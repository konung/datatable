# 1. data table subclass is initialized
#   class methods are going to be called on the class instance, and the class will store table data
#
# 2. instantiate an instance of the data table subclass ( OrdersIndex.new)
#
# 3. query the instance w/ pagination and sorting params
#    a query gets executed w/ params -> ARel
#    results get stored  -> AR
#    results get passed back as json

require 'datatable/railtie'
require 'datatable/errors'
require 'datatable/helper'
require 'datatable/active_record_dsl'

# during normal execution rails should have already pulled
# this in but we may have to do it ourselves in some tests
require 'action_view' unless defined?(ActionView)
require 'ostruct'

module Datatable

  PARAM_MATCHERS = [
      /\AiDisplayStart\z/,
      /\AiDisplayLength\z/,
      /\AiColumns\z/,
      /\AsSearch\z/,
      /\AbRegex\z/,
      /\AbSearchable_\d+\z/,
      /\AsSearch_\d+\z/,
      /\AbRegex_\d+\z/,
      /\AbSortable_\d+\z/,
      /\AiSortingCols\z/,
      /\AiSortCol_\d+\z/,
      /\AsSortDir_\d+\z/,
      /\AsEcho\z/
  ]

  class Base

    include Datatable::ActiveRecordDSL
    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TagHelper

    def self.config(&block)
      @config ||= OpenStruct.new
      if block_given?
        yield @config
      else
        return @config
      end
    end

    def self.model
      @model
    end

    attr_accessor :records

    def self.sql(*args)
      if args.empty?
        @sql_string
      else
        @sql_string = args.first
      end
    end
   
    def self.count(*args)
      if args.empty?
        @count_sql
      else
        @count_sql = args.first
      end
    end

    def self.where(*args)
      if args.empty?
        @where_sql
      else
        @where_sql = args.first
      end
    end

    def self.template_text
      (where || "") + (count || "") + (sql || "")
    end

    def self.columns(*args)
      if args.empty?
        raise 'There are no columns on the Datatable (use assign__column_names)' unless @columns
        return @columns
      end

      @columns = ActiveSupport::OrderedHash.new
      args.each { |element| @columns[element.keys.first] = element.values.first }
    end

    def self.option(key,value)
      @javascript_options ||= {}
      @javascript_options[key.to_s] = value
    end

    def self.javascript_options
      @javascript_options || {}
    end

    def self.known_parameter(arg)
      PARAM_MATCHERS.each do |matcher|
        return true if arg =~ matcher
      end
      false
    end

    def self.unknown_parameter(arg)
      !(known_parameter(arg))
    end

    def self.query(params, variables={})
      # convert all of the keys to strings and filter out any non valid datatable parameters.
      skparams = params.stringify_keys.delete_if{|k,v| unknown_parameter(k) }
      
      # take advantage of the fact that Datatables uses hungarian notation
      # and convert all of the parameters to their correct type here instead
      # of worring about it all throughthe code base
      skparams.each do |key, value|
        skparams[key] = value.to_i if key =~ /^i/
        skparams[key] = value.to_s if key =~ /^s/
        skparams[key] = (value ? true : false) if key =~ /^b/
      end

      # scan the template text looking for the variables so 
      # we can give a sensible error if it's missing
      variables.each do |key, value|
        unless template_text =~ /#{key}/m
          fail "Substitution key: '#{key}' not in found in SQL text"
        end
      end
 
      datatable = new(skparams)
      datatable.count(variables)
      datatable.instance_query(variables)
      datatable
    end


    # only used in testing
    def self.to_sql
      relation.to_sql
    end

    # We want to allow people to access routes in data tables.
    #
    # Including the rails routes doesn't work b/c for some reason 
    # the route methods are not availble as class methods
    # no matter if we use include or send.
    #
    # This works for now.
    def self.method_missing(symbol, *args, &block)
      if symbol.to_s =~ /(path|url)$/
        return Rails.application.routes.url_helpers.send(symbol, *args)
      end

      super(symbol, *args, &block)
    end

    def initialize(params={})
      @params = params
      @records = []
    end

    def instance_query(variables={})
      @records =  self.class.sql ? sql_instance_query(variables) : active_record_instance_query
      self
    end

    def count(variables={})
      @count = self.class.sql ? sql_count(variables) : self.class.relation.count
    end


    def to_json
      {
        'sEcho' => (@params['sEcho'] || -1).to_i,
        'aaData' => @records,
        'iTotalRecords' => @records.length,
        'iTotalDisplayRecords' => (@count || 0)
      }
    end

    private

#    def sql_count
#      if self.class.count
#        count_sql = self.class.count.dup
#        if self.class.where && !@already_counted
#          count_sql << " WHERE " + self.class.where
#        end
#        @already_counted = true
#      else
#        count_sql = query_sql.sub(/^\s*SELECT(.*?)FROM/mi, 'SELECT count(*) FROM')
#        # we don't tak the where on because it's already been done inside query_sql
#      end
#      ActiveRecord::Base.connection.select_value(count_sql).to_i
#    end
    #
    def sql_string
      self.class.sql ? self.class.sql.dup : nil
    end

    def where_string
      self.class.where ? self.class.where.dup : nil
    end

    def count_string
      self.class.count ? self.class.count.dup : nil
    end

    def sql_count(variables)
      if count_string.blank?
        query = query_sql.sub(/^\s*SELECT(.*?)FROM/mi, 'SELECT count(*) FROM')
      else
        if where_string.blank?
          query = count_string
        else
          query = count_string + " WHERE " + where_string
        end
      end
      query = substitute_variables(query.dup, variables)
      ActiveRecord::Base.connection.select_value(query).to_i
    end

    def column_attributes
      self.class.columns
    end

    def evaluate_variable(value)
      if value.kind_of?(Array)
        if value.empty?
          return "(NULL)"
        else
          return "(#{value.join(',')})"
        end
      end
      value.to_s
    end

    def substitute_variables(template, substitutions)
      result = template.dup
      substitutions.stringify_keys.each do |key, value|
        if template =~ /#{key}/m
          result.gsub!("{{#{key}}}", evaluate_variable(value))
        else
          #fail "Substitution key: '#{key}' not in found in SQL text\n#{template}"
        end
      end
      result
    end

    def sql_instance_query(variables)
      query = query_sql + order_by_sql_fragment + limit_offset_sql_fragment
      query = substitute_variables(query.dup, variables)
      connection = self.class.model ? self.class.model.connection : ActiveRecord::Base.connection
      connection.select_rows(query)
    end

    def active_record_instance_query
      raise "set_model not called on #{self.class.name}" unless self.class.model
      relation = self.class.relation
      if(search = search_string)
        relation = relation.where(search)
      end
      relation = relation.order(order_string) if @params['iSortingCols'].to_i > 0
      relation = relation.offset(@params['iDisplayStart']).limit(@params['iDisplayLength'])
      self.class.model.connection.select_rows(relation.to_sql)
    end

    #
    # TODO: look closer at this should it be isortingcols -1 ?
    #
    def order_string
      result = []

      @params['iSortingCols'].times do |count|
        col_index = @params["iSortCol_#{count}"]
        col_dir = @params["sSortDir_#{count}"]
        col_name = column_attributes.keys[col_index]
        result << " " + (col_name + " " + col_dir)
      end

      result.join(", ")
    end


    def sanitize(*args)
      ActiveRecord::Base.send(:sanitize_sql_array, args)
    end

    def global_search_string
      return nil if @params['sSearch'].blank?
      filter = @params['sSearch'].strip
      result = []

      column_attributes.keys.each_with_index do |col, i|
        next if column_attributes[col][:bSearchable] == false
        next unless @params["bSearchable_#{i}"]
        attributes = column_attributes[col]
        if attributes[:type] == :string
          result << sanitize("#{col} #{like_sql} ?", "%#{filter}%")
        elsif attributes[:type] == :integer
          # to_i returns 0 on strings without numberic values so only search for 0 when the parameter actually contains '0'
          if filter == "0" || filter.to_i != 0
            result << "#{col} = #{filter.to_i}"
          end
        end
      end

      return nil if result.empty?
      "(" + result.join(" OR ") + ")"
    end

    def individual_search_strings
      keys = column_attributes.keys
      result = []
      ((@params['iColumns']||1)).times do |i|
        next if @params["sSearch_#{i}"].blank?
        filter = @params["sSearch_#{i}"].strip
        raise "can't search unsearchable column'" if column_attributes[keys[i]][:bSearchable] == false
        attributes = column_attributes[keys[i]]
        if attributes[:type] == :string
          result << sanitize("#{keys[i]} #{like_sql} ?", "%#{filter}%")
        elsif attributes[:type] == :integer
          # to_i returns 0 on strings without numeric values only search for 0 when the parameter actually contains '0'
          if filter == "0" || filter.to_i != 0
            result << "#{keys[i]} = #{filter}"
          else
            result << '1 = 2'
          end
        end
      end
      return nil if result.empty?
      "(" + result.join(" AND ") + ")"
    end

    def search_string
      result = [global_search_string, individual_search_strings].compact
      result.join(" AND ") if result.any?
    end

    def limit_offset_sql_fragment
      return '' unless @params['iDisplayStart'].present? && @params['iDisplayLength'].present?
      result = ""
      result << " LIMIT #{@params['iDisplayLength']}" if @params['iDisplayLength']
      result << " OFFSET #{@params['iDisplayStart']}" if @params['iDisplayStart']
      result
    end

    def order_by_sql_fragment
      if @params['iSortingCols'].to_i > 0
        " ORDER BY" + order_string
      else
        ""
      end
    end

    def query_sql
      result =  self.class.sql.dup
      if self.class.where
        result << " WHERE " + self.class.where
        if search_string
          result << " AND " + search_string
        end
      else
        if search_string
          result << " WHERE " + search_string
        end
      end
      result
    end

    def like_sql
      Datatable::Base.config.sql_like || "LIKE"
    end

  end
end

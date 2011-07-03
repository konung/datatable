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
require 'datatable/helper'
require 'datatable/active_record_dsl'

# during normal execution rails should have already pulled
# this in but we may have to do it ourselves in some tests
require 'action_view' unless defined?(ActionView)
require 'ostruct'

module Datatable
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
      return @sql_string if args.empty?

      @sql_string = args.first
    end

    def self.count(*args)
      if args.empty?
        return @count_sql
      else
        @count_sql = args.first
      end
    end

    def self.where(*args)
      if args.empty?
        return @where_sql
      else
        @where_sql = args.first
      end
    end

    def self.sql_string
      @sql_string
    end

    def self.columns(*args)
      if args.empty?
        raise 'There are no columns on the Datatable (use assign__column_names)' unless @columns
        return @columns
      end

      @columns = ActiveSupport::OrderedHash.new
      args.each { |element| @columns[element.keys.first] = element.values.first }
    end


    def self._columns
      # given the select part of a sql query
      # for each of the columns requested
      # create a hash inside of the columns hash
      #   -- figure out the typ
      select = sql_string.scan(/SELECT(.*)FROM/im)[0][0]
      select_columns = select.split(",").map(&:strip)

      select_columns.each_with_object({}) do |column, hash|

        table_name = column.split('.')[0]

        c = Class.new(ActiveRecord::Base)

        c.class_eval do
          set_table_name table_name
        end

        type = c.columns.detect { |col| col.name == column.split('.').last.to_s}.type

        hash[column] = {:type => type}
      end

    end

    def self.option(key,value)
      @javascript_options ||= {}
      @javascript_options[key.to_s] = value
    end

    def self.javascript_options
      @javascript_options || {}
    end

    def self.query(params, variables={})
      params.each do |key, value|
        params[key] = value.to_i if key =~ /^i/
      end

      if @sql_string && !@already_substituted
        substitute_variables(variables)
      end
      @already_substituted = true

      datatable = new(params)
      datatable.instance_query
      datatable.count
      datatable
    end

    def self.substitute_variables(substitutions)
      substitutions.stringify_keys.each do |key, value|
        unless "#{@where_sql}#{@count_sql}#{@sql_string}" =~ /#{key}/m
          fail "Substitution key: '#{key}' not in found in SQL text"
        end
        new_text = value.kind_of?(Array) ? "(#{value.join(', ')})" : value.to_s
        @where_sql.try(:gsub!,"{{#{key}}}", new_text )
        @sql_string.try(:gsub!, "{{#{key}}}", new_text)
        @count_sql.try(:gsub!,"{{#{key}}}", new_text)
      end
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

    def instance_query
      @records =  self.class.sql_string ? sql_instance_query : active_record_instance_query
      self
    end

    def count
      @count = self.class.sql_string ? sql_count : self.class.relation.count
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

    def sql_count
      if self.class.count
        count_sql = self.class.count.dup
        if self.class.where && !@already_counted
          count_sql << " WHERE " + self.class.where
        end
        @already_counted = true
      else
        count_sql = query_sql.sub(/^\s*SELECT(.*?)FROM/mi, 'SELECT count(*) FROM')
        # we don't tak the where on because it's already been done inside query_sql
      end
      ActiveRecord::Base.connection.select_value(count_sql).to_i
    end

    def column_attributes
      self.class.columns
    end

    def sql_instance_query
      connection = self.class.model ? self.class.model.connection : ActiveRecord::Base.connection
      connection.select_rows(query_sql + order_by_sql_fragment + limit_offset_sql_fragment)
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
      filter = @params['sSearch']
      return nil unless filter
      result = []

      column_attributes.keys.each_with_index do |col, i|
        next if column_attributes[col][:bSearchable] == false
        next unless @params["bSearchable_#{i}"]
        attributes = column_attributes[col]
        if attributes[:type] == :string
          result << sanitize("#{col} #{like_sql} ?", "%#{filter}%")
        else
          # to_i returns 0 on arbitrary strings
          # so only search for integers = 0 when someone actually typed 0
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
      ((@params['iColumns']||1) - 1).times do |i|
        filter = @params["sSearch_#{i}"]
        next if filter.blank?
        raise "can't search unsearchable column'" if column_attributes[keys[i]][:bSearchable] == false
        attributes = column_attributes[keys[i]]
        if attributes[:type] == :string
          result << sanitize("#{keys[i]} #{like_sql} ?", "%#{filter}%")
        else
          # to_i returns 0 on arbitrary strings
          # so only search for integers = 0 when someone actually typed 0
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
      result =  self.class.sql_string.dup
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

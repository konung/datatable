# 1. data table subclass is initialized
#   class methods are going to be called on the class instance, and the class will store table data
#
# 2. instantiate an instance of the data table subclass ( OrdersIndex.new)
#
# 3. query the instance w/ pagination and sorting params
#    a query gets executed w/ params -> ARel
#    results get stored  -> AR
#    results get passed back as json

require 'data_table/railtie'
require 'data_table/helper'
require 'data_table/active_record_dsl'

module DataTable
  class Base

    include DataTable::ActiveRecordDSL
    extend ActionView::Helpers::UrlHelper
    extend ActionView::Helpers::TagHelper

    def self.model
      @model
    end

    attr_accessor :records

    def self.sql(*args)
      if args.empty?
        return @sql_string
      end

      @sql_string = args.first
    end

    def self.sql_string
      @sql_string
    end

    def self.columns(*args)
      if args.empty?
        raise 'There are no columns on the DataTable (use assign__column_names)' unless @columns
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
      @javascript_options[key] = value
    end

    def self.javascript_options
      @javascript_options || {}
    end

    def self.query(params)
      params.each do |key, value|
        params[key] = value.to_i if key =~ /^i/
      end
      datatable = new(params)
      datatable.instance_query
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

    def instance_query
      @records =  self.class.sql_string ? sql_instance_query : active_record_instance_query
      self
    end

    def to_json
      {
        'sEcho' => (@params['sEcho'] || -1).to_i,
        'aaData' => records,
        'iTotalRecords' => @records.length,
        'iTotalDisplayRecords' => records.length,
      }
    end

    private

    def column_attributes
      self.class.columns
    end

    def sql_instance_query
      connection = self.class.model ? self.class.model.connection : ActiveRecord::Base.connection
      connection.select_rows(query_sql)
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

    def limit_offset
      result = ""
      result << " LIMIT #{@params['iDisplayLength']}" if @params['iDisplayLength']
      result << " OFFSET #{@params['iDisplayStart']}" if @params['iDisplayStart']
      result
    end

    def sanitize(*args)
      ActiveRecord::Base.send(:sanitize_sql_array, args)
    end

    def global_search_string
      filter = @params['sSearch']
      return nil unless filter
      result = []

      column_attributes.keys.each_with_index do |col, i|
        next unless @params["bSearchable_#{i}"]
        attributes = column_attributes[col]
        if attributes[:type] == :string
          result << sanitize("#{col} like ?", "%#{filter}%")
        else
          # to_i returns 0 on arbitrary strings
          # so only search for integers = 0 when someone actually typed 0
          if filter == "0" || filter.to_i > 0
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
      (@params['iColumns'] - 1).times do |i|
        filter = @params["sSearch_#{i}"]
        next if filter.blank?
        attributes = column_attributes[keys[i]]
        if attributes[:type] == :string
          result << sanitize("#{keys[i]} like ?", "%#{filter}%")
        else
          # to_i returns 0 on arbitrary strings
          # so only search for integers = 0 when someone actually typed 0
          if filter == "0" || filter.to_i > 0
            result << "#{keys[i]} = #{filter.to_i}"
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


    def query_sql
      current_sql = self.class.sql_string.dup
      if(search = search_string)
        current_sql << "WHERE " + search
      end
      current_sql << (" ORDER BY" + order_string) if @params['iSortingCols'].to_i > 0
      current_sql << limit_offset
    end

  end
end

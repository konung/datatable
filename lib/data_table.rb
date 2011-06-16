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

    def self.model
      @model
    end

    attr_accessor :records

    def self.columns
      raise 'There are no columns on the DataTable (use assign_column_names)' unless @columns
      @columns
    end

    def self.assign_column_names(args)
      @columns = args
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




    #------------------------------------------------------------------------------------------------------------------
    #  type       name                  description
    #------------------------------------------------------------------------------------------------------------------
    #  int        iDisplayStart       Display start point
    #
    #  int        iDisplayLength      Number of records to display
    #
    #  int        iColumns            Number of columns being displayed (useful for getting individual column search info)
    #
    #  string     sSearch             Global search field
    #
    #  boolean    bEscapeRegex        Global search is regex or not
    #
    #  boolean    bSortable_(int)     Indicator for if a column is flagged as sortable or not on the client-side
    #
    #  boolean    bSearchable_(int)   Indicator for if a column is flagged as searchable or not on the client-side
    #
    #  string     sSearch_(int)	      Individual column filter
    #
    #  boolean    bEscapeRegex_(int)	Individual column filter is regex or not
    #
    #  int        iSortingCols	      Number of columns to sort on
    #
    #  int        iSortCol_(int)	    Column being sorted on (you will need to decode this number for your database)
    #
    #  string     sSortDir_(int)	    Direction to be sorted - "desc" or "asc". Note that the prefix for this variable
    #                                 is wrong in 1.5.x where iSortDir_(int) was used)
    #
    #  string     sEcho	              Information for DataTables to use for rendering
    #
    #-----------------------------------------------------------------------------------------------------------------
    def self.query(params)
      params.each do |key, value|
        params[key] = value.to_i if key =~ /^i/
      end

      datatable = new(params)
      datatable.query
      datatable
    end

    # Private
    def self.to_sql
      relation.to_sql
    end

    def initialize(params={})
      @params = params
      @records = []
    end

    #------------------------------------------------------------------------------------------------------------------
    #  type       name                  description
    #------------------------------------------------------------------------------------------------------------------
    #  int        iTotalRecords         Total records, before filtering (i.e. the total number of records in
    #                                   the database)
    #
    #  int        iTotalDisplayRecords  Total records, after filtering (i.e. the total number of records after
    #                                   filtering has been applied - not just the number of records being returned
    #                                   in this result set)
    #
    #  string     sEcho                 An unaltered copy of sEcho sent from the client side. This parameter will
    #                                   change with each draw (it is basically a draw count) - so it is important
    #                                   that this is implemented. Note that it strongly recommended for security
    #                                   reasons that you 'cast' this parameter to an integer in order to prevent
    #                                   Cross Site Scripting (XSS) attacks.
    #
    #  string     sColumns              Optional - this is a string of column names, comma separated (used in
    #                                   combination with sName) which will allow DataTables to reorder data on the
    #                                   client-side if required for display
    #
    #  array      aaData                The data in a 2D array
    #-----------------------------------------------------------------------------------------------------------------
    def to_json
      {
        'sEcho' => (@params['sEcho'] || -1).to_i,
        'aaData' => records,
        'iTotalRecords' => @records.length, 
        #self.class.model.count,
        'iTotalDisplayRecords' => records.length,
      }
    end

    def self.sql(s)
      @sql_string = s
    end

    def self.sql_string
      @sql_string
    end

    #
    # TODO: look closer at this should it be isortingcols -1 ?
    #
    def order_string
      result = []
      @params['iSortingCols'].times do |count|
        col_index = @params["iSortCol_#{count}"]
        col_dir = @params["sSortDir_#{count}"]
        col_name = self.class.columns[col_index][0]
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
      self.class.columns.each_with_index do |col, i|
       next unless @params["bSearchable_#{i}"]
       if col[1] == :string
         result << sanitize("#{col[0]} like ?", "%#{filter}%")
       else
         # to_i returns 0 on arbitrary strings
         # so only search for integers = 0 when someone actually typed 0
         if filter == "0" || filter.to_i > 0
          result << "#{col[0]} = #{filter.to_i}"
         end
       end

      end
      return nil if result.empty?
      "(" + result.join(" OR ") + ")"
    end

    def individual_search_strings
      cols = self.class.columns
      result = []
      (@params['iColumns'] - 1).times do |i|
        filter = @params["sSearch_#{i}"]
        next if filter.blank?
        if cols[i][1] == :string
          result << sanitize("#{cols[i][0]} like ?", "%#{filter}%")
        else
          # to_i returns 0 on arbitrary strings
          # so only search for integers = 0 when someone actually typed 0
          if filter == "0" || filter.to_i > 0
           result << "#{cols[i][0]} = #{filter.to_i}"
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

    def query
      if self.class.sql_string
        current_sql = query_sql
        connection = self.class.model ? self.class.model.connection : ActiveRecord::Base.connection
        @records = connection.select_rows(current_sql)

      else
        raise "set_model not called on #{self.class.name}" unless self.class.model
        relation = self.class.relation
        if(search = search_string)
          relation = relation.where(search)
        end
        relation = relation.order(order_string) if @params['iSortingCols'].to_i > 0
        relation = relation.offset(@params['iDisplayStart']).limit(@params['iDisplayLength'])
        @records = self.class.model.connection.select_rows(relation.to_sql)
      end
      self
    end

  end
end

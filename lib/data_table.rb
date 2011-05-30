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

module DataTable

  VERSION = "0.1.0.dev1"

  class Base

    attr_accessor :records

    def self.relation
      @relation
    end

    def self.relation=(right)
      @relation = right
    end

    def self.model
      @model
    end

    def self.assign_column_names(args)
      @column_names = args
    end

    def self.column_names
      @column_names
    end

    def self.columns
      #TODO: make more helpful
      raise 'There are no columns on the DataTable' unless @columns
      @columns
    end

    def self.current_model
      @inner_model || @model
    end

    def self.option(key,value)
      @options ||= {}
      @options[key] = value
    end

    def self.javascript_options(path)
      defaults = {
        'sAjaxSource' =>  path,
        'sDom' => '<"H"lr>t<"F"ip>',
        'iDisplayLength' => 10,
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers"
      }
      @options ? @options.merge(defaults) : defaults
    end

    def self.column(c)
      raise "set_model not called on #{self.name}" unless @model
      @columns ||= []
      @columns << "#{@model.table_name}.#{c}"
      @relation= @relation.select(current_model.arel_table[c])
    end

    # TODO: Change to joins to match arel
    def self.join(association, &block)
      @inner_model = current_model.reflect_on_association(association).klass
      @relation = @relation.joins(association)
      instance_eval(&block) if block_given?
      @inner_model = nil
    end

    def self.set_model(model)
      @model = model
      @relation = model
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

    def order_string
      result = []
      @params['iSortingCols'].times do |count|
        col_index = @params["iSortCol_#{count}"]
        col_dir = @params["sSortDir_#{count}"]
        col_name = self.class.column_names[col_index]
        result << " " + (col_name + " " + col_dir)
      end
      " ORDER BY" + result.join(", ")
    end

    def limit_offset
      result = ""
      result << " LIMIT #{@params['iDisplayLength']}" if @params['iDisplayLength']
      result << " OFFSET #{@params['iDisplayStart']}" if @params['iDisplayStart']
      result
    end

    def query
      if self.class.sql_string
        raise "set_model not called on #{self.class.name}" unless self.class.model
        current_sql = self.class.sql_string.dup
        current_sql << order_string if @params['iSortingCols'].to_i > 0
        current_sql << limit_offset
        @records = self.class.model.connection.select_rows(current_sql)
      else
        relation = self.class.relation 
        relation = relation.offset(@params['iDisplayStart']).limit(@params['iDisplayLength'])
        @records = self.class.model.connection.select_rows(relation.to_sql)
      end
      self
    end


    # generate javascript
    def javascript
      <<-CONTENT.gsub(/^\s{8}/,"")
        <script type="text/javascript">
          $(document).ready(function() {
            $('.datatable').dataTable({#{datatable_options}});
          });
        </script>
      CONTENT
    end

    # convienence method to provide html+javascript
    def render
      (html + javascript).html_safe
    end


  end
end

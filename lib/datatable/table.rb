#require 'active_support/core_ext'
# Boat.reflect_on_all_associations.first.klass

module Datatable

  class Table
    attr_accessor :table, :include

    def initialize(model_class)
      @model = model_class
      @table = model_class.table_name
      @include = []
      @columns = []
      @option = {
        :bProcessing => true,
        :bServerSide => true,
        :sPaginationType => "full_numbers",
        :iDisplayLength => 25,
        :bLengthChange => true,
        :bStateSave => false,
        :bFilter => true,
        :bAutoWidth => false,
        :aaSorting => "[[0, 'ASC']]",
        :bJQeuryUI => true,
        :sAjaxSource => "/#{table}.js"
      }
      yield(self) if block_given?
    end

    def count
      @columns.count
    end

    # returns true if the selector is in the form 'table_name.column_name'
    def qualified_selector?(selector)
      selector =~ /(\w+)\.(\w+)/
    end



    #
    #
    def column(name, render=nil, select=nil,  type=nil)

      result = Column.new

      # The name value will be titlized and used as the tables
      # column title.
      #
      result.name = name

      #
      # SELECT
      #
      if select
        # a user supplied select was provided
        if qualified_selector?(select)
          selector_table, selector_column = select.split(".")
          unless selector_table == @table
            # add the selectors table to include since
            # it's not the current models table.
            @include << selector_table
          end
          result.select = "#{@model.reflect_on_association(selector_table.to_sym).table_name}.#{selector_column}"
        else
          # it's an unqualifed selector
          if @model.column_names.include?(select.to_s)
            result.select = "#{@table_name}.#{select}"
          else
            raise "'#{@table_name}' does not include column '#{select}'"
          end
        end
      else
        # no user supplied select so determine it from name
        if @model.column_names.include?(name.to_s)
            result.select =  (select ? select : "#{@table}.#{name}")
        else
          result.select = nil
        end
      end

      #
      # RENDER
      #
      if render.nil?
        #
        # if no render is supplied then assume then assume
        # that it's the attribute name on the current model
        #
        result.render = lambda{|o| o.send(name.to_s)}
      elsif render.kind_of?(Proc)
        #
        # if they supplied a proc then simply save the proc
        # in render it will be used later
        #
        result.render = render
      else
        #
        # if they supplied anything else just save it's string
        # int render
        #
        result.render = render.to_s
      end

      #
      # TYPE is unused right now
      #
      result.type =  (type ? render : :integer)


      @columns << result
    end
    #
    #
    #
    #
    #
    #
    #
    #
    

    def script
      result = <<-CONTENT.gsub(/^\s{8}/,"")
        <script type="text/javascript">
          $(document).ready(function() {
            $('.datatable').dataTable({
              sDom: '<"H"lr>t<"F"ip>',
              oLanguage: {
                sSearch: "Search",
                sProcessing: "<img alt='Spinner' src='/images/spinner.gif'/>"
              },
              bJQueryUI: #{@option[:bJQeuryUI]},
              sPaginationType: "#{@option[:sPaginationType]}",
              iDisplayLength: #{@option[:iDisplayLength]},
              bProcessing: #{@option[:bProcessing]},
              bServerSide: #{@option[:bServerSide]},
              sAjaxSource: "#{@option[:sAjaxSource]}",
              bLengthChange: #{@option[:bLengthChange]},
              bStateSave: #{@option[:bStateSave]},
              bFilter: #{@option[:bFilter]},
              bAutoWidth: #{@option[:bAutoWidth]},
              aaSorting: #{@option[:aaSorting]},
              aoColumns: [
      CONTENT
      column_content = []
      1.upto(@columns.count) do |index|
        if @columns[index-1].select
          column_content << "          {bSortable: true}"
        else
          column_content << "          {bSortable: false}"
        end
      end
      result << column_content.join(",\n ")
      result << "\n"
      result << <<-CONTENT.gsub(/^\s{8}/,"")
              ]
             });
          });
        </script>
      CONTENT
    end

    #
    #
    #
    #
    def html
      result =<<-CONTENT.gsub(/^\s{8}/,"")
        <div class='datatable_container'>
          <table class='datatable'>
            <thead>
              <tr>
      CONTENT
      @columns.each do |column|
        result << "        <th>#{column.name.to_s.titleize}</th>\n"
      end
      result << <<-CONTENT.gsub(/^\s{8}/,"")
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      CONTENT
      result
    end

    def render
      (html + script).html_safe
    end


    def conditions(params)
      ""
    end


    def page(params)
      (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1
    end

    # iSortingCols  - gives number of columns being sorted
    # iSortCol_0    - gives the index of the highest precedent column for sorting (the value is zero to n-1 columns)
    # sSortDir_0    - gives the direction of the highest precedent column for sorting (asc or desc)
    # iSortCol_1    - gives the index of the next highest precedent column for sorting
    # sSortDir_1    - gives the direction of next the highest precedent column for sorting
    def order(params)
      result = []
      1.upto(params[:iSortingCols].to_i) do |count|
        cur_sort_col = "iSortCol_#{count - 1}".to_sym
        cur_sort_dir = "sSortDir_#{count - 1}".to_sym
        col_select = @columns[params[cur_sort_col].to_i].select
        if col_select
            col_direction  = params[cur_sort_dir].upcase
          result << "#{col_select} #{col_direction}"
        end
      end
      result.join(", ")
    end

    def sql_count(params)
      @model.includes(@include).count
    end

    def array_of(data)
      result = []
      @columns.each do |column|
        if column.render.kind_of?(Proc)
          result << column.render.call(data)
        else
          result << column.render
        end
      end
      result
    end

    def paginate(params)
      @model.paginate(
        :page => page(params),
        :order => order(params),
        :per_page => params[:iDisplayLength],
        :include => @include
      )
    end

    # http://www.datatables.net/usage/server-side
    #
    #
    #  type       name                  description
    # ----------------------------------------------------------------------------------------------------------
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
    #
#    def json(params)
#      data = paginate(params)
#      total_objects = sql_count(params)
#      { 'sEcho' => params[:sEcho].to_i || -1,
#        'iTotalRecords' => total_objects,
#        'iTotalDisplayRecords'=> total_objects,
#        'aaData' => data.map{|e| array_of(e)}
#      }.to_json
#    end
    def to_json(params)
      result = {}
      result[:iTotalRecords] = 0
      result[:iTotalDisplayRecords] = 0
      result[:sEcho] = params.has_key?(:sEcho) ? params[:sEcho].to_i : -1
      result[:aaData] = []
      ActiveSupport::JSON.encode(result)
    end

  end
end





=begin
  def index
    @datatable = Datatable::Datatable.build(Boat) do |table|
      table.column "serial_number.value", lambda{|truck| truck.serial_number.value}, "serial_number.value"
      table.column "serial_number.date_code", lambda{|truck| truck.serial_number.date_code}, "serial_number.date_code"
      table.column "boat_size.name", lambda{|truck| truck.boat_size.name}, "boat_size.name"
      table.column "boat_model.name", lambda{|truck| truck.boat_model.name}, "boat_model.name"
      #table.column :dealer, lambda{|truck| truck.dealer.nick_name}, "dealer.nick_name"
      table.column "base_color.name", lambda{|truck| truck.base_color.name}, "base_color.name"
      table.column "accent_color.name", lambda{|truck| truck.accent_color.name}, "accent_color.name"
      table.column nil, lambda{|truck| "<a href='#{boat_path(truck)}'>Show</a>" }, "Action"
    end
    respond_to do |format|
      format.html # index.html.erb
      format.js { render :json => @datatable.json(params), :content_type => 'text/html'}
    end
  end
=end
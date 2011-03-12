#require 'active_support/core_ext'

# Boat.reflect_on_all_associations.first.klass

module Datatable

  class Datatable
    attr_reader :controller, :action
    attr_accessor :table, :include

    def self.build(model_class)
      table = new(model_class)
      yield(table)
      table
    end

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
    end

    def column_count
      @columns.count
    end

    #
    #
    def column(name, render=nil, select=nil,  type=nil)
      
      result = Column.new

      result.name = name

      if select
        # a user supplied select was provided
        if select =~ /(\w+)\.(\w+)/
          table = $1
          column = $2
          unless $1 == @table
            @include << $1
          end
          result.select = select
        else
          result.select = select
        end
      else # no user supplied select so determine it from name
        if @model.column_names.include?(name.to_s)
            result.select =  (select ? select : "#{@table}.#{name}")
        else
          result.select = nil
        end
      end

      result.render = (render ? render : lambda{|o| o.send(name.to_s) || "" })
      
      result.type =  (type ? render : :integer)
      @columns << result
    end

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

    def array_of(data)
      result = []
      @columns.each do |column|
        result << column.render.call(data)
      end
      result
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
        col_name = @columns[params[cur_sort_col].to_i].select
        if col_name
            col_direction  = params[cur_sort_dir].upcase
          result << "#{col_name} #{col_direction}"
        end
      end
      result.join(", ")
    end

    def count(params)
      @model.count(:include => @include)
    end

    def paginate(params)
      @model.paginate(
        :page => page(params),
        :order => order(params),
        :per_page => params[:iDisplayLength],
        :include => @include
      )
    end

    def json(params)
      data = paginate(params)
      total_objects = count(params)
      { 'sEcho' => params[:sEcho].to_i || -1,
        'iTotalRecords' => total_objects,
        'iTotalDisplayRecords'=> total_objects,
        'aaData' => data.map{|e| array_of(e)}
      }.to_json
    end
    
  end
end
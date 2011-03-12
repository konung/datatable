module Datatable

  class Datatable
    attr_reader :controller, :action
    attr_accessor :table

    def self.build(model_class)
      table = new(model_class)
      yield(table)
      table
    end

    def initialize(model_class)
      @model = model_class
      @table = model_class.table_name
      @columns = []
      @view_stuff = []
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

    def []=(index,hash)
      @view_stuff[index] = hash
    end

    #
    #
    def column(name, extractor=nil, fetcher=nil, type=nil)
      result = []
      result << name
      if @model.column_names.include?(name.to_s)
          result << (extractor ? extractor : "#{@table}.#{name}")
      else
        result << nil
      end
      result << (fetcher ? fetcher : lambda{|o| o.send(name) || "" })
      result << (type ? fetcher : :integer)
      @columns << result
    end

    def script
      <<-RESULT.gsub(/^\s{8}/,"")
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
             });
          });
        </script>
      RESULT
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
        result << "        <th>#{column[0]}</th>\n"
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
        result << column[2].call(data)
      end
      result
    end

    def conditions(params)
      ""
    end

    def count(params)
      @model.count
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
        col_name = @columns[params[cur_sort_col].to_i][1]
        if col_name
            col_direction  = params[cur_sort_dir].upcase
          result << "#{col_name} #{col_direction}"
        end
      end
      result.join(", ")
    end

    def paginate(params)
      @model.paginate(
        :page => page(params),
        :order => order(params),
        :per_page => params[:iDisplayLength] )
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
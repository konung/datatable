module Datatable
  module Helper

    def datatable
      "#{datatable_html} #{datatable_javascript}".html_safe
    end


    def datatable_html
      <<-CONTENT.gsub(/^\s{6}/,"").html_safe
        <table id='datatable'>
          <thead>
            <tr>
      #{headings}
            </tr>
          </thead>
          <tbody>
          </tbody>
          <tfoot>
          <tr>
            #{individual_column_searching if @datatable.javascript_options['individual_column_searching']}
          </tr>
          </tfoot>
        </table>
      CONTENT
    end


    def datatable_javascript
      raise "No @datatable assign" unless @datatable
      # TODO: this will escape ampersands
      # ERB::Util.h('http://www.foo.com/ab/asdflkj?asdf=asdf&asdf=alsdf') => "http://www.foo.com/ab/asdflkj?asdf=asdf&amp;asdf=alsdf" 
      "<script>
        function replace(string, columns) {
          var i = columns.length;
          while(i--){
            string = string.replace('{{' + i + '}}', columns[i]);
            string = string.replace('%7B%7B' + i + '%7D%7D', columns[i]);
          }
          return string;
        }
        $(function(){

          var oTable = $('#datatable').dataTable(#{javascript_options.to_json.gsub(/\"column_defs\"/, columns)})


          $('tfoot input').keyup( function () {
            /* Filter on the column (the index) of this element */
            oTable.fnFilter( this.value, $('tfoot input').index(this) );
          } );

        });

      </script>".html_safe
    end

    private

    def headings
      @datatable.columns.map do |key, value|
        "<th>#{value[:heading] || humanize_column(key)}</th>"
      end.join
    end

    def humanize_column(name)
      columns = name.split('.')
      [columns[0].singularize, columns[1]].map(&:humanize).map(&:titleize).join(" ")
    end

    def javascript_options
      defaults = {
        'sAjaxSource' => h(request.path),
        'sDom' => '<"H"lfr>t<"F"ip>',
        'iDisplayLength' => 10, # Number per page
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers",
        "aoColumnDefs" => 'column_defs'
      }
      defaults.merge(@datatable.javascript_options)
    end

    def columns
      array = []
      @datatable.columns.each do |key, value|
        if value.has_key?(:link_to)
          array << %Q|
            {
                "fnRender": function(oObj) {
                    return replace('#{value[:link_to]}', oObj.aData);
             },
             "aTargets": [#{@datatable.columns.keys.index(key)}]
            }|
        end
      end
      "[" + array.join(", ") + "]"
    end


    def individual_column_searching
      # TODO: placeholders only supported in HTML5 
      @datatable.columns.map do |key, value| 
        %Q{
          <th>
            <input type="text" placeholder="#{key}" class="search_init" />
          </th>
        }
      end.join
    end

  end
end

module DataTable
  module Helper

    def data_table
      "#{data_table_html} #{data_table_javascript}".html_safe
    end


    def data_table_html
      <<-CONTENT.gsub(/^\s{6}/,"").html_safe
        <table id='data_table'>
          <thead>
            <tr>
      #{headings}
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      CONTENT
    end


    def data_table_javascript
      raise "No @data_table assign" unless @data_table
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
          $('#data_table').dataTable(#{javascript_options.to_json.gsub(/\"column_defs\"/, columns)})
        });
      </script>".html_safe
    end

    private

    def headings
      @data_table.columns.map do |key, value|
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
        'iDisplayLength' => 10,
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers",
        "aoColumnDefs" => 'column_defs'
      }
      @data_table.javascript_options.merge(defaults)
    end

    def columns
      array = []
      @data_table.columns.each do |key, value|
        if value.has_key?(:link_to)
          array << %Q|
            {
                "fnRender": function(oObj) {
                    return replace('#{value[:link_to]}', oObj.aData);
             },
             "aTargets": [#{@data_table.columns.keys.index(key)}]
            }|
        end
      end
      "[" + array.join(", ") + "]"
    end


  end
end

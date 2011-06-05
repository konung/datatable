module DataTable
  module Helper
    def concat_strings(a, b)
      a + " " + b
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
        $(function(){
          $('#data_table').dataTable(#{@data_table.javascript_options(h request.path).to_json})
        });
      </script>".html_safe
    end

    private

    def headings
      @data_table.columns.map do |column|
        "<th>#{human_column_name column[0]}</th>"
      end.join
    end

    def human_column_name(column)
      columns = column.split('.')
      [columns[0].singularize, columns[1]].map(&:humanize).map(&:titleize).join(" ")
    end




  end
end

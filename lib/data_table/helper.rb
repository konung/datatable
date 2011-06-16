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
        $(function(){
          $('#data_table').dataTable(#{javascript_options.to_json})
        });
      </script>".html_safe
    end

    private

    def headings
      @data_table.columns.map do |column|
        "<th>#{human_column_name column}</th>"
      end.join
    end

    def human_column_name(column)
      sql_name = column[0]
      custom_heading = column[2]
      return custom_heading if custom_heading

      columns = sql_name.split('.')
      [columns[0].singularize, columns[1]].map(&:humanize).map(&:titleize).join(" ")
    end

    def javascript_options
      defaults = {
        'sAjaxSource' => h(request.path),
        'sDom' => '<"H"lfr>t<"F"ip>',
        'iDisplayLength' => 10,
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers"
      }
      @data_table.javascript_options.merge(defaults)
    end



  end
end

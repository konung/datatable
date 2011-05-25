module DataTable
  module Helper
    def concat_strings(a, b)
      a + " " + b
    end

    def data_table_html
      <<-CONTENT.gsub(/^\s{6}/,"")
        <table class='datatable'>
          <thead>
            <tr>
      #{'<th></th>' * @data_table.columns.length}
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      CONTENT
    end

    # Private
    def _data_table_attributes_hash(params={})
      @data_table.config
      {
        'sAjaxSource' => @request.path,
        'sDom' => '<"H"lr>t<"F"ip>'
      }
    end

    def data_table_javascript
      # TODO: this will escape ampersands
      # ERB::Util.h('http://www.foo.com/ab/asdflkj?asdf=asdf&asdf=alsdf') => "http://www.foo.com/ab/asdflkj?asdf=asdf&amp;asdf=alsdf" 
      "<script>$(function(){$('#data_table').dataTable(#{@data_table.javascript_options(h request.path).to_json})</script>".html_safe
    end
  end
end

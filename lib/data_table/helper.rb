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

    def _attributes_hash
    end

    def data_table_javascript
    end

  end
end

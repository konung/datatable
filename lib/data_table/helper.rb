module DataTable
  module Helper
    def concat_strings(a, b)
      a + " " + b
    end

    def data_table_html
      <<-CONTENT.gsub(/^\s{6}/,"")
        <div class='datatable_container'>
          <table class='datatable'>
            <thead>
              <tr>
                #{'<th></th>' * @data_table.columns.length}
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      CONTENT
    end

  end
end

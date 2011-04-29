#require 'active_support/core_ext'
# Boat.reflect_on_all_associations.first.klass

module Datatable

  class Table

    # manage the options as a ruby hash
    def datatable_func_opts
      ActiveSupport::JSON.encode({})
    end
    

    # generate javascript
    def javascript
      <<-CONTENT.gsub(/^\s{8}/,"")
        <script type="text/javascript">
          $(document).ready(function() {
            $('.datatable').dataTable(#{ActiveSupport::JSON.encode(datatable_func_opts)});
          });
        </script>
      CONTENT
    end

    # generate html
    def html
      <<-CONTENT.gsub(/^\s{8}/,"")
        <div class='datatable_container'>
          <table class='datatable'>
            <thead>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      CONTENT
    end

    # convienence method to provide html+javascript
    def render
      (html + javascript).html_safe
    end


    #------------------------------------------------------------------------------------------------------------------
    #  type       name                  description
    #------------------------------------------------------------------------------------------------------------------
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
    #-----------------------------------------------------------------------------------------------------------------
    def to_json(params)
      ActiveSupport::JSON.encode({})
    end

  end
end

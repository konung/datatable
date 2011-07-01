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

          var oTable = $('#datatable').dataTable(#{javascript_options.to_json.gsub(/\"aocolumns_place_holder\"/, aocolumns_text)})


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
        'iDisplayLength' => 10,
        'bProcessing' => true,
        'bServerSide' => true,
        'sPaginationType' => "full_numbers",
        'aoColumns' => "aocolumns_place_holder"
      }
      defaults.merge(@datatable.javascript_options)
    end

    #  returns a ruby hash of
    def ruby_aocolumns
      result = []
      column_def_keys = %w[ asSorting bSearchable bSortable
                            bUseRendered bVisible fnRender iDataSort
                            mDataProp sClass sDefaultContent sName
                            sSortDataType sTitle sType sWidth link_to ]
      index = 0
      @datatable.columns.each_value do |column_hash|
        column_result = {}
        column_hash.each do |key,value|
          if column_def_keys.include?(key.to_s)
            column_result[key.to_s] = value
          end
        end

        # rewrite any link_to values as fnRender functions
        if column_result.include?('link_to')
          column_result['fnRender'] = %Q|function(oObj) { return replace('#{column_result['link_to']}', oObj.aData);}|
          column_result.delete('link_to')
        end

        if column_result.empty?
          result << nil
        else
          result << column_result
        end
      end
      result
    end

    def aocolumns_text
      outer = []
      ruby_aocolumns.each do |column|
        if column
          inner = []
          column.each do |key, value|
            inner << case key
              when 'fnRender'
                "\"#{key.to_s}\": #{value.to_json[1..-2]}"
              else
                "\"#{key.to_s}\": #{value.to_json}"
            end
          end
          outer << "{" + inner.join(", ") + "}"
        else
          outer << "null"
        end
      end
      '[' + outer.join(', ') + ']'
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

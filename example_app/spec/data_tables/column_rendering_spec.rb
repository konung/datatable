require 'spec_helper'



#
#describe 'links?' do
#   before do
#
#     class AR < DataTable::Base
#     class AR < DataTable::Base
#       set_model Order
#
#       column :memo
#       column :order_number do
#         link_to nil, edit_order_path(:id)
#       end
#       column :id
#
#       column do
#         link_to 'Edit', edit_order_path('{{id}}')
#       end
#
#
#       def link_to(*args)
#         colunms[:auto] = {:link_to => link_to(args)}
#       end
#
#
#       column do
#         link_to 'Delete', order_path(:id), :method => 'delete', :confirm => 'Are you sure?'
#       end
#
#     end
#
#   end
#
#   it 'links the order number to the order' do
#     '<a href="/orders/' + oObj.aData[0] + '> '+ oObj.aData[1] + '</a>'
#
#   end
#end
#
#
#



##
## # $(document).ready(function() {
## # 	$('#example').dataTable( {
## # 		"aoColumnDefs": [
## # 			{
## #        "link" = 'w/e the backend gives as the link <aref',
##
## # 				"fnRender": function ( oObj ) {
##
##           <a href=\"/orders/{{0}}\">{{0}}</a>
##           [[0,11], [0,18]]
##           [oObj[0], oObj[0]]

##           replacements(
## #          replacements = {
## #            '{{id}}': oObj.aData[3],
## #            '{{another_id}}': oObj.aData[5]
## #          }
##


## #          return link("#{link_to}", replacements);
## # 				},
## # 				"aTargets": [ 0 ]
## # 			},
## # 			{ "bVisible": false,  "aTargets": [ 3 ] },
## # 			{ "sClass": "center", "aTargets": [ 4 ] }
## # 		]
## # 	} );
## # } );
## #
## #  javascript helper will need:
## #
## #  The link
## <a href='/posts/{{post_id}/comments/{{comment_id}}'>Edit</a>
## <a href='/posts/{{post_id}/comments/{{comment_id}}'>{{post_title}}</a>
##
## #
## #  a hash where the keys are strings to replace and the values are the index of the column that should replace the key
## #
##
## it 'should give the javascript helper the right stuff' do
##
##   data_table.info_for_helper
##   make sure it getst the right link
##   make sure it sends the right reeplacements
##
##
## end

class Example2 < Datatable::Base

  set_model Order

  column :id, :type => :integer, :sTitle => "Id"
  column :memo

  option('individual_column_searching', true)
  option('sDom', '<"clear"><"H"Trf>t<"F"i>')
  option('bScrollInfinite', true)
  option('bScrollCollapse', true)
  option('sScrollY', '200px')
end

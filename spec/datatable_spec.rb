require 'spec_helper'
require 'datatable'

describe DataTable do

  it 'should echo when the echo is provided' do
    echo = rand(239823)
    params = {'sEcho' => echo }
    DataTable.new(params).json['sEcho'].should == echo
  end

  it 'should echo when there is no echo' do
    DataTable.new.json['sEcho'].should == -1
  end

  it 'should return an empty array if there are no records' do
    DataTable.new.json['aaData'].should == []
  end

  it 'should return the number of records' do
    DataTable.new.json['iTotalRecords'].should == 0
    DataTable.new.json['iTotalDisplayRecords'].should == 0
  end

  # it 'should give basic results' do
  #   params = {"bSortable_0"=>"true", "iColumns"=>"4", "bSortable_1"=>"true", "iSortCol_0"=>"0", "bSearchable_0"=>"true", "sSearch_0"=>"", "bSortable_2"=>"true", "bSearchable_1"=>"true", "sSearch_1"=>"", "bRegex_0"=>"false", "iDisplayLength"=>"10", "bSortable_3"=>"true", "bSearchable_2"=>"true", "sSearch_2"=>"", "bRegex_1"=>"false", "sSortDir_0"=>"DESC", "bSearchable_3"=>"true", "sSearch_3"=>"", "bRegex_2"=>"false", "sEcho"=>"1", "iSortingCols"=>"1", "bRegex_3"=>"false", "sSearch"=>"", "_"=>"1304112480707", "bRegex"=>"false", "iDisplayStart"=>"0", "sColumns"=>""}

  #   DataTable.query(params).json.should == {
  #     'sEcho' =>  params[:sEcho],
  #     'iTotalRecords' => Order.count,
  #     'iTotalDisplayRecords' => Order.count,
  #     'aaData' => data
  #   }
  # end

end


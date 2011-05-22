require 'spec_helper'
require 'datatable'

describe DataTable::DataTable do

  it 'should echo when the echo is provided' do
    echo = rand(239823)
    params = {'sEcho' => echo }
    DataTable::DataTable.new(params).json['sEcho'].should == echo
  end

  it 'should echo when there is no echo' do
    DataTable::DataTable.new.json['sEcho'].should == -1
  end

  it 'should return an empty array if there are no records' do
    DataTable::DataTable.new.json['aaData'].should == []
  end

  it 'should return the number of records' do
    DataTable::DataTable.new.json['iTotalRecords'].should == 0
    DataTable::DataTable.new.json['iTotalDisplayRecords'].should == 0
  end

  it 'should deal w/ pagination' do
    params = {'iDisplayLength' => 10, 'iDisplayStart' => 20 }
    DataTable::DataTable.query(params).json.should == {
      'iTotalRecords' => 320,
      'iTotalDisplayRecords' => 320,
      'aaData' => [[] * 320]
    }
  end

  # have to pass params to something
  # DataTable::DataTable.new(Model) do
  #  column :foo, :asc, :as => 'bar'
  # end

  # it 'should give basic results' do
  #   params = {"bSortable_0"=>"true", "iColumns"=>"4", "bSortable_1"=>"true", "iSortCol_0"=>"0", "bSearchable_0"=>"true", "sSearch_0"=>"", "bSortable_2"=>"true", "bSearchable_1"=>"true", "sSearch_1"=>"", "bRegex_0"=>"false", "iDisplayLength"=>"10", "bSortable_3"=>"true", "bSearchable_2"=>"true", "sSearch_2"=>"", "bRegex_1"=>"false", "sSortDir_0"=>"DESC", "bSearchable_3"=>"true", "sSearch_3"=>"", "bRegex_2"=>"false", "sEcho"=>"1", "iSortingCols"=>"1", "bRegex_3"=>"false", "sSearch"=>"", "_"=>"1304112480707", "bRegex"=>"false", "iDisplayStart"=>"0", "sColumns"=>""}

  #   DataTable::DataTable.query(params).json.should == {
  #     'sEcho' =>  params[:sEcho],
  #     'iTotalRecords' => Order.count,
  #     'iTotalDisplayRecords' => Order.count,
  #     'aaData' => data
  #   }
  # end

end


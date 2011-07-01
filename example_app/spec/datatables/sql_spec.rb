require 'spec_helper'

describe 'Use raw sql' do

  before do
    Object.send(:remove_const, :T) rescue nil
    class T < Datatable::Base
      sql <<-SQL
        SELECT
          sales_reps.id,
          first_name,
          last_name
        FROM
          sales_reps
      SQL
      columns(
        {'sales_reps.id' => {:type => :integer}},
        {'sales_reps.first_name' => {:type => :string}},
        {'sales_reps.last_name' => {:type => :string}}
      )
    end

    @sales_reps = [
        Factory(:sales_rep), Factory(:sales_rep),
        Factory(:sales_rep), Factory(:sales_rep) ]

    30.times do
      Factory(:customer, :sales_rep => @sales_reps[rand(4)])
    end

    @params = {
      "iColumns" =>	4,
      "bSearchable_0" => true,
      "bSearchable_1" => true,
      "bSearchable_2" => true,
      "bSortable_0" => true,
      "bSortable_1" => true,
      "bSortable_2" => true,
      "sSearch_0" => nil,
      "sSearch_1" => nil,
      "sSearch_2" => nil,
      "sSearch" => nil   }
  end

  it 'should return the correct number of records' do
    T.query(@params).to_json['aaData'].length.should == @sales_reps.length
  end

  it 'should return the records' do
    row = [@sales_reps[0].id.to_s, @sales_reps[0].first_name, @sales_reps[0].last_name]
    T.query(@params).to_json['aaData'][0].should  == row
  end

  it 'should provide the first page' do
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2

    row = [@sales_reps[0].id.to_s, @sales_reps[0].first_name, @sales_reps[0].last_name]
    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['aaData'].length.should == 2
    T.query(@params).to_json['aaData'][0].should == row
  end

  it 'should provide the second page' do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    row = [@sales_reps[2].id.to_s, @sales_reps[2].first_name, @sales_reps[2].last_name]
    T.query(@params).to_json['iTotalRecords'].should == 2
    T.query(@params).to_json['aaData'].length.should == 2
    T.query(@params).to_json['aaData'][0].should == row
  end

end



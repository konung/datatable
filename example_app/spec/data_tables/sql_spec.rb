require 'spec_helper'

describe 'Use raw sql' do

  before do

    class SalesRepCustomers < DataTable::Base


      # count <<-SQL
      #   SELECT 
      #     count(*)
      #   FROM
      #     sales_reps
      #   LEFT OUTER JOIN 
      #     (SELECT 
      #        customers.sales_rep_id, 
      #        count(*) AS value 
      #      FROM customers 
      #      GROUP BY customers.sales_rep_id)
      #   AS 
      #     customer_counts
      #   ON
      #     customer_counts.sales_rep_id = sales_reps.id

      # SQL


      sql <<-SQL
        SELECT 
          sales_reps.id,
          first_name AS fullname,
      #{'sales_reps.created_at,' if ActiveRecord::Base.connection.class.to_s =~ /mysql/i }
      #{"to_char(sales_reps.created_at, 'YYYY-MM-DD HH24:MI:SS' )," if ActiveRecord::Base.connection.class.to_s =~ /post/i }
          COALESCE(customer_counts.value,0) AS count
        FROM 
          sales_reps
        LEFT OUTER JOIN 
          (SELECT 
             customers.sales_rep_id, 
             count(*) AS value 
           FROM customers 
           GROUP BY customers.sales_rep_id)
        AS 
          customer_counts
        ON
          customer_counts.sales_rep_id = sales_reps.id
      SQL

      columns(
        {'sales_reps.id' => {:type => :integer}},
        {'fullname' => {:type => :string}},
        {'sales_reps.created_at' => {:type => :datetime }},
        {'count' => {:type => :integer }}
      )

    end


    @sales_reps = [Factory(:sales_rep), Factory(:sales_rep),
      Factory(:sales_rep), Factory(:sales_rep)]

    30.times do
      Factory(:customer, :sales_rep => @sales_reps[rand(4)])
    end

    @params = {
      "iColumns" =>	4,
      "bSearchable_0" => true,
      "bSearchable_1" => true,
      "bSearchable_2" => true,
      "bSearchable_3" => true,
      "bSortable_0" => true,
      "bSortable_1" => true,
      "bSortable_2" => true,
      "bSortable_3" => true,
      "sSearch_0" => nil,
      "sSearch_1" => nil,
      "sSearch_2" => nil,
      "sSearch_3" => nil,
      "sSearch" => nil   }
  end

  it 'should return the correct number of records' do
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == @sales_reps.length
  end

  it 'should return the records' do
    first_row = [@sales_reps[0].id, @sales_reps[0].first_name, @sales_reps[0].created_at.strftime("%Y-%m-%d %R:%S"), @sales_reps[0].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['aaData'][0].should  == first_row
  end

  it 'should provide the first page' do
    @params['iDisplayStart'] = 0
    @params['iDisplayLength'] = 2

    row = [@sales_reps[0].id, @sales_reps[0].first_name, @sales_reps[0].created_at.strftime("%Y-%m-%d %R:%S"), @sales_reps[0].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['iTotalRecords'].should == 2
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == 2
    SalesRepCustomers.query(@params).to_json['aaData'][0].should == row
  end

  it 'should provide the second page' do
    @params['iDisplayStart'] = 2
    @params['iDisplayLength'] = 2

    row = [@sales_reps[2].id, @sales_reps[2].first_name, @sales_reps[2].created_at.strftime("%Y-%m-%d %R:%S"), @sales_reps[2].customers.count].map(&:to_s)
    SalesRepCustomers.query(@params).to_json['iTotalRecords'].should == 2
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == 2
    SalesRepCustomers.query(@params).to_json['aaData'][0].should == row
  end

end



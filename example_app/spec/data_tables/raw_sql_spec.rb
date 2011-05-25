require 'spec_helper'

describe 'Use raw sql' do

  before do

    class SalesRepCustomers < DataTable::Base
      set_model SalesRep

      sql <<-SQL
        SELECT 
          sales_reps.id,
          CONCAT(first_name, last_name) AS fullname,
          sales_reps.created_at,
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
    end

    @sales_reps = [Factory(:sales_rep), Factory(:sales_rep)]
    10.times do
      Factory(:customer, :sales_rep => @sales_reps[rand(2)])
    end

    @params = {}
  end

  it 'should return the correct number of records' do
    SalesRepCustomers.query(@params).to_json['aaData'].length.should == 2
  end

  it 'should return the records' do
    first_row = [@sales_reps[0].id, @sales_reps[0].first_name + @sales_reps[0].last_name, @sales_reps[0].created_at, @sales_reps[0].customers.count]
    SalesRepCustomers.query(@params).to_json['aaData'][0].should  == first_row
  end
  it 'should paginate' 

  it 'should allow ordering by arbitrary columns'



end

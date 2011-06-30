require 'spec_helper'

describe 'sql kitchen sink' do
  before do
    class T

      count <<-SQL
        SELECT
          count(*)
        FROM
          orders
        JOIN
          customers
        ON
          orders.customer_id = customers.id
      SQL

      sql <<-SQL
        SELECT
          orders.id,
          orders.order_number,
          TRIM(BOTH FROM COALESCE(customers.first_name, ' ') || ' ' || COALESCE(customers.last_name, ' ')) AS sales_rep_name
          NULL
          NULL
        FROM
          orders
        JOIN
          customers
        ON
          orders.customer_id = customers.id
      SQL

      where <<-SQL
        customers.id IN {{customer_ids}}
      SQL

      columns([
        { :table      => 'orders',
          :column     => 'id',
          :visible    => false,
          :type       => :integer,
          :width      => '100px'
        },

        { :table      => 'orders',
          :column     => 'order_number',
          :header     => 'Order No.',
          :type       => :string,
          :width      => '100px',
          :class      => 'first'
        },

        { :table      => nil,
          :column     => 'sales_rep_name',
          :header     => 'Sales Rep',
          :type       => :string,
          :search_sql => 'sales_reps.firstname iLIKE {{2}} OR sales_reps.last_name iLIKE {{2}}',
          :width      => '100px'
        },

        { :table       => nil,
          :column      => nil,
          :sortable    => false,
          :searchable  => false,
          :render      => %Q|
                            function(oObj){
                              if(oObj.aData){
                                return "YES"
                              else
                                return "NO"
                              }
                            }
                          |,
          :width       => '100px'
        },

        { :table       => nil,
          :column      => nil,
          :sortable    => false,
          :searchable  => false,
          :link_to     => link_to('view', accent_color_path('{{0}}')),
          :width       => '100px',
          :class      => 'last'
        }
      ])

      option('sDom', '<"H"lrf>t<"F"ip>')
      option('individual_column_searching', true)

    end
  end

  it "require table and column name to be set" do
    # don't use them as key because they may not exist in the query'
    pending
  end

  it "honor bVisible per column" do
    # include data but render nothing
    pending
  end

  uit "should support per column widths" do
    # necessary if you don't use automatic column widths'
    pending
  end

  it "should be able to set class of cells in column" do
    # needed for css
    pending
  end

  it "should be able to set bSortable per column" do
    pending
  end

  it "should be able to set the default sort direction" do
    # most views will have an initially defined sort order
    pending
  end

  it "should be able to set bSearcchable per column" do
    # can't include anything in SQL not even wild card search'
    pending
  end

  it "should support sDefaultContent" do
    # useful for turning NULL into "unknown"
    pending
  end

  it "should be able to set a fnRender method" do
    # useful for turning bool into "yes" or "no" for example
    pending
  end

  it "should support where clause in the static definition" do
    pending
  end

  it "needs to support overriding the percolumn filtering logic" do
    # columns created with AS can't appear in where clause so we
    # have to define how to handle them.  If not searchable ignore
    # this column
    pending
  end

  it "should barf when iColumn param is not set on query" do
    # it's useful to browse the json output so it's nice to have
    # it correctly render the default page zero even though none
    # of the datatable params are set
    pending
  end



end



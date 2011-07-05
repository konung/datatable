Datatable
=========

This is a [Rails 3.0](http://rubyonrails.org) plugin that provides server-side processing for the [Datatables](http://datatables.net) javascript library.  The screenshot below
contains an example with global search, per column search, infinite scrolling and the optional table tools plugin installed.


![Alt text](https://github.com/logic-refinery/datatable/raw/master/images/datatable_screenshot.png "optional title") 

Introduction
============

This gem is in an early stage of development.  It's likely the code base will experience significant churn in the next few releases as we
search for the best way deliver the desired functionality.  If you think this may be a problem you should most likely avoid using it for now.
On the other hand if you're not afraid of diving into the code to help us improve it we will certiainly do what we can to make sure it works
for you in return.

Setup
======

Because of the fast moving nature of this project for the time being I recomend using bundler and pulling from git.  If you
intend to deploy an application using this gem I'd recomend locking your dependency to a specific well tested commit.

Add the following to you Gemfile

```ruby
  gem "datatable", :git => "git://github.com/logic-refinery/datatable.git" :ref => "500a5f"
```

Then run bundle install

```sh
  bundle install datatable
```

Then run the generator to create the javascript files and code templates

```sh
  rails generate datatable:install
```

The generator will have added some javascript files to your public/javascript folder that you will and to include after JQuery

```erb
  <%= javascript_include_tag "jquery.dataTables" %>
```

If you want to use the example stylesheets you will need to include that also.

```erb
  <%= stylesheet_link_tag "demo_page", "jquery-ui-1.7.2.custom.css", "jquery-ui-1.7.2.custom" %>
```

Usage
=====

Imagine that you have an 'Order' that belongs to a 'Customer' and has many 'Item'

In app/controllers/orders_controller.rb you would add something like this:

```ruby
  def index
    @datatable = OrdersIndex
    respond_to do |format|
      format.html
      format.js { render :json => @datatable.query(params).to_json }
    end
  end
```

In app/views/orders/index.html.erb you would add something like this:

```erb
  <%= datatable %>
```

In app/datatables/orders_index.rb you would need to define the datatable.  In the future this hopefully will be a DSL that's easier to use.
Right now it mostly just exposes the internal datastructures so the necessary information can be defined. See the [wiki](https://github.com/logic-refinery/datatable/wiki) 
for more detailed information.

```ruby
  class OrdersIndex < Datatable::Base
    sql <<-SQL
      SELECT
      orders.id,
      orders.order_number,
      customers.first_name,
      customers.last_name,
      orders.memo
    FROM
      orders
    JOIN
      customers ON customers.id = orders.customer_id
    SQL

    columns(
      {"orders.id" => {:type => :integer, :heading => "Id", :sWidth => '50px'}},
      {"orders.order_number" => {:type => :integer, :link_to => link_to('{{1}}', order_path('{{0}}')),:heading => 'Order Number', :sWidth => '125px' }},
      {"customers.first_name" => {:type => :string, :link_to => link_to('{{2}}', order_path('{{0}}')),:sWidth => '200px' }},
      {"customers.last_name" => {:type => :string,:sWidth => '200px'}},
      {"orders.memo" => {:type => :string }})

    option('bJQueryUI', true)
    option('individual_column_searching', true)
    option('sDom', '<"clear"><"H"Trf>t<"F"i>')
    option('bScrollInfinite', true)
    option('bScrollCollapse', true)
    option('sScrollY', '200px')
  end
```

In app/config/initializers/datatable.rb you would add something like this:

```ruby
  Datatable::Base.config do |config|
    config.style = true
    config.sql_like = 'ILIKE'
    config.table_tools = true
  end
```

Limitations
==========

 *  It only supports MySQL and PostgreSLQ through ActiveRecord.

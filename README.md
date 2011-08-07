WARNING!!!
==========

This gem is not ready for prime-time but if you're feeling adventurous read on....

It's likely the code base will experience significant churn in the next few releases as we search for the best way deliver the desired 
functionality.  If you think this may be a problem you should most likely avoid using this gem for now.  On the other hand if you're not
afraid of diving into the code to help us improve it we will certiainly do what we can to make sure it works for you in return.

Datatable
=========

This is a [Rails 3.0](http://rubyonrails.org) plugin that provides server-side processing for the [Datatables](http://datatables.net) javascript library.  The screenshot below
contains an example with global search, per column search, infinite scrolling and the optional table tools plugin installed using the jquery ui theme 'smoothness'.


![Alt text](https://github.com/logic-refinery/datatable/raw/master/images/datatable_screenshot.png "optional title") 



Introduction
============

This library is not intended to create a zero configuration admin style interface to your data.  It's intended to provide a fairly complete
and flexible interface into your data for the datatables javascript library.  It will require a moderate amount of configuration to define 
exactly what you want to see, how it should be displayed and the relationship between that view and the database schema.  Hopefully though
we can make it so all of that configuration happens in one place with a minimal amount of redundancy.

Setup
======

Add the following to you Gemfile

```ruby
  gem "datatable", "~>0.2pre2"
```

Then run bundle install

```sh
  bundle install datatable
```

Then run the generator to create the javascript files and code templates

```sh
  rails generate datatable:install
```

The generator will have added some files in public/datatable.  At a minimum you need to include the datatables
javascript after jquery.  A typical rails applicaiton layout would look something like this.

```erb
  <%= javascript_include_tag :defaults %>
  <%= datatable_javascript %>
```

If you want to use the jquery ui be sure to include those style sheets.

```erb
  <%= stylesheet_link_tag :all %>
  <%= stylesheet_link_tag 'smoothness/jquery-ui-1.8.14.custom' %>
```

The generator created a template in app/config/initializers/datatable.rb that you can modify as needed.

```ruby
  Datatable::Base.config do |config|
    config.style = true
    config.sql_like = 'ILIKE'
    config.table_tools = true
  end
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

Documentation
=============

[wiki](https://github.com/logic-refinery/datatable/wiki)

Limitations
==========

 *  It only supports MySQL and PostgreSLQ through ActiveRecord.

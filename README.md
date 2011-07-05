Datatable
=========

This is a [Rails 3.0](http://rubyonrails.org) plugin that provides an interface to the [Datatables](http://datatables.net) javascript library.  

Introduction
============

This gem is in an early stage of development.  It's likely the code base will experience significant churn in the next few releases as we
search for the best way deliver the desired functionality.  If you think this may be a problem you should most likely avoid using this
gem for production use.  On the other hand if you're not afraid of diving into the code to help us solve a problem we will certiainly do 
what we can do help you in return.


Setup
======

Because of the fast moving nature of this project for the time being I recomend using bundler and pulling from the git repository.

Add the following to you Gemfile

```ruby
  gem "datatable", :git => "git://github.com/logic-refinery/datatable.git"
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

If you wnat to use the example stylesheets you will need to include that also.
```erb
  <%= stylesheet_link_tag "demo_page", "jquery-ui-1.7.2.custom.css", "jquery-ui-1.7.2.custom" %>
```


----------------------------
See the [wiki](https://github.com/logic-refinery/datatable/wiki) for more detailed information.

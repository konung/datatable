module Datatable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../../../vendor/datatable", __FILE__)

      def copy_assets
        say_status("copying", "dataTable assets", :green)

        directory 'media/images', 'public/datatable/images'
        directory 'media/css', 'public/datatable/css'
        directory 'media/js', 'public/datatable/js'
      end


      def copy_initializer
        template "../../lib/generators/templates/datatable_initializer.rb", "config/initializers/datatable.rb"
      end

      def show_next_steps

        puts "\n" * 3
        puts "-" * 60
        puts "\n" * 3

        puts <<-HELPFUL_INSTRUCTIONS
        
Next Steps:

0. You must be using and including JQuery. 

  # Gemfile

  gem 'jquery-rails'

  Then bundle and run rails g jquery:install

1. Put the asset tags into your layouts:

  # app/views/layouts/admin.html.erb

  <%= stylesheet_link_tag '/datatable/css/demo_table.css' %>

  <%= javascript_include_tag :defaults %>

  <%# The datatable javascript tag must come after you require jquery! %>
  <%= javascript_include_datatable %> 

2. Create a Datatable. We suggest naming it Controller#Action.

  rails g datatable:new UsersIndex
        HELPFUL_INSTRUCTIONS
        puts "\n" * 5

      end

    end
  end
end

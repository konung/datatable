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

        puts <<-HELPFUL_INSTRUCTIONS
        Next Steps

          1. Put in the asset tags

          2. rails g datatable your_table
        HELPFUL_INSTRUCTIONS

      end

    end
  end
end

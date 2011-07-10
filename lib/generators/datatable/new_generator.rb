module Datatable
  module Generators

    class NewGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)

      def create_datatable_file
        template "datatable.rb", "app/datatables/#{file_name}.rb"
      end

      def show_next_steps
        puts "\n" * 2

        puts <<-HELPFUL_INSTRUCTIONS
   Next Steps:

   0. Setup the controller

     # app/controllers/your_controller.rb
     def index
       @datatable = #{class_name}
       respond_to do |format|
         format.html 
         format.js { render :json => @datatable.query(params).to_json }
       end
     end

   1. Setup the view

     # app/views/your_controller/your_view.html.erb

     <%= datatable %>

   2. Enjoy.

    HELPFUL_INSTRUCTIONS
    puts "\n" * 3

      end


    end

  end
end


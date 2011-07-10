module Datatable
  module Generators

    class NewGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)

      def create_datatable_file
        template "datatable.rb", "app/datatables/#{file_name}.rb"
      end
    end

  end
end


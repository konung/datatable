require 'data_table/data_table_helper'
module DataTable
  class Railtie < Rails::Railtie
    initializer "data_table.data_table_helper" do
      ActionView::Base.send :include, DataTableHelper
    end
  end
end
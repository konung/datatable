require 'data_table/helper'
require 'rails'

module DataTable
  class Railtie < ::Rails::Railtie
    initializer "data_table.helper" do
      ActionView::Base.send :include, DataTable::Helper
    end
  end
end

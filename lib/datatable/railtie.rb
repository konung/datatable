require 'datatable/helper'
require 'rails'

module Datatable
  class Railtie < ::Rails::Railtie
    initializer "datatable.helper" do
      ActionView::Base.send :include, Datatable::Helper
    end
  end
end

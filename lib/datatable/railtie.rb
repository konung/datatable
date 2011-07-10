require 'datatable/helper'
require 'rails'

module Datatable
  class Railtie < ::Rails::Railtie

    initializer 'datatable.load_later' do
      datatable_path = Rails.application.config.eager_load_paths.grep(/app\/datatable/)
      Rails.application.config.eager_load_paths -= datatable_path
    end

    initializer "datatable.helper" do
      ActionView::Base.send :include, Datatable::Helper
    end

  end
end

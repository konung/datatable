#require 'active_support/core_ext'

# Boat.reflect_on_all_associations.first.klass

module Datatable

  # name    - is this a label? a symbol to reference the column?
  # select  - what to use as the select in the order by
  # render  - call back to render the content
  # type    - data table
  class Column
    attr_accessor :name, :select, :render, :type
  end
end
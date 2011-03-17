module Datatable

  # name    - is this a label? a symbol to reference the column?
  # select  - what to use as the select in the order by
  # render  - call back to render the content
  # type    - data table
  class Column
    attr_reader :name, :datatable


    # would it make more sense to pass the active record model
    # to the column instead of the datatable?
    #
    def initialize(datatable, name, accessor=nil)
      @datatable = datatable
      @accessor = accessor
      @name = name
    end

    def accessor
      if @accessor
        @accessor
      else
        if @datatable.model_column_names.include?(@name.to_s)
          "#{@name}"
        else
          raise "#{@name} is not an attribute of #{@datatable.model.class}"
        end
      end
    end

    def render(o)
      o.send(accessor)
    end

  end
end





#      #
#      # SELECT
#      #
#      if select
#        # a user supplied select was provided
#        if qualified_selector?(select)
#          selector_table, selector_column = select.split(".")
#          unless selector_table == @table
#            # add the selectors table to include since
#            # it's not the current models table.
#            @include << selector_table
#          end
#          result.select = "#{@model.reflect_on_association(selector_table.to_sym).table_name}.#{selector_column}"
#        else
#          # it's an unqualifed selector
#          if @model.column_names.include?(select.to_s)
#            result.select = "#{@table_name}.#{select}"
#          else
#            raise "'#{@table_name}' does not include column '#{select}'"
#          end
#        end
#      else
#        # no user supplied select so determine it from name
#        if @model.column_names.include?(name.to_s)
#            result.select =  (select ? select : "#{@table}.#{name}")
#        else
#          result.select = nil
#        end
#      end



#      #
#      # RENDER
#      #
#      if render.nil?
#        #
#        # if no render is supplied then assume then assume
#        # that it's the attribute name on the current model
#        #
#        result.render = lambda{|o| o.send(name.to_s)}
#      elsif render.kind_of?(Proc)
#        #
#        # if they supplied a proc then simply save the proc
#        # in render it will be used later
#        #
#        result.render = render
#      else
#        #
#        # if they supplied anything else just save it's string
#        # int render
#        #
#        result.render = render.to_s
#      end
#
#      #
#      # TYPE is unused right now
#      #
#      result.type =  (type ? render : :integer)


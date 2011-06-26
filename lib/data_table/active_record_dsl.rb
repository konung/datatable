module DataTable
  module ActiveRecordDSL

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def relation
        @relation
      end

      def set_model(model)
        @model = model
        @relation = model
      end

      def current_model
        @inner_model || @model
      end

      def column(c, options={})

        raise "set_model not called on #{self.name}" unless @model

        @columns ||= ActiveSupport::OrderedHash.new

        column_hash = {}
        column_hash[:type] = current_model.columns.detect{ |col| col.name == c.to_s}.type
        column_hash[:link_to] = options[:link_to]

        @columns["#{current_model.table_name}.#{c}"] = column_hash

        @relation= @relation.select(current_model.arel_table[c])
      end

      # TODO: Change to joins to match arel
      def join(association, &block)

        @inner_model = current_model.reflect_on_association(association).klass
        @relation = @relation.joins(association)
        instance_eval(&block) if block_given?
        @inner_model = nil
      end

    end

  end
end

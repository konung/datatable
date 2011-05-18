# 1. data table subclass is initialized
#   class methods are going to be called on the class instance, and the class will store table data
#
# 2. instantiate an instance of the data table subclass ( OrdersIndex.new)
#
# 3. query the instance w/ pagination and sorting params
#    a query gets executed w/ params -> ARel
#    results get stored  -> AR
#    results get passed back as json
class DataTable
  # include SQLGenerator
  # include ParamsParser

  attr_accessor :echo
  attr_accessor :data
  attr_accessor :total_count
  attr_accessor :displayed_count
  attr_accessor :records

  def self.relation
    @relation
  end

  def self.klass
    @klass
  end

  def self.current_klass
    @inner_klass || @klass
  end

  def self.column(c)
    @relation= @relation.select(current_klass.arel_table[c])
  end

  def self.join(association, &block)
    @inner_klass = current_klass.reflect_on_association(association).klass
    @relation = @relation.joins(association)
    instance_eval(&block) if block_given?
    @inner_klass = nil
  end

  def self.set_model(klass)
    @klass = klass
    @relation = klass
  end

  def self.query(params)
    datatable = new(params)
    datatable.query
    datatable
  end

  def initialize(params={})
    @echo = (params['sEcho'] || -1).to_i
    @displayed_count = 0
    @total_count = 0
    @records = []
  end

  def some_method(a)
    [ '', '', '' ]
  end

  def as_json
    {
      'sEcho' => echo,
      'aaData' => records,
      'iTotalRecords' => total_count,
      'iTotalDisplayRecords' => records.length,
    }
  end

  def query
    @records = self.class.klass.connection.select_rows(sql)
    @total_count = @records.count
    self
  end

  def sql
    self.class.relation.to_sql
  end

end

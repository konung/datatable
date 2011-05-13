class DataTable
  # include SQLGenerator
  # include ParamsParser

  attr_accessor :echo
  attr_accessor :data
  attr_accessor :total_count
  attr_accessor :displayed_count

  def self.relation
    @@relation
  end

  def self.column(c)
    @@inner_class ||= nil
    if @@inner_class
      table = Arel::Table.new(@@inner_class.to_s.pluralize)
      @@relation = @@relation.select(table[c])
    else
      @@relation = @@relation.select(c)
    end
  end

  def self.join(association, &block)
    @@inner_class = association
    @@relation = @@relation.joins(association)
    instance_eval(&block) if block_given?
    @@inner_class = nil
  end

  def self.set_model(klass)
    @@klass = klass
    @@relation = klass #Arel::Table.new(klass.table_name)
  end

  # 1. data table subclass is initialized 
  #   class methods are going to be called on the class instance, and the class will store table data
  #
  # 2. instantiate an instance of the data table subclass ( OrdersIndex.new)
  #
  # 3. query the instance w/ pagination and sorting params
  #    a query gets executed w/ params -> ARel
  #    results get stored  -> AR
  #    results get passed back as json



  def initialize(params={})
    @echo = (params['sEcho'] || -1).to_i
    @data = []
    @displayed_count = 0
    @total_count = 0
  end

  def json
    {
      'sEcho' => echo,
      'aaData' => data,
      'iTotalRecords' => total_count,
      'iTotalDisplayRecords' => displayed_count,
      'aaRecords' => []
    }
  end

  def query(params)
    self
  end

  def sql
    @@relation.to_sql
  end


end

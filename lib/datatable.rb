class DataTable

  attr_accessor :echo
  attr_accessor :data
  attr_accessor :total_count
  attr_accessor :displayed_count

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
      'iTotalDisplayRecords' => displayed_count
    }
  end

end

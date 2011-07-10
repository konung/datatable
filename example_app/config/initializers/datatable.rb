Datatable::Base.config do |config|
  config.style = true # Wraps it in a div when not using jquery ui
  config.jquery_ui = false
  config.sql_like = 'ILIKE'
  config.table_tools = false
end


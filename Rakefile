require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'

desc 'default: run all examples'
task :default => :spec

desc "run all examples"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.verbose = true
  task.rspec_opts = ["--color", "--format=doc"]
end

desc 'Generate documentation for the datatable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Datatable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end




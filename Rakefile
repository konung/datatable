require 'bundler'
Bundler.require :default, :test

require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'rake/clean'

CLOBBER.include('*.gem')

desc 'rake spec'
task :default => :spec

desc "run all examples"
RSpec::Core::RakeTask.new(:spec) do |task|
  task.verbose = true
  task.rspec_opts = ["--color", "--format=doc"]
end

desc 'Generate documentation for the datatable plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'docs'
  rdoc.title    = 'Datatable'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "build gem"
task :build do
  system "gem build datatable.gemspec"
end

desc "publish gem"
task :release => :build do
  system "gem push bundler-#{Datatable::VERSION}"
end

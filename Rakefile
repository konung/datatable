require 'bundler'
Bundler.require :default, :test

require 'rake'
require 'rdoc/task'
require 'rspec/core/rake_task'
require 'rake/clean'

CLOBBER.include('*.gem')

desc 'rake spec'
task :default => :spec

task :spec do
   puts 'The specs are in the example_app folder. Run rake spec in that directory'
end

desc 'Generate documentation for the datatable plugin.'
Rake::RDocTask.new(:rdoc => 'rdoc', :clobber_rdoc => "rdoc:clobber", :rerdoc => 'rdoc:force') do |rdoc|
  rdoc.rdoc_dir = 'docs'
  rdoc.title    = 'Datatable'
  rdoc.options  << "--all"
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "build gem"
task :build do
  system "gem build datatable.gemspec"
end

desc "publish gem"
task :release => :build do
  system "gem push bundler-#{DataTable::VERSION::STRING}"
end

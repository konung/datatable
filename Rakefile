require 'rake/clean'
require 'rdoc/task'

CLOBBER.include('*.gem')

task :default do
  puts 'Run "rake spec" in the "example_app" directory to perform tests.'
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
  system "gem push datatable-#{Datatable::VERSION}.gem"
end

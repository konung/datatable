require 'rake/clean'
require 'rdoc/task'
require 'fileutils'

include FileUtils

ROOT_DIR = File.dirname(__FILE__)

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
  system "gem push bundler-#{Datatable::VERSION::STRING}"
end


namespace :vendor do 
  desc "update vendor/datatable"
  task :update do 
    repository = File.join(ROOT_DIR, %w[vendor datatable])
    rm_rf repository
    `git clone git://github.com/DataTables/DataTables.git #{repository}`
    tags = `cd download && git tag`
    release = tags.grep(/RELEASE/).sort{|a,b| b <=> a }.first
    `cd download && git checkout #{release}`
    rm_rf File.join(repository, 'examples')
    rm_rf File.join(repository, %w[media unit_testing])
    rm_rf File.join(repository, %w[media images], "Sorting icons.psd")
    rm_rf File.join(repository, %w[media css demo_page.css])
  end
end



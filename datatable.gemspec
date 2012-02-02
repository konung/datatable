# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "datatable/version"

Gem::Specification.new do |s|
  s.name        = "datatable"
  s.version     = Datatable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Greenly", 'Mischa Fierer']
  s.email       = ["michaelgreenly@logic-refinery.com"]
  s.homepage    = "https://github.com/logic-refinery/datatable"
  s.summary     = %q{A Rails plugin for the jquery.datatables library}
  s.description = %q{A Rails plugin for the jquery.datatables library}
  s.add_dependency('rails', '> 3.0', '< 4.0' )

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

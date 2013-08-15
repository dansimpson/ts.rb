$:.push File.expand_path("../lib", __FILE__)
require "ts"

spec = Gem::Specification.new do |s|
  s.name = "ts"
  s.version = TS::Version
  s.date = "2013-08-14"
  s.summary = "Utility gem for numeric time series data"
  s.email = "dan.simpson@gmail.com"
  s.homepage = "https://github.com/dansimpson/ts.rb"
  s.description = "Utilities for numeric time series data"
  s.has_rdoc = true
  
  s.authors = ["Dan Simpson"]

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

end
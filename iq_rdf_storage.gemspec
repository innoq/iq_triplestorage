require File.expand_path("../lib/iq_rdf_storage", __FILE__)

Gem::Specification.new do |s|
  s.name        = "iq_rdf_storage"
  s.version     = IqRdfStorage::VERSION
  s.platform    = Gem::Platform::RUBY

  s.rubyforge_project = s.name

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end

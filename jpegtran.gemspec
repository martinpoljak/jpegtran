# -*- encoding: utf-8 -*-
require "./lib/version"

Gem::Specification.new do |s|
  s.name = "jpegtran"
  s.version = Jpegtran::VERSION
  s.authors = ["Martin Koz\u{e1}k"]
  s.email = "martinkozak@martinkozak.net"

  s.homepage = "https://github.com/martinkozak/jpegtran"
  s.licenses = ["MIT"]
  s.summary = "Ruby interface to 'jpegtran' tool."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.has_rdoc = true
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]

  s.add_runtime_dependency 'pipe-run', "~> 0.3.0"
  s.add_development_dependency 'bundler'
end


# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qpay/version'

Gem::Specification.new do |spec|
  spec.name          = 'qpay'
  spec.version       = Qpay::VERSION
  spec.authors       = ['scorix']
  spec.email         = ['scorix@gmail.com']

  spec.summary       = %q{A gem for payment in qpay.}
  spec.description   = %q{api doc: https://qpay.qq.com/qpaywiki/showdocument.php?pid=38&docid=58}
  spec.homepage      = 'https://github.com/scorix/qpay'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '> 1.9'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'net-dns'
  spec.add_development_dependency 'sinatra'

  spec.add_development_dependency 'httparty'
  spec.add_development_dependency 'patron'

  spec.add_dependency 'multi_xml'
end

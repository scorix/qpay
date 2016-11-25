$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'qpay'
require 'rspec'
require 'rspec/its'
require 'webmock/rspec'
require 'fakes/fake_qpay'

RSpec.configure do |c|
  c.before { stub_request(:any, /https:\/\/qpay\.qq\.com/).to_rack(FakeQpay) }
end

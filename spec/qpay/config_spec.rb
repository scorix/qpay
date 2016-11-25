describe Qpay do
  describe "#configure" do
    subject { Qpay::Client.new(appid: 'abc') }

    its(:config) { is_expected.to be_a Qpay::Config }
    its('config.appid') { is_expected.to eql 'abc' }
  end
end

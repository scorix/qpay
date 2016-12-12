describe Qpay do
  describe "#sign" do
    let(:config) { Qpay::Config.new(appid: 'wxd930ea5d5a258f4f',
                                    mch_id: '10000100',
                                    api_key: '192006250b4c09247ec02edce69f6a2d') }

    context :params_without_noncestr do
      let(:params) { {device_info: '1000', body: 'test', appid: 'wxd930ea5d5a258f4f', mch_id: '10000100', nonce_str: "ibuaiVcKdpRxkhJA"} }

      context :sign do
        subject { Qpay.sign(params, config) }
        it { is_expected.to eql '9A0A8659F005D6984697E2CA0A9CF3B7' }
      end

      context :string_params_without_sign do
        subject { Qpay.string_params_without_sign(params, config) }
        it { is_expected.to eql 'appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d' }
      end

      context :params_with_sign do
        subject { Qpay.params_with_sign(params, config) }
        it { is_expected.to eql "device_info" => "1000",
                                "body" => "test",
                                "appid" => "wxd930ea5d5a258f4f",
                                "mch_id" => "10000100",
                                "nonce_str" => "ibuaiVcKdpRxkhJA",
                                "sign" => "9A0A8659F005D6984697E2CA0A9CF3B7" }
      end
    end

    context :params_without_noncestr do
      let(:params) { {device_info: '1000', body: 'test', nonce_str: 'ibuaiVcKdpRxkhJA', appid: 'wxd930ea5d5a258f4f', mch_id: '10000100'} }

      context :sign do
        subject { Qpay.sign(params, config) }
        it { is_expected.to eql '9A0A8659F005D6984697E2CA0A9CF3B7' }
      end

      context :string_params_without_sign do
        subject { Qpay.string_params_without_sign(params, config) }
        it { is_expected.to eql 'appid=wxd930ea5d5a258f4f&body=test&device_info=1000&mch_id=10000100&nonce_str=ibuaiVcKdpRxkhJA&key=192006250b4c09247ec02edce69f6a2d' }
      end

      context :params_with_sign do
        subject { Qpay.params_with_sign(params, config) }
        it { is_expected.to eql "device_info" => "1000",
                                "body" => "test",
                                "appid" => "wxd930ea5d5a258f4f",
                                "mch_id" => "10000100",
                                "nonce_str" => "ibuaiVcKdpRxkhJA",
                                "sign" => "9A0A8659F005D6984697E2CA0A9CF3B7" }
      end
    end

    context :signed_params do
      context :mch_id do
        let(:params) { {device_info: '1000', body: 'test', nonce_str: 'ibuaiVcKdpRxkhJA', appid: 'wxd930ea5d5a258f4f'} }
        subject { Qpay.params_with_sign(params, config) }
        its(:keys) { is_expected.to eql params.keys.map(&:to_s) | %w(nonce_str sign) }
      end

      context :appid do
        let(:params) { {device_info: '1000', body: 'test', nonce_str: 'ibuaiVcKdpRxkhJA', mch_id: '10000100'} }
        subject { Qpay.params_with_sign(params, config) }
        its(:keys) { is_expected.to eql params.keys.map(&:to_s) | %w(nonce_str sign) }
      end
    end
  end

  describe "#sign_app" do
    let(:params) { {appId: "100619284", nonce: "ksjfwierwfjk", tokenId: "1000000002", pubAcc: nil, bargainorId: "1900000109"} }
    let(:config) { Qpay::Config.new(appid: '100619284',
                                    mch_id: '1900000109',
                                    app_key: 'd139ae6fb0175e5659dce2a7c1fe84d5') }
    it "should sign the params" do
      expect(Qpay.sign_app(params, config)).to eql "c6xXw0tNABhOMc869h1bfxTp9Mk="
    end
  end
end

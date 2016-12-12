module Qpay
  class << self
    def sign(params, config)
      Digest::MD5.hexdigest(string_params_without_sign(params, config)).upcase
    end

    # https://qpay.qq.com/qpaywiki/showdocument.php?pid=38&docid=165
    def sign_app(params, config)
      key = "#{config.app_key}&"
      data = preprocess_params(params, keep_blank: true).sort_by { |k, _| k }.map { |x| x.join('=') }.join('&')
      digest = OpenSSL::Digest.new('sha1')
      hmac = OpenSSL::HMAC.digest(digest, key, data)
      Base64.encode64(hmac).strip
    end

    def string_params_without_sign(params, config)
      sorted_params = preprocess_params(params).sort_by { |k, _| k }
      (sorted_params << ['key', config.api_key]).map { |x| x.join('=') }.join('&')
    end

    def params_with_sign(params, config)
      params_dup = preprocess_params(params)
      params_dup.merge('sign' => Qpay.sign(params, config))
    end

    private
    def random_string
      SecureRandom.urlsafe_base64.tr('-_', '')
    end

    def preprocess_params(params, keep_blank: false)
      params_dup = params.dup
      stringified_keys_params = {}
      params_dup.each do |k, v|
        next if !keep_blank && blank?(v)
        stringified_keys_params[k.to_s] = v
      end
      stringified_keys_params.delete('key')
      stringified_keys_params
    end

    def blank?(v)
      !v || v.nil? || (v.respond_to?(:empty?) && v.empty?)
    end
  end
end

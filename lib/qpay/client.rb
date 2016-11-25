# encoding: utf-8

module Qpay
  class Client

    def initialize(options = {})
      @config = Config.new
      @config.appid = options[:appid]
      @config.mch_id = options[:mch_id]
      @config.app_secret = options[:app_secret]
      @config.api_key = options[:api_key]
      @config.cert_type = options[:cert_type]
      @config.cert_file = options[:cert_file]
      @config.cert_password = options[:cert_password]
      @config.adapter = options[:adapter] || :patron
    end

    def config
      @config.dup
    end

    def api
      @api ||= case config.adapter
                 when :httparty
                   require 'httparty'
                   c = Class.new do
                     include ::HTTParty
                     base_uri 'https://qpay.qq.com/cgi-bin'
                     disable_rails_query_string_format
                     default_timeout 10
                     headers 'Content-Type' => 'application/xml'

                     def self.post(url, body, format:)
                       super(url, body: body, format: format).parsed_response
                     end
                   end

                   c.default_options.delete(:p12)
                   c.default_options.delete(:p12_password)
                   c.default_options.delete(:pem)
                   c.default_options.delete(:pem_password)

                   # set cert option
                   if @config.cert_type && @config.cert_file && File.exist?(@config.cert_file)
                     c..public_send(@config.cert_type.to_sym, File.read(@config.cert_file), @config.cert_password)
                   end
                   c
                 when :patron
                   require 'patron'
                   Class.new do
                     def self.post(url, body, format:)
                       s = Patron::Session.new(base_url: 'https://qpay.qq.com/cgi-bin',
                                               timeout: 10,
                                               headers: {'Content-Type' => 'application/xml'},
                                               force_ipv4: true)
                       body = s.post(url, body).body
                       case format
                         when :xml
                           MultiXml.parse(body)
                         when :csv
                           require 'csv'
                           CSV.parse(body)
                       end
                     end
                   end
               end
    end

    # 除被扫支付场景以外，商户系统先调用该接口在QQ钱包服务后台生成预支付交易单，返回正确的预支付交易回话标识后再按具体的场景生成交易串调起支付。
    def unifiedorder(body, out_trade_no, total_fee, spbill_create_ip, notify_url, more_params = {})
      params = more_params.merge(body: body,
                                 out_trade_no: out_trade_no,
                                 total_fee: total_fee,
                                 spbill_create_ip: spbill_create_ip,
                                 notify_url: notify_url)
      params[:fee_type] ||= 'CNY'
      params[:time_start] ||= Time.now.strftime('%Y%m%d%H%M%S')
      params[:trade_type] ||= 'APP'

      api.post('/pay/qpay_unified_order.cgi', request_params(params), format: :xml)
    end

    # 该接口提供所有手Q钱包订单的查询，商户可以通过该接口主动查询订单状态，完成下一步的业务逻辑。
    #
    # 需要调用查询接口的情况：
    #   * 当商户后台、网络、服务器等出现异常，商户系统最终未接收到支付通知；
    #   * 调用支付接口后，返回系统错误或未知交易状态情况；
    #   * 调用 qpay_close_order.cgi 关闭订单接口之前之前，需确认支付状态
    def orderquery(out_trade_no, more_params = {})
      params = more_params.merge(out_trade_no: out_trade_no)

      api.post('/pay/qpay_order_query.cgi', request_params(params), format: :xml)
    end

    # 以下情况需要调用关单接口：
    #   * 商户订单支付失败需要生成新单号重新发起支付，要对原订单号调用关单，避免重复支付
    #   * 系统下单后，用户支付超时，系统退出不再受理，避免用户继续，请调用关单接口
    #
    # 注意：订单生成后不能马上调用关单接口，最短调用时间间隔为5分钟。
    def closeorder(out_trade_no, more_params = {})
      params = more_params.merge(out_trade_no: out_trade_no)

      api.post('/pay/qpay_close_order.cgi', request_params(params), format: :xml)
    end


    # 当交易发生之后一段时间内，由于买家或者卖家的原因需要退款时，卖家可以通过退款接口将支付款退还给买家，QQ钱包将在收到退款请求并且验证成功之后，按照退款规则将支付款按原路退到买家帐号上。
    #
    # 注意：
    #   1.交易时间超过一年的订单无法提交退款；
    #   2.QQ钱包退款支持单笔交易分多次退款，多次退款需要提交原支付订单的商户订单号和设置不同的退款单号。一笔退款失败后重新提交，要采用原来的退款单号。总退款金额不能超过用户实际支付金额。
    def refund(out_trade_no, out_refund_no, total_fee, refund_fee, more_params = {})
      params = more_params.merge(out_trade_no: out_trade_no,
                                 out_refund_no: out_refund_no,
                                 total_fee: total_fee,
                                 refund_fee: refund_fee)
      params[:refund_fee_type] ||= 'CNY'
      params[:op_user_id] ||= Qpay.config.mch_id

      api.post('/pay/qpay_refund.cgi', request_params(params), format: :xml)
    end

    # 提交退款申请后，通过调用该接口查询退款状态。退款有一定延时，用余额支付的退款20分钟内到账，银行卡支付的退款3个工作日后重新查询退款状态。
    def refundquery(out_trade_no, more_params = {})
      params = more_params.merge(out_trade_no: out_trade_no)

      api.post('/pay/qpay_refund_query.cgi', request_params(params), format: :xml)
    end

    # 商户可以通过该接口下载历史交易清单。
    #
    # 注意：
    #   1、在QQ钱包侧未成功下单的交易不会出现在对账单中；
    #   2、QQ钱包在次日9点启动生成前一天的对账单，建议商户10点后再获取；
    #   3、对账单中涉及金额的字段单位为“元”；
    #   4、对账单接口只能下载三个月以内的对账单。
    def downloadbill(bill_date, more_params = {})
      params = more_params.merge(bill_date: Time.parse(bill_date.to_s).strftime('%Y%m%d'))

      # csv data
      api.post("/sp_download/qpay_mch_statement_down.cgi", request_params(params), format: :csv)
    end

    private
    def request_params(params)
      params.merge!(appid: @config.appid, mch_id: @config.mch_id)
      to_xml(Qpay.params_with_sign(params, @config))
    end

    def to_xml(params)
      xml = '<xml>'
      ((params.keys - ['sign', :sign]).sort | ['sign', :sign]).each do |k|
        xml << "<#{k}>#{params[k]}</#{k}>" if params[k]
      end
      xml << '</xml>'
    end
  end
end

require 'sinatra/base'

class FakeQpay < Sinatra::Base
  helpers do
    def hash_to_xml(hash)
      xml = '<xml>'
      hash.each { |k, v| xml << "<#{k}>#{v}</#{k}>" }
      xml << '</xml>'
      xml
    end
  end

  post '/cgi-bin/pay/qpay_unified_order.cgi' do
    content_type :txt
    status 200

    hash = {
        return_code: 'SUCCESS',
        return_msg: 'OK',
        appid: 'wx2421b1c4370ec43b',
        mch_id: '10000100',
        nonce_str: 'IITRi8Iabbblz1Jc',
        sign: '7921E432F65EB8ED0CE9755F0E86D72F',
        result_code: 'SUCCESS',
        prepay_id: 'wx201411101639507cbf6ffd8b0779950874',
        trade_type: 'JSAPI'
    }

    body hash_to_xml(hash)
  end

  post '/cgi-bin/pay/qpay_order_query.cgi' do
    content_type :txt
    status 200

    hash = {
        return_code: 'SUCCESS',
        return_msg: 'OK',
        appid: 'wx2421b1c4370ec43b',
        mch_id: '10000100',
        nonce_str: 'IITRi8Iabbblz1Jc',
        sign: '7921E432F65EB8ED0CE9755F0E86D72F',
        result_code: 'SUCCESS',
        prepay_id: 'wx201411101639507cbf6ffd8b0779950874',
        trade_type: 'JSAPI'
    }

    body hash_to_xml(hash)
  end

  post '/cgi-bin/pay/qpay_close_order.cgi' do
    content_type :txt
    status 200

    hash = {
        retcode: 0,
        retmsg: 'ok',
        return_code: 'SUCCESS',
        return_msg: 'SUCCESS',
        appid: 'wx2421b1c4370ec43b',
        mch_id: '10000100',
        nonce_str: 'IITRi8Iabbblz1Jc',
        sign: '7921E432F65EB8ED0CE9755F0E86D72F',
        result_code: 'SUCCESS',
        prepay_id: 'wx201411101639507cbf6ffd8b0779950874',
        trade_type: 'JSAPI'
    }

    body hash_to_xml(hash)
  end

  post '/cgi-bin/sp_download/qpay_mch_statement_down.cgi' do
    content_type :txt
    status 200
    body "交易时间,商户号,商户APPID,子商户号,子商户APPID,用户标识,设备号,支付场景,商户订单号,QQ钱包订单号,付款银行,货币种类,订单金额(元),商户优惠金额(元),商户应收金额(元),QQ钱包优惠金额(元),用户支付金额(元),交易状态,退款提交时间,商户退款订单号,QQ钱包退款订单号,退款金额(元),退还QQ钱包优惠金额(元),退款状态,退款成功时间,退款方式,商品名称,商户数据包,手续费金额(元),费率
2016/7/23 14:14,1263732001,暂无数据,1263711801,暂无数据,暂无数据,暂无数据,暂无数据,`100540000011201607231001010451,`1263711801461607231903720235,财付通余额,RMB,0,暂无数据,暂无数据,0,,转入退款,2016/7/23 14:14,`REV_100540000011201607231001010451,`1121263711801607230535066910,0.01,0,退款成功,暂无数据,暂无数据,暂无数据,暂无数据,暂无数据,暂无数据
交易总笔数,订单总金额(元),商户优惠总金额(元),商户应收总金额(元),QQ钱包优惠总金额(元),用户支付总金额(元),退款总金额(元),退还QQ钱包优惠总金额(元),手续费总金额(元)
9,0,0,0,0,0,353.04,0,0"
  end
end

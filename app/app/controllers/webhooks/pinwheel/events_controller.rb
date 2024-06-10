class Webhooks::Pinwheel::EventsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def secure_compare(a, b)
    ActiveSupport::SecurityUtils.secure_compare(a, b)
  end

  def verify_signature(signature, timestamp, raw_body)
    msg = IO:Buffer.from"v2:#{timestamp}:#{raw_body}"
    digest = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      'YOUR_API_SECRET',
      msg
    )
    generated_signature = "v2=#{digest}"
    secure_compare(signature, generated_signature)
  end

  def create
    signature = request.headers['X-Pinwheel-Signature']
    timestamp = request.headers['X-Timestamp']

    unless verify_signature(signature, timestamp, request.body.read.bytes)
      return render json: { error: "Invalid signature" }, status: :unauthorized
    end

    if params["event"] == "paystubs.fully_synced" || params["event"] == "paystubs.partially_synced"
      @cbv_flow = CbvFlow.find_by_argyle_user_id(params["data"]["user"])

      if @cbv_flow
        @cbv_flow.update(payroll_data_available_from: params["data"]["available_from"])
        ArgylePaystubsChannel.broadcast_to(@cbv_flow, params)
      end
    end

    if params["event"] == "accounts.connected"
      rep = ConnectedArgyleAccount.create!(
        user_id: params["data"]["user"],
        account_id: params["data"]["account"]
      )
      Rails.logger.info "ConnectedArgyleAccount created: #{rep}"
      render json: { message: "ConnectedArgyleAccount created", data: rep }, status: :created
    end
  end
end

# # Technology Stack: Node.js, Express.js

# require 'openssl'
# require 'digest'

# def verify_signature(signature, timestamp, raw_body)
#   prefix = Buffer.from("v2:#{timestamp}:", 'utf8')
#   message = Buffer.concat([prefix, raw_body])
#   digest = OpenSSL::HMAC.hexdigest('sha256', ENV['YOUR_PINWHEEL_API_SECRET'].encode('utf-8'), message)
#   generated_signature = "v2=#{digest}"

#   buf_sig = Buffer.from(signature)
#   buf_gen = Buffer.from(generated_signature)

#   return buf_sig.length == buf_gen.length && OpenSSL::TimingSafeEqual.timingSafeEqual(buf_sig, buf_gen)
# end

# auth_middleware = Express.json(verify: ->(request, response, buffer) {
#   signature = request.headers['x-pinwheel-signature']
#   timestamp = request.headers['x-timestamp']

#   unless verify_signature(signature, timestamp, buffer)
#     raise 'Invalid webhook request signature'
#   end
# })

class CbvFlowInvitation < ApplicationRecord
  has_secure_token :auth_token, length: 36

  has_one :cbv_flow

  def has_visited?
    cbv_flow.present?
  end

  def to_url
    Rails.application.routes.url_helpers.cbv_flow_entry_url(token: auth_token)
  end
end

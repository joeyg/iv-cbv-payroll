class Api::ArgyleController < ApplicationController
  USER_TOKEN_ENDPOINT = 'https://api-sandbox.argyle.com/v2/user-tokens';
  ITEMS_ENDPOINT = 'https://api-sandbox.argyle.com/v2/items';

  def update_token
    cbv_flow = CbvFlow.find(session[:cbv_flow_id])
    new_token = refresh_token(cbv_flow.argyle_user_id)

    render json: { status: :ok, token: new_token['user_token'] }
  end

  def items
    render json: { status: :ok, items: fetch_employers(params[:q]) }
  end

  private

  def refresh_token(argyle_user_id)
    res = Net::HTTP.post(
      URI.parse(USER_TOKEN_ENDPOINT),
      { "user": argyle_user_id }.to_json,
      {
        "Authorization" => "Basic #{Rails.application.credentials.argyle[:api_key]}",
        "Content-Type" => "application/json"
      }
    )

    JSON.parse(res.body)
  end

  def fetch_employers(query)
    res = Net::HTTP.get(URI.parse("#{ITEMS_ENDPOINT}?q=#{query}"), {"Authorization" => "Basic #{Rails.application.credentials.argyle[:api_key]}"})
    parsed = JSON.parse(res)

    parsed['results']
  end
end

class ProvidersController < ApplicationController
  USER_TOKEN_ENDPOINT = 'https://api-sandbox.argyle.com/v2/users';
  ITEMS_ENDPOINT = 'https://api-sandbox.argyle.com/v2/items';
  PAYSTUBS_ENDPOINT = 'https://api-sandbox.argyle.com/v2/paystubs?limit=2&account='

  def index
    res = Net::HTTP.post(URI.parse(USER_TOKEN_ENDPOINT), "", {"Authorization" => "Basic #{ENV['ARGYLE_API_TOKEN']}"})
    res2 = Net::HTTP.get(URI.parse(ITEMS_ENDPOINT), {"Authorization" => "Basic #{ENV['ARGYLE_API_TOKEN']}"})
    @user_token = JSON.parse(res.body)["user_token"]
    @companies = JSON.parse(res2)["results"]
    @account_id = params[:account_id]
  end

  def search
  end

  def confirm
    res = Net::HTTP.get(URI.parse("#{PAYSTUBS_ENDPOINT}#{employer_params[:account_id]}"), {"Authorization" => "Basic #{ENV['ARGYLE_API_TOKEN']}"})

    @employer = employer_params[:employer]
    @payments = JSON.parse(res)["results"].map do |payment|
      {
        amount: payment['net_pay'].to_i,
        start: payment['paystub_period']['start_date'],
        end: payment['paystub_period']['end_date'],
        hours: payment['hours'],
        rate: payment['rate']
      }
    end
  end

  private

  def employer_params
    params.require(:user).permit(:employer, :account_id)
  end
end

class CbvFlowsController < ApplicationController
  USER_TOKEN_ENDPOINT = 'https://api-sandbox.argyle.com/v2/users';

  before_action :set_cbv_flow

  def entry
  end

  def employer_search
    @argyle_user_token = fetch_and_store_argyle_token
  end

  def summary
    @employer = summary_employer_params[:employer]
    @payments = [
      { amount: 810, start: 'March 25', end: 'June 15', hours: 54, rate: 15  },
      { amount: 195, start: 'January 1', end: 'February 23', hours: 13, rate: 15  }
    ]
  end

  def reset
    session[:cbv_flow_id] = nil
    session[:argyle_user_token] = nil
    redirect_to root_url
  end

  private

  def set_cbv_flow
    if session[:cbv_flow_id]
      @cbv_flow = CbvFlow.find(session[:cbv_flow_id])
    else
      # TODO: This case_number would be provided by the case worker when they send the initial invite
      @cbv_flow = CbvFlow.create(case_number: 'ABC1234')
      session[:cbv_flow_id] = @cbv_flow.id
    end
  end

  def next_path
    case params[:action]
    when 'entry'
      cbv_flow_employer_search_path
    when 'employer_search'
      cbv_flow_summary_path
    when 'summary'
      root_url
    end
  end
  helper_method :next_path

  def fetch_and_store_argyle_token
    return session[:argyle_user_token] if session[:argyle_user_token].present?

    raise "ARGYLE_API_TOKEN environment variable is blank. Make sure you have the .env.local from 1Password." if ENV['ARGYLE_API_TOKEN'].blank?

    res = Net::HTTP.post(URI.parse(USER_TOKEN_ENDPOINT), "", {"Authorization" => "Basic #{ENV['ARGYLE_API_TOKEN']}"})
    parsed = JSON.parse(res.body)
    raise "Argyle API error: #{parsed['detail']}" if res.code.to_i >= 400

    @cbv_flow.update(argyle_user_id: parsed['id'])
    session[:argyle_user_token] = parsed['user_token']

    parsed['user_token']
  end

  def summary_employer_params
    params.permit(:employer)
  end
end

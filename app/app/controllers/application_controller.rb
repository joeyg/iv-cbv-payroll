class ApplicationController < ActionController::Base
  helper :view
  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def site_config
    Rails.application.config.sites
  end
end

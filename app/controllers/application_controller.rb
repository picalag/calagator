# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '8813a7fec0bb4fbffd283a3868998eed'

  layout "application"

  # For vendor/plugins/exception_notification
  if ['preview', 'production'].include?(RAILS_ENV) || ENV['NOTIFY_ON_EXCEPTIONS']
    include ExceptionNotifiable
    local_addresses.clear
    (self.exception_notifiable_silent_exceptions ||= []) << ActionController::InvalidAuthenticityToken if ActionController.const_defined?(:InvalidAuthenticityToken)
  end

  # Setup theme
  layout "application"
  theme THEME_NAME # DEPENDENCY: lib/theme_reader.rb


  protected

  #---[ Helpers ]---------------------------------------------------------

  # Returns a data structure used for telling the CSS menu which part of the
  # site the user is on. The structure's keys are the symbol names of resources
  # and their values are either "active" or nil.
  def link_class
    return @_link_class_cache ||= {
      :events => (( controller_name == 'events' ||
            controller_name == 'sources' ||
            controller_name == 'site')  && 'active'),
      :venues => (controller_name == 'venues'  && 'active'),
    }
  end
  helper_method :link_class

  #---[ Misc ]------------------------------------------------------------

  # Set or append flash +message+ (e.g. "OMG!") to flash key with the name
  # +kind+ (e.g. :failure).
  def append_flash(kind, message)
    kind = kind.to_sym
    if leaf = flash[kind]
      flash[kind] = "#{leaf} #{message}"
    else
      flash[kind] = "#{message}"
    end
  end

  # Authlogic
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation

  private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def require_user
    unless current_user
      store_location
      flash[:failure] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def require_no_user
    if current_user
      store_location
      flash[:failure] = "You must be logged out to access this page"
      redirect_to root_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
end

# Make it possible to use helpers in controllers
# http://www.johnyerhot.com/2008/01/10/rails-using-helpers-in-you-controller/
class Helper
  include Singleton
  include ActionView::Helpers::UrlHelper # Provide: #link_to
  include ActionView::Helpers::TagHelper # Provide: #escape_once (which #link_to needs)
end
def help
  Helper.instance
end

class ApplicationController < ActionController::API
    before_action :check_concurrent_session
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def check_concurrent_session
      if already_logged_in?

        sign_out current_user
        render json: { message: "Token Expired Please Log In Again"}, status: 401 
      end
    end
  
    def already_logged_in?
      current_user && !(bearer_token == current_user.current_login_token)
    end

    def bearer_token
      pattern = /^Bearer /
      header  = request.headers['Authorization']
      header.gsub(pattern, '') if header && header.match(pattern)
    end
    
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :deposit])
      devise_parameter_sanitizer.permit(:account_update, keys: [:role, :deposit])
      
    end
end

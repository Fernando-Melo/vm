class Users::RegistrationsController < Devise::RegistrationsController
    respond_to :json
    # before_action :configure_sign_up_params, only: [:create]

    # def create
    #     binding.pry
    #     super
    # end

    private

    # def configure_sign_up_params
    #     devise_parameter_sanitizer.permit(:sign_up, keys: [:role, :deposit])
    # end

    def respond_with(resource, _opts = {})
      resource.persisted? ? register_success : register_failed
    end
    def register_success
      render json: { message: 'Signed up.' }
    end
    def register_failed
      render json: { message: "Signed up failure." }
    end
end

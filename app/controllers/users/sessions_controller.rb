class Users::SessionsController < Devise::SessionsController
    respond_to :json

    def create
      super
    end

    def destroy_all
      AllowlistedJwt.where(user_id: current_user&.id)&.pluck(:jti).each do |jti|
        User.revoke_jwt({ "jti": jti }, current_user)
      end

      render json: { message: "Logged out on all devices" }, status: :ok
    end

    private 

    def respond_with(resource, _opts = {})
      if multiple_logins?
        return render json: { message: "There is already an active session using your account." }, status: :ok
      end
      render json: { message: "Logged in." }, status: :ok
    end

    def respond_to_on_destroy
      render json: { message: "Logged out." }, status: :ok
    end

    def multiple_logins?
      AllowlistedJwt.where(user_id: current_user&.id).count > 1
    end
end

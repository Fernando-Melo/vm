class Users::SessionsController < Devise::SessionsController
    respond_to :json

    def create
      super
    end

    private 

    def respond_with(resource, _opts = {})
      # if multiple_logins?
      #   return render json: { message: "There is already an active session using your account." }, status: :ok
      # end
      render json: { message: "Logged in." }, status: :ok
    end

    def respond_to_on_destroy
      log_out_success
    end

    def log_out_success
      render json: { message: "Logged out." }, status: :ok
    end

    # def log_out_failure
    #   render json: { message: "Logged out failure."}, status: :unauthorized
    # end
end

class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :check_current_user_buyer, only: %i[ deposit reset buy ]
    before_action :set_product, only: %i[ buy ]
    before_action :check_quantity, only: %i[ buy ]
    before_action :check_deposit, only: %i[ buy ]
    

    POSSIBLE_DEPOSITS = [100, 50, 20, 10, 5]

    def show
        return render json: User.find_by(id: params[:id]) if current_user&.id&.to_s == params[:id] || current_user&.role == "admin"

        render json: { message: "Unauthorized"}, status: 401
    end

    def destroy
        if current_user
            current_user.destroy!
            return render json: { message: "Deleted User"}, status: 200
        end

        render json: { message: "Unauthorized"}, status: 401
    end

    def show_all
        return render json: User.all if current_user&.role == "admin"

        render json: { message: "Unauthorized"}, status: 401
    end

    def update
        return render json: current_user if current_user&.update!(user_params)
        
        render json: { message: "Could not update user" },status: 500
    end

    def deposit
        if POSSIBLE_DEPOSITS.include?(params[:deposit].to_i)
            current_user.update!(deposit: current_user.deposit + params[:deposit].to_i)
            return render json: { 
                deposit: "You just deposited #{params[:deposit].to_i}",
                total_deposit:  current_user.deposit
            } 
        end
        
        render json: { message: "Invalid Amount"}, status: 422 
    end

    def reset
        old_deposit = current_user.deposit
        current_user.update!(deposit: 0)

        return render json: { 
            message: "Reset! Please collect #{old_deposit}",
        } 
    end

    def buy
        @total_change = current_user.deposit - @total_spent 
        change_result = give_change

        old_deposit = current_user.deposit

        # assuming machine will give back all the money after purchase
        current_user.update!(deposit: 0)

        render json: {
            deposit: old_deposit,
            spent: @total_spent,
            change: @total_change,
            change_result: change_result
        }
    end


    private

    def give_change
        change_left = @total_change
        change_result = []

        POSSIBLE_DEPOSITS.each do |coin|
            number_of_coins = change_left / coin 
            change_result.push(number_of_coins)
            change_left -= number_of_coins * coin
        end
        
        return change_result
    end

    def set_product
        @product = Product.find_by(id: params[:product_id])

        render json: { message: "Product does not exist"}, status: 404 unless @product
    end

    def check_quantity
        render json: { message: "Product out of stock for the quantity requested"}, status: 422 if @product.amount_available < params[:quantity].to_i || params[:quantity].to_i <= 0
    end
 
    def check_deposit
        @total_spent = @product.cost * params[:quantity].to_i
        render json: { message: "Insufficient Funds"}, status: 422 if @total_spent > current_user.deposit
    end   


    def user_params
      params.fetch(:user, {}).permit(:password, :email, :role, :deposit)
    end

    def check_current_user_buyer
        render json: {message: "Unauthorized"}, status: 401 unless current_user&.role == "buyer"
    end
end
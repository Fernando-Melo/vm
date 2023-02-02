require 'rails_helper'

RSpec.describe UsersController, type: :controller do
    def login_user(user)
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user
    end

    let!(:some_users) do
        [
            FactoryBot.create(:user, role: "buyer", email: "1stemail@email.com"),
            FactoryBot.create(:user, role: "seller", email: "2ndemail@email.com"),
        ]
    end

    describe "GET #show_all" do

        context "when user is admin" do
            let(:admin) { FactoryBot.create(:admin)}

            it "returns all users" do
                login_user(admin)
                get :show_all, params: {}

                # Make sure to swap this as well
                expect(response).to be_successful # be_successful expects a HTTP Status code of 200

                result = JSON.parse(response.body)
                expect(result[0].with_indifferent_access).to include(
                    {
                        id: some_users[0].id, 
                        email: some_users[0].email,
                        role: some_users[0].role,
                        deposit: some_users[0].deposit, 
                    }
                )

                expect(result[1].with_indifferent_access).to include(
                    {
                        id: some_users[1].id, 
                        email: some_users[1].email,
                        role: some_users[1].role,
                        deposit: some_users[1].deposit, 
                    }
                )
                
                expect(result[2].with_indifferent_access).to include(
                    {
                        id: admin.id, 
                        email: admin.email,
                        role: admin.role,
                        deposit: admin.deposit, 
                    }
                )                  
            end
        end

        context "when user is not admin" do
            let(:user) { FactoryBot.create(:user)}

            it "is not authorized to view all users" do
                login_user(user)
                get :show_all, params: {}
                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
            end

            it "testing 2 logins in a row" do
                login_user(user)
                login_user(user)
            end
        end
        
        context "without login" do
            it "requires authentication to perform action" do
                get :show_all, params: {}

                expect(response.status).to eq(401)
                
            end
        end

    end

    describe "GET #show" do

        context "when user is admin" do
            let(:admin) { FactoryBot.create(:admin)}
            let(:user) { FactoryBot.create(:user, email: "random@email.com")}

            it "returns user's info" do
                login_user(admin)
                get :show, params: { id: user.id }

                expect(response).to be_successful
                result = JSON.parse(response.body)
                expect(result.with_indifferent_access).to include(
                    {
                        id: user.id, 
                        email: user.email,
                        role: user.role,
                        deposit: user.deposit, 
                    }
                )             
            end
        end

        context "when user is not admin" do
            let(:user) { FactoryBot.create(:user)}
            let(:user_2){ FactoryBot.create(:user, email: "abcd@email.com")}

            it "not authorized to check on other user's info" do
                login_user(user)
                get :show, params: { id: user_2.id }

                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")            
            end

            it " authorized to check own info" do
                login_user(user)
                get :show, params: { id: user.id }

                expect(response).to be_successful
               
                result = JSON.parse(response.body)
                expect(result.with_indifferent_access).to include(
                    {
                        id: user.id, 
                        email: user.email,
                        role: user.role,
                        deposit: user.deposit, 
                    }
                )   
            end            
        end    
        
        context "without login" do
            it "requires authentication to perform action" do
                get :show, params: { id: 1 }

                expect(response.status).to eq(401)
                
            end
        end
    end    

    describe "PATCH #update" do
            let(:user) { FactoryBot.create(:user)}

            let(:new_email) { "abc@email.com"}
            let(:role) { "seller" }
            let(:password) { "new_password" }


            it "is not authorized to update its info" do
                login_user(user)

                old_encrypted_password = user.encrypted_password

                patch  :update, params: {user: {email: new_email, role: role, password: password}}

                expect(response).to be_successful
                user.reload
                expect(user.email).to eq (new_email)
                expect(user.role).to eq (role)
                expect(user.encrypted_password).not_to eq (old_encrypted_password)
            end 
            
            context "without login" do
                it "requires authentication to perform action" do
                    patch  :update, params: {user: {email: new_email, role: role, password: password}}

                    expect(response.status).to eq(401)
                    
                end
            end
    end    

    describe "POST #deposit" do
        context "when user is not a buyer" do
            let(:user) { FactoryBot.create(:user, role: "seller")}
            it "is not authorized to deposit" do                    
                login_user(user)

                post  :deposit, params: {deposit: 50}

                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
            end 
        end
        
        context "when user is a buyer" do
            let(:user) { FactoryBot.create(:user, role: "buyer", deposit: initial_deposit)}


            context "when user deposits a valid amount" do
                let(:initial_deposit) { 200 }
                let(:deposit) { 50 }


                it "adds funds to user's deposit" do                    
                    login_user(user)

                    post  :deposit, params: {deposit: deposit}

                    expect(response).to be_successful
                    
                    json_response = JSON.parse(response.body)
                    expect(json_response["deposit"]).to eq("You just deposited #{deposit}")
                    user.reload
                    expect(user.deposit).to eq(initial_deposit + deposit)
                end 
            end

            context "when user deposits an invalid amount" do
                let(:initial_deposit) { 200 }
                let(:deposit) { 3 }


                it "adds funds to user's deposit" do                    
                    login_user(user)

                    post  :deposit, params: {deposit: deposit}

                    expect(response.status).to eq(422)
                    expect(JSON.parse(response.body)["message"]).to eq("Invalid Amount")
                end 
            end            
        end    
        
        context "without login" do
            it "requires authentication to perform action" do
                post  :deposit, params: {deposit: 50}

                expect(response.status).to eq(401)
            end
        end
    end        

    describe "GET #reset" do
        context "when user is not a buyer" do
            let(:user) { FactoryBot.create(:user, role: "seller")}
            it "is not authorized to reset deposit" do                    
                login_user(user)

                get  :reset, params: {}

                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
            end 
        end
        
        context "when user is a buyer" do
            let(:initial_deposit) { 200 }
            let(:user) { FactoryBot.create(:user, role: "buyer", deposit: initial_deposit)}

            it "reset buyer's deposit to 0" do                    
                login_user(user)

                get  :reset, params: {}

                expect(response).to be_successful
                expect(JSON.parse(response.body)["message"]).to eq("Reset! Please collect #{initial_deposit}")
                
                user.reload
                expect(user.deposit).to eq(0)
            end 
        end 
        
        context "without login" do
            it "requires authentication to perform action" do
                get  :reset, params: {}

                expect(response.status).to eq(401)
                
            end
        end
    end  
    
    describe "Post #buy" do
        context "when user is not a buyer" do
            let(:user) { FactoryBot.create(:user, role: "seller")}
            it "is not authorized to update its info" do                    
                login_user(user)

                post  :buy, params: {}

                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Unauthorized")
            end 
        end
        
        context "when user is a buyer" do
            let(:initial_deposit) { 0 }
            let(:user) { FactoryBot.create(:user, role: "buyer", deposit: initial_deposit)}
            let(:product) {FactoryBot.create(:product, amount_available: 2, cost: 55 )}

            it "throws error when user does not have funds to buy product(s)" do                    
                login_user(user)

                post  :buy, params: {product_id: product.id, quantity: 1}

                expect(response.status).to eq(422)
                expect(JSON.parse(response.body)["message"]).to eq("Insufficient Funds")
            end
            
            
            it "throws error when user requests more products than the ones available" do                    
                login_user(user)
                user.update(deposit: 500)

                post  :buy, params: {product_id: product.id, quantity: 3}

                expect(response.status).to eq(422)
                expect(JSON.parse(response.body)["message"]).to eq("Product out of stock for the quantity requested")
            end   
            
            it "gives 0 change when user has exactly the right amount of deposit" do                    
                login_user(user)
                user.update(deposit: 110)

                post  :buy, params: {product_id: product.id, quantity: 2}

                expect(response).to be_successful
                
                expect(JSON.parse(response.body).with_indifferent_access).to include(
                    {
                        deposit: 110,
                        spent: 110,
                        change: 0,
                        change_result: [0,0,0,0,0],
                    }
                )
            end
            
            it "gives correct change using greedy algorithm" do                    
                login_user(user)
                user.update(deposit: 500)
                product.update(amount_available: 3)

                post  :buy, params: {product_id: product.id, quantity: 3}

                expect(response).to be_successful
                
                expect(JSON.parse(response.body).with_indifferent_access).to include(
                    {
                        deposit: 500,
                        spent: 165,
                        change: 335,
                        change_result: [3,0,1,1,1],
                    }
                )
            end                       
        end 
        
        context "without login" do
            it "requires authentication to perform action" do
                get  :reset, params: {}

                expect(response.status).to eq(401)
            end
        end
    end   
    
    describe "Delete #destroy" do
        context "when user is logged in" do
            let(:user) { FactoryBot.create(:user)}

            it "deletes user" do
                login_user(user)
                delete :destroy, params: {}

                expect(response).to be_successful
                expect(JSON.parse(response.body)["message"]).to eq("Deleted User")            
            end          
        end    
        
        context "without login" do
            it "requires authentication to perform action" do
                delete :destroy, params: {}

                expect(response.status).to eq(401)
                
            end
        end
    end        
end


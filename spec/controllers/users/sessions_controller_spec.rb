require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
    before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    def login_user(user)
        sign_in user
    end

    #logout user (destroys session)
    describe "DELETE #destroy" do

        context "when user is not logged in" do
            let(:user) {  FactoryBot.create(:user) }

            it "returns unauthorized" do
                delete :destroy, params: { user: user}  
                expect(response.status).to eq(401)
                expect(JSON.parse(response.body)["message"]).to eq("Logged out failure.")
            end
        end

        context "when user is logged in" do
            let(:user) {  FactoryBot.create(:user) }

            it "logs out user" do
                login_user(user)
                delete :destroy, params: { user: user}  
                expect(response).to be_successful
                expect(JSON.parse(response.body)["message"]).to eq("Logged out.")
            end
        end        
    end
end


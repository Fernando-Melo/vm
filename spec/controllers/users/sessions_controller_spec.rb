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
        let(:user) {  FactoryBot.create(:user) }

        it "logs out user" do
            login_user(user)
            delete :destroy, params: { user: user}  
            expect(response).to be_successful
            expect(JSON.parse(response.body)["message"]).to eq("Logged out.")
        end
    end
end


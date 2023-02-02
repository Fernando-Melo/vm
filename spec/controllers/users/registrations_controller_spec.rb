require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
    before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    describe "Post #create" do

        context "registers user without login" do
            let(:user_params) {  { email: "fminf521min7273513hadthesad623@email.com", password: "fmin5", role: "seller", deposit: "5800"  } }

            it "signs up" do
                post :create, params: { user: user_params}  

                expect(response).to be_successful
                expect(JSON.parse(response.body)["message"]).to eq("Signed up.")
                expect(User.last.email).to eq(user_params[:email])
                expect(User.last.role).to eq(user_params[:role])
                expect(User.last.deposit).to eq(user_params[:deposit].to_i)
            end
        end
    end
end


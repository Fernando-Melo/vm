FactoryBot.define do
    factory :user do
        email { Faker::Internet.email }
        password {"qwerty"}
    end

    factory :admin, parent: :user do
        role { "admin" }
    end

    factory :seller, parent: :user do
        role { "seller" }
    end

    factory :product do
        amount_available { 2 }
        cost { 105 }
        product_name { Faker::Beer.name}
        association :seller, factory: :seller
    end    
end

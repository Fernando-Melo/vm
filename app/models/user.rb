class User < ApplicationRecord
  include Users::AllowList

  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         jwt_revocation_strategy: self

  enum role: [ :buyer, :seller, :admin ]      
end

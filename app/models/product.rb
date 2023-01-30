class Product < ApplicationRecord
    belongs_to :seller, class_name: "User"
    validate :cost_multiple_five

 def cost_multiple_five
    errors.add(:cost, "must be in multiples of 5") unless cost % 5 == 0
 end
end
  
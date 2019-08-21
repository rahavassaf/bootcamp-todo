class Task < ApplicationRecord
	belongs_to :user
	validates :title, presence: true, length: {maximum: 100, minimum: 3}
end

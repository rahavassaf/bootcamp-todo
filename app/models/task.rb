class Task < ApplicationRecord
	validates :title, presence: true, length: {maximum: 100, minimum: 3}
end

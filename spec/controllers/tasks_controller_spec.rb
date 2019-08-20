require 'rails_helper'

RSpec.describe TasksController, type: :controller do
	describe 'tasks#index' do
		it "should list the tasks in the database" do
			task1 = FactoryBot.create(:task)
			task2 = FactoryBot.create(:task)
			get :index

			expect(response).to have_http_status :success
			response_value = ActiveSupport::JSON.decode(@response.body)
			expect(response_value.count).to eq(2)
		end

		it "should list the tasks in a consistent order" do
			task1 = FactoryBot.create(:task)
			task2 = FactoryBot.create(:task)
			
			get :index
			expect(response).to have_http_status :success
			response_ids = ActiveSupport::JSON.decode(@response.body).pluck('id')
			expect(response_ids).to eq([task1.id, task2.id])

			task2.update_attributes(title: 'something else')

			get :index
			expect(response).to have_http_status :success
			response_ids = ActiveSupport::JSON.decode(@response.body).pluck('id')
			expect(response_ids).to eq([task1.id, task2.id])
		end
	end

	describe 'task#update' do
		it "should allow tasks to be marked as done" do
			task = FactoryBot.create(:task)

			expect(task.done).to eq(false)

			put :update, params: {id: task.id, task: {done: true}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.done).to eq(true)
		end

		it "should allow tasks to be marked as not-done" do
			task = FactoryBot.create(:task, {done: true})

			expect(task.done).to eq(true)

			put :update, params: {id: task.id, task: {done: false}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.done).to eq(false)
		end

		it "should require the a user be signed-in" do
		end

		it "should require the a user own the task" do
		end

		it "should return 404 for non-existent task" do
			put :update, params: {id: 0, task: {done: true}}

			expect(response).to have_http_status :not_found
		end

		it "should reject invalid tasks" do
		end
	end
end

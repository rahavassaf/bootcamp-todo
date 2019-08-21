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
			task = FactoryBot.create(:task, {title: 'Valid title'})

			put :update, params: {id: task.id, task: {title: '#'*2}}
			expect(response).to have_http_status :unprocessable_entity
			
			task.reload
			expect(task.title).to eq('Valid title')

			put :update, params: {id: task.id, task: {title: '#'*101}}
			expect(response).to have_http_status :unprocessable_entity
			
			task.reload
			expect(task.title).to eq('Valid title')
		end

		it "should accept valid tasks" do
			task = FactoryBot.create(:task)

			put :update, params: {id: task.id, task: {title: '#'*3}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.title).to eq('#'*3)

			put :update, params: {id: task.id, task: {title: '#'*100}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.title).to eq('#'*100)
		end
	end

	describe 'task#create' do
		it "should allow new tasks to be created" do
			post :create, params: {task: {title: 'Fix things'}}
			expect(response).to have_http_status :success

			response_value = ActiveSupport::JSON.decode(@response.body)
			expect(response_value['title']).to eq('Fix things')

			expect(Task.last.title).to eq('Fix things')
		end

		it "should require the a user be signed-in" do
		end

		it "should reject invalid tasks" do
			post :create, params: {task: {title: '#'*2}}
			expect(response).to have_http_status :unprocessable_entity

			post :create, params: {task: {title: '#'*101}}
			expect(response).to have_http_status :unprocessable_entity

			expect(Task.all.length).to eq(0)
		end

		it "should accept valid tasks" do
			post :create, params: {task: {title: '#'*3}}
			expect(response).to have_http_status :success

			post :create, params: {task: {title: '#'*100}}
			expect(response).to have_http_status :success

			expect(Task.all.length).to eq(2)
		end
	end
end

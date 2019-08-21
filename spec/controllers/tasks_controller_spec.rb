require 'rails_helper'

RSpec.describe TasksController, type: :controller do
	describe 'tasks#index' do
		it "should list the tasks in the database" do
			user = FactoryBot.create(:user)
			sign_in user

			task1 = FactoryBot.create(:task, {user: user})
			task2 = FactoryBot.create(:task, {user: user})
			get :index

			expect(response).to have_http_status :success
			response_value = ActiveSupport::JSON.decode(@response.body)
			expect(response_value.count).to eq(2)
		end

		it "should list the tasks in a consistent order" do
			user = FactoryBot.create(:user)
			sign_in user

			task1 = FactoryBot.create(:task, {user: user})
			task2 = FactoryBot.create(:task, {user: user})
			
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

		it "should require the user be signed in" do
			get :index
			expect(response).to redirect_to new_user_session_path
		end
	end

	describe 'task#update' do
		it "should allow tasks to be marked as done" do
			user = FactoryBot.create(:user)
			sign_in user

			task = FactoryBot.create(:task, {user: user})

			expect(task.done).to eq(false)

			put :update, params: {id: task.id, task: {done: true}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.done).to eq(true)
		end

		it "should allow tasks to be marked as not-done" do
			user = FactoryBot.create(:user)
			sign_in user

			task = FactoryBot.create(:task, {done: true, user: user})

			expect(task.done).to eq(true)

			put :update, params: {id: task.id, task: {done: false}}
			expect(response).to have_http_status :success
			
			task.reload
			expect(task.done).to eq(false)
		end

		it "should require the user be signed-in" do
			user = FactoryBot.create(:user)
			task = FactoryBot.create(:task, {user: user})
			put :update, params: {id: task.id, task: {done: false}}
			expect(response).to redirect_to new_user_session_path
		end

		it "should require the user own the task" do
			user1 = FactoryBot.create(:user)
			task = FactoryBot.create(:task, {user: user1})

			user2 = FactoryBot.create(:user)
			sign_in user2

			put :update, params: {id: task.id, task: {done: false}}
			expect(response).to have_http_status :unauthorized
		end

		it "should return 404 for non-existent task" do
			user = FactoryBot.create(:user)
			sign_in user

			put :update, params: {id: 0, task: {done: true}}

			expect(response).to have_http_status :not_found
		end

		it "should reject invalid tasks" do
			user = FactoryBot.create(:user)
			sign_in user

			task = FactoryBot.create(:task, {title: 'Valid title', user: user})

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
			user = FactoryBot.create(:user)
			sign_in user

			task = FactoryBot.create(:task, {user: user})

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
			user = FactoryBot.create(:user)
			sign_in user

			post :create, params: {task: {title: 'Fix things'}}
			expect(response).to have_http_status :success

			response_value = ActiveSupport::JSON.decode(@response.body)
			expect(response_value['title']).to eq('Fix things')

			expect(Task.last.title).to eq('Fix things')
		end

		it "should require the user be signed-in" do
			post :create, params: {task: {title: 'Fix things'}}
			expect(response).to redirect_to new_user_session_path
		end

		it "should reject invalid tasks" do
			user = FactoryBot.create(:user)
			sign_in user

			post :create, params: {task: {title: '#'*2}}
			expect(response).to have_http_status :unprocessable_entity

			post :create, params: {task: {title: '#'*101}}
			expect(response).to have_http_status :unprocessable_entity

			expect(Task.all.length).to eq(0)
		end

		it "should accept valid tasks" do
			user = FactoryBot.create(:user)
			sign_in user

			post :create, params: {task: {title: '#'*3}}
			expect(response).to have_http_status :success

			post :create, params: {task: {title: '#'*100}}
			expect(response).to have_http_status :success

			expect(Task.all.length).to eq(2)
		end
	end
end

class TasksController < ApplicationController
	before_action :authenticate_user!

	def index
		render json: current_user.tasks.order(:id)
	end

	def update
		begin
			task = Task.find(params[:id])
		rescue
			return render plain: 'Not Found',  status: :not_found
		end

		if task.user != current_user
			return render plain: 'Unauthorized', status: :unauthorized
		end

		task.update_attributes(task_params)
		
		if task.invalid?
			render plain: 'Unprocessable', status: :unprocessable_entity
		else
			render json: task
		end
	end

	def create
		task = current_user.tasks.create(task_params)

		if task.invalid?
			render plain: 'Unprocessable', status: :unprocessable_entity
		else
			render json: task
		end
	end

	private

	def task_params
		params.require(:task).permit(:done, :title)
	end
end

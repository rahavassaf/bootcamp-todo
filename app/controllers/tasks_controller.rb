class TasksController < ApplicationController
	def index
		render json: Task.order(:id)
	end

	def update
		begin
			task = Task.find(params[:id])
		rescue
			return render plain: 'Not Found',  status: :not_found
		end

		task.update_attributes(task_params)
		
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

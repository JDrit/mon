class UsersController < ApplicationController
    before_action :signed_in_user

    def new
        @users = User.all
        @computers = Computer.all
        @new_user = User.new
    end
    
    def edit
        @new_user = User.find_by_id(params[:id])
        @computers = Computer.all
    end

    def update
        @computers = Computer.all
        @new_user = User.find_by_id(params[:id])
        if @new_user.update_attributes(user_params)
            flash[:success] = "User Updated"
            redirect_to edit_user_path @new_user
        else
            flash[:danger] = "Could not update user"
            render "edit"
        end
    end


    def create
        @new_user = User.new(user_params)
        if @new_user.save
            flash[:success] = "User successfully created"
            redirect_to new_user_path
        else
            @computers = Computer.all
            @users = User.all
            flash[:danger] = "Could not create User"
            render "new"
        end
    end

    def destroy
        User.find_by_id(params[:id]).destroy
        flash[:success] = "User Deleted"
        redirect_to new_user_path
    end


    private
        def user_params
            params.require(:user).permit(:name, :email, :password, :password_confirmation)
        end
end

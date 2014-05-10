class WatchdogsController < ApplicationController
    before_action :signed_in_user

    def index
        @watchdogs = Watchdog.where(user: @current_user) 
    end

    def new
        @watchdog = Watchdog.new
    end

    def create
        computer_id = params[:watchdog][:computer_id]
        @watchdog = Watchdog.new(watchdog_params)
        @watchdog.user = @current_user
        @watchdog.computer = Computer.find(computer_id)
        if @watchdog.save
            flash[:success] = "watchdog successfully created"
            redirect_to @watchdog
        else
            flash[:error] = "Could not create watchdog"
            render action: "new"
        end
    end

    def delete
        watchdog = Watchdog.where(id: params[:id], user: @current_user).first
        if watchdog == nil
            flash[:error] = "watchdog does not exist"
        else
            flash[:success] = "watchdog successfully deleted"
        end
        redirect_to watchdogs_url
    end

    def show
        @watchdog = Watchdog.where(id: params[:id], user: @current_user).first
        if @watchdog == nil
            flash[:error] = "watchdog does not exist"
        end
    end

    def edit
        @watchdog = Watchdog.where(id: params[:id], user: @current_user).first
        if @watchdog == nil
            flash[:error] = "watchdog does not exist"
            redirect_to watchdogs_url
        end
    end

    def update
        @watchdog = watchdog.where(id: params[:id], user: @current_user).first
        if @watchdog == nil
            flash[:error] = "watchdog does not exist"
            redirect_to watchdogs_url
        elsif @watchdog.update_attributes(watchdog_params)
            redirect_to @watchdog
        else
            flash[:error] = "could not update watchdog"
            render action: "edit"
        end
    end

    private
        def watchdog_params
            params.require(:watchdog).permit(:cpu_load, :memory_usage, :disk_read,
                                            :disk_write, :rx, :tx, :disk_percentage_left)
        end
end

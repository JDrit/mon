class WatchdogsController < ApplicationController
    before_action :signed_in_user

    def index
        @watchdogs = @current_user.watchdogs
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
            redirect_to watchdogs_url
        else
            flash[:danger] = "Could not create watchdog"
            render action: "new"
        end
    end

    def destroy
        watchdog = @current_user.watchdogs.find(params[:id])
        if watchdog == nil
            flash[:danger] = "watchdog does not exist"
        else
            watchdog.destroy
            flash[:success] = "watchdog successfully deleted"
        end
        redirect_to watchdogs_url
    end

    def show
        @watchdog = @current_user.watchdogs.find(params[:id])
        if @watchdog == nil
            flash[:danger] = "watchdog does not exist"
        end
    end

    def edit
        @watchdog = @current_user.watchdogs.find(params[:id])
        if @watchdog == nil
            flash[:danger] = "watchdog does not exist"
            redirect_to watchdogs_url
        end
    end

    def update
        @watchdog = @current_user.watchdogs.find(params[:id])
        if @watchdog == nil
            flash[:danger] = "watchdog does not exist"
            redirect_to watchdogs_url
        elsif @watchdog.update_attributes(watchdog_params)
            flash[:success] = "Watchdog successfully updated"
            redirect_to watchdogs_url
        else
            flash[:danger] = "could not update watchdog"
            render action: "edit"
        end
    end

    private
        def watchdog_params
            params.require(:watchdog).permit(:cpu_load, :memory_usage, :disk_read,
                                             :disk_write, :rx, :tx, :disk_percentage_left)
        end
end

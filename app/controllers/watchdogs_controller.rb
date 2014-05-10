class WatchdogsController < ApplicationController
    before_action :signed_in_user

    def index
        @watchdogs = Watchdog.where(user: @current_user) 
    end

    def create

    end

    def delete

    end

    def edit

    end
end

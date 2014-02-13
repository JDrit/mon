class ApiController < ApplicationController
    before_action :validate_api_key
    
    def add_entry
        date = Time.now.getutc.to_i
        @current_computer.uptime = params[:uptime]
        @current_computer.save
        stat = @current_computer.stats.new(timestamp: date, 
                                           load_average: params[:load_average],
                                           memory_usage: params[:memory_usage],
                                           network_up: 1, network_down: 1)
        render :json => {:status => "error"} if !stat.save
        params[:disks].each do |disk_params|
            disk = @current_computer.disks.new(timestamp: date, 
                                               name: disk_params[:name], 
                                               read: disk_params[:read], 
                                               write: disk_params[:write])
            render :json => {:status => "error"} if !disk.save
        end
        params[:programs].each do |program_params|
            program = @current_computer.programs.new(timestamp: date,
                                 name: program_params[:name],
                                 load_usage: program_params[:load_usage],
                                 memory_usage: program_params[:memory_usage])
            render :json => {:status => "error"} if !program.save
        end
        params[:partitions].each do |partition_params|
            partition = @current_computer.partitions.new(timestamp: date,
                                                name: partition_params[:name],
                                                cap: partition_params[:cap],
                                                usage: partition_params[:usage])
            render :json => {:status => "error"} if !partition.save
        end
        params[:interfaces].each do |interface_params|
            interface = @current_computer.interfaces.new(timestamp: date,
                                                name: interface_params[:name],
                                                rx: interface_params[:rx],
                                                tx: interface_params[:tx])
            render :json => {:status => "error"} if !interface.save
        end
        render :json => {:status => "success"}
    end

    def verified_request?
        if request.content_type == "application/json"
            true
        else
            super()
        end
    end

    private
    def validate_api_key
        @current_computer = Computer.find_by api_key: params[:api_key].to_s
        if @current_computer == nil
            render :json => { :error => "invalid api key" }
        end
    end
end

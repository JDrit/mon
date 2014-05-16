class ApiController < ApplicationController
    before_action :validate_api_key
    
    def add_entry
        date = Time.now.getutc.to_i
        sql_error = false
        ActiveRecord::Base.transaction do
            begin
                @current_computer.uptime = params[:uptime]
                @current_computer.save!
                current_read = current_write = current_rx = current_rx = 0
                disk_usage = disk_cap = 0
                stat = @current_computer.stats.create!(timestamp: date, 
                                                   load_average: params[:load_average],
                                                   memory_usage: params[:memory_usage],
                                                   network_up: 1, network_down: 1)
                params[:disks].each do |disk_params|
                    disk = @current_computer.disks.create!(timestamp: date, 
                                                       name: disk_params[:name], 
                                                       read: disk_params[:read], 
                                                       write: disk_params[:write])
                    current_read += disk_params[:read]
                    current_write += disk_params[:write]
                end
                params[:programs].each do |program_params|
                    program = @current_computer.programs.create!(timestamp: date,
                                         name: program_params[:name],
                                         load_usage: program_params[:load_usage],
                                         memory_usage: program_params[:memory_usage],
                                         user: program_params[:user], 
                                         read: program_params[:read],
                                         write: program_params[:write])
                end
                params[:partitions].each do |partition_params|
                    partition = @current_computer.partitions.create!(timestamp: date,
                                                        name: partition_params[:name],
                                                        cap: partition_params[:cap],
                                                        usage: partition_params[:usage])
                    disk_usage += partition_params[:usage]
                    disk_cap += partition_params[:cap]
                end
                params[:interfaces].each do |interface_params|
                    interface = @current_computer.interfaces.create!(timestamp: date,
                                                        name: interface_params[:name],
                                                        rx: interface_params[:rx],
                                                        tx: interface_params[:tx])
                    current_rx = interface_params[:rx]
                    current_tx = interface_params[:tx]
                end
                notifications = [] 
                Rails.logger.info ENV
                @current_computer.watchdogs.each do |watchdog|
                    if watchdog.cpu_load != nil && 
                        stat.load_average >= watchdog.cpu_load
                        notifications << "load average hit #{stat.load_average}"
                    end
                    if watchdog.memory_usage != nil &&
                        stat.memory_usage >= watchdog.memory_usage
                        notifications << "memory usage hit #{display_memory stat.memory_usage}"
                    end
                    if watchdog.disk_read != nil &&
                        current_read >= watchdog.disk_read
                        notifications << "disk read hit #{display_speed current_read}"
                    end
                    if watchdog.disk_write && 
                        current_write >= watchdog.disk_write
                        notifications << "disk writes hit #{display_speed current_writes}"
                    end
                    if watchdog.rx != nil && 
                        current_rx >= watchdog.rx
                        notifications << "incoming traffic hit #{display_speed current_rx}"
                    end
                    if watchdog.tx != nil && 
                        current_tx >= watchdog.tx
                        notifications << "outgoing traffic hit #{display_speed current_tx}"

                    end
                    if watchdog.disk_percentage_left != nil && 
                        (disk_usage.to_f / disk_cap.to_f) * 100 >= watchdog.disk_percentage_left
                        notifications << "disk usage is now at #{((disk_usage.to_f / disk_cap.to_f) * 100).round(2)}%"
                    end
                    WatchdogMailer.notification(watchdog, notifications).deliver if notifications.length != 0

                end
                
                render :json => {:status => "success"} 
            rescue Exception => e
                Rails.logger.info e
                sql_error = true
                render :json => {:status => "error"}
            end
            Rails.logger.info sql_error
            raise ActiveRecord::Rollback if sql_error
        end

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
        Rails.logger.info params
        Rails.logger.info "test"
        @current_computer = Computer.find_by api_key: params[:api_key].to_s
        if @current_computer == nil
            render :json => { :error => "invalid api key" }
        end
    end

    def display_memory(mem)
        if mem.to_i > 1024 * 1024
            return (mem.to_f / 1024 / 1024).round(2).to_s + "GB"
        elsif mem.to_i > 1024
            return (mem.to_f / 1024).round(2).to_s + "MB"
        else
            return mem.to_i.round(2).to_s + "KB"
        end
    end

    def display_speed(bytes)
        if bytes > 1024 * 1024 * 1024
            return (bytes.to_f / 1024 / 1024 / 1024).round(2).to_s + "GB/s"
        elsif bytes > 1024 * 1024
            return (bytes.to_f / 1024 / 1024).round(2).to_s + "MB/s"
        elsif bytes > 1024
            return (bytes.to_f / 1024).round(2).to_s + "KB/s"
        else
            return bytes.to_s + "B/s"
        end
    end

end

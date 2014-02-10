class ComputersController < ApplicationController
    before_action :signed_in_user
    before_action :get_computer

    def show
        @computers = Computer.all
        if @current_computer.stats.length > 0
            date = @current_computer.stats.last.timestamp
            @programs = @current_computer.programs.where(timestamp: date).order("load_usage desc")
        else
            @programs = []
        end
    end

    def disks
        @computers = Computer.all
    end

    def index
        @computers = Computer.all
        @computers.each do |computer|
            stat = computer.stats.last 
            if !stat.nil?
                computer.load_avg = stat.load_average
                computer.mem_usage = stat.memory_usage 
                computer.disk_cap = computer.partitions.sum(:cap, :conditions => 
                                                            { :timestamp => stat.timestamp })
                computer.disk_usage = computer.partitions.sum(:usage, :conditions => 
                                                              { :timestamp => stat.timestamp })
            end
        end
    end


    # Below are all the json calls for gettings the stats for a given computer
    def get_stats
        cpu = []
        mem = []
        @current_computer.stats.select("timestamp, load_average, 
                                       memory_usage").order(:timestamp).each do |stat|
            cpu << [stat.timestamp * 1000, stat.load_average.to_f]
            mem << [stat.timestamp * 1000, stat.memory_usage.to_i / 1024]
        end
        render :json => {cpu: cpu, mem: mem}
    end

    def get_partitions
        partitions = Hash.new
        @current_computer.partitions.select("timestamp, name, usage").order(:timestamp).each do |partition|
            partitions[partition.name] = [] if partitions[partition.name] == nil
            partitions[partition.name] << [partition.timestamp * 1000, 
                                    partition.usage.to_f / 1024 / 1024]
        end
        render :json => partitions
    end

    def get_disk_reads
        disk_reads = Hash.new
        @current_computer.disks.select("timestamp, name, read, write").order(:timestamp).each do |disk|
            disk_reads[disk.name] = [] if disk_reads[disk.name] == nil
            disk_reads[disk.name] << [disk.timestamp * 1000, disk.read.to_i]
        end
        render :json => disk_reads
    end

    def get_disk_writes
        disk_writes = Hash.new
        @current_computer.disks.select("timestamp, name, read, write").order(:timestamp).each do |disk|
            disk_writes[disk.name] = [] if disk_writes[disk.name] == nil
            disk_writes[disk.name] << [disk.timestamp * 1000, disk.write.to_i]
        end
        render :json => disk_writes
    end

    def get_interfaces_rx
        interfaces_rx = Hash.new
        @current_computer.interfaces.order(:timestamp).each do |interface|
            interfaces_rx[interface.name] = [] if interfaces_rx[interface.name] == nil
            interfaces_rx[interface.name] << [interface.timestamp * 1000, interface.rx.to_i]
        end
        render :json => interfaces_rx
    end

    def get_interfaces_tx
        interfaces_tx = Hash.new
        @current_computer.interfaces.order(:timestamp).each do |interface|
            interfaces_tx[interface.name] = [] if interfaces_tx[interface.name] == nil
            interfaces_tx[interface.name] << [interface.timestamp * 1000, interface.tx.to_i]
        end
        render :json => interfaces_tx
    end

    def get_programs
        date = params[:date].to_i / 1000
        render :json => { programs: @current_computer.programs.where(timestamp: date).order('load_usage desc') , 
                          date: date.to_f }
    end
    
    private
        def get_computer
            @id = params['id']
            @current_computer = Computer.find_by_id(@id)
        end

    
end

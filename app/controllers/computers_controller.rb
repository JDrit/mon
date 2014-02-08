class ComputersController < ApplicationController
    before_action :signed_in_user
    before_action :get_computer

    def show
        @computers = Computer.all
    end

    def disks
        @computers = Computer.all
    end

    def index
        @computers = Computer.all
        @computers.each do |computer|
            stat = computer.stats.last 
            computer.load_avg = stat.load_average
            computer.mem_usage = stat.memory_usage
            computer.disk_cap = computer.partitions.sum(:cap, :conditions => 
                                                        { :created_at => stat.created_at  })
            computer.disk_usage = computer.partitions.sum(:usage, :conditions => 
                                                          { :created_at => stat.created_at })
        end
    end


    # Below are all the json calls for gettings the stats for a given computer
    def get_stats
        cpu = []
        mem = []
        @current_computer.stats.select("created_at, load_average, 
                                       memory_usage").each do |stat|
            cpu << [stat.created_at.to_i * 1000, stat.load_average.to_f]
            mem << [stat.created_at.to_i * 1000, stat.memory_usage.to_i / 1024]
        end
        render :json => {cpu: cpu, mem: mem}
    end

    def get_partitions
        partitions = Hash.new
        @current_computer.partitions.select("created_at, name, usage").each do |partition|
            partitions[partition.name] = [] if partitions[partition.name] == nil
            partitions[partition.name] << [partition.created_at.to_i * 1000, 
                                    partition.usage.to_f / 1024 / 1024]
        end
        render :json => partitions
    end

    def get_disk_reads
        disk_reads = Hash.new
        @current_computer.disks.select("created_at, name, read, write").each do |disk|
            disk_reads[disk.name] = [] if disk_reads[disk.name] == nil
            disk_reads[disk.name] << [disk.created_at.to_i * 1000, disk.read.to_i]
        end
        render :json => disk_reads
    end

    def get_disk_writes
        disk_writes = Hash.new
        @current_computer.disks.select("created_at, name, read, write").each do |disk|
            disk_writes[disk.name] = [] if disk_writes[disk.name] == nil
            disk_writes[disk.name] << [disk.created_at.to_i * 1000, disk.write.to_i]
        end
        render :json => disk_writes
    end

    def get_interfaces_rx
        interfaces_rx = Hash.new
        @current_computer.interfaces.each do |interface|
            interfaces_rx[interface.name] = [] if interfaces_rx[interface.name] == nil
            interfaces_rx[interface.name] << [interface.created_at.to_i * 1000, interface.rx.to_i]
        end
        render :json => interfaces_rx
    end

    def get_interfaces_tx
        interfaces_tx = Hash.new
        @current_computer.interfaces.each do |interface|
            interfaces_tx[interface.name] = [] if interfaces_tx[interface.name] == nil
            interfaces_tx[interface.name] << [interface.created_at.to_i * 1000, interface.tx.to_i]
        end
        render :json => interfaces_tx
    end
    
    private
        def get_computer
            @id = params['id']
            @current_computer = Computer.find_by_id(@id)
        end

    
end

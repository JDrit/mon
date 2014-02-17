class ComputersController < ApplicationController
    before_action :signed_in_user
    before_action :get_computer

    def show
        @computers = Computer.all
        if @current_computer.stats.length > 0
            date = @current_computer.stats.last.timestamp
            @programs = []
            @current_computer.programs.where(timestamp: date)
                .order("load_usage desc, memory_usage desc").limit(20)
                .each do |program|
                    program.name = program.name.truncate 40
                    @programs << program
            end
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
                computer.load_avg = stat.load_average.to_f
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

    # gets the programs running at the given time. The interval is needed 
    # since highcharts groups the data points.
    # :date = the timestamp for the stat
    # :interval = the interval to search
    # :sort = what to order by cpu, or mem
    def get_programs
        date = params[:date].to_i / 1000
        interval = params[:interval].to_i / 1000
        if params[:sort] == "cpu"
            sort = "load_usage"
            sort2 = "memory_usage"
        elsif params[:sort] == "mem"
            sort = "memory_usage"
            sort2 = "load_usage"
        elsif params[:sort] == "read"
            sort = "read"
            sort2 = "write"
        else
            sort = "write"
            sort2 = "read"
        end
        programs = @current_computer.programs.where(
            timestamp: (date - interval)..(date + interval))
            .order("timestamp, #{sort} desc, #{sort2} desc").limit(20)
        return_data = []
        programs.each do |program|
            if program.timestamp == programs[0].timestamp
                program.name = program.name.truncate 40
                return_data << program
            else
                break
            end
        end
        render :json => { programs: return_data, date: date }
    end
    
    private
        def get_computer
            @id = params['id']
            @current_computer = Computer.find_by_id(@id)
        end

    
end

class ComputersController < ApplicationController
    before_action :signed_in_user
    before_action :get_computer, except: [:index, :create, :new]
    @@time_range = 1.week.ago

    def new
        @computers = Computer.all
        @new_computer = Computer.new
    end

    def edit
        @computers = Computer.all
    end

    def update
        @computers = Computer.all
        if @current_computer.update_attributes(computer_params)
            flash[:success] = "Computer Updated"
            redirect_to edit_computer_path @current_computer
        else
            flash[:danger] = "Could not update computer"
            render "edit"
        end
    end

    def destroy
        @current_computer.destroy
        flash[:success] = "Computer Deleted"
        redirect_to new_computer_path
    end

    def create
        @new_computer = Computer.new(computer_params)
        if @new_computer.save
            flash[:success] = "Computer successfully created"
            redirect_to new_computer_path
        else
            @computers = Computer.all
            flash[:danger] = "Could not create computer"
            render "new"
        end
    end

    def show
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
        last_timestamp = @@time_range
        @current_computer.stats.select("timestamp, load_average, memory_usage, created_at")
                .where("created_at >= ?", @@time_range)
                .order(:timestamp).each do |stat|
            # deals with empty values
            while stat.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                cpu << [last_timestamp.to_i * 1000, nil]
                mem << [last_timestamp.to_i * 1000, nil]
            end
            last_timestamp = stat.created_at
            cpu << [stat.timestamp * 1000, stat.load_average.to_f]
            mem << [stat.timestamp * 1000, stat.memory_usage.to_i / 1024]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            cpu << [last_timestamp.to_i * 1000, nil]
            mem << [last_timestamp.to_i * 1000, nil]
        end
        render :json => {cpu: cpu, mem: mem}
    end

    def get_stats_current
        stat = @current_computer.stats.last
        if stat.created_at < 5.minutes.ago
            render :json => { timestamp: Time.now.to_i * 1000, 
                              cpu: nil, 
                              mem: nil }
        else
            render :json => { timestamp: stat.timestamp * 1000, 
                              cpu: stat.load_average.to_f, 
                              mem: stat.memory_usage.to_i / 1024 }
        end
    end

    def get_partitions
        partitions = Hash.new
        last_timestamp = @@time_range
        @current_computer.partitions.select("timestamp, name, usage, created_at")
                .where("created_at >= ?", @@time_range)
                .order(:timestamp, :name).each do |partition|
            while partition.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                partitions.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
            end
            last_timestamp = partition.created_at
            partitions[partition.name] = [] if partitions[partition.name] == nil
            partitions[partition.name] << [partition.timestamp * 1000, 
                                    partition.usage.to_f / 1024 / 1024]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            partitions.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
        end
        render :json => partitions
    end

    def get_partitions_current
        timestamp = @current_computer.stats.last.timestamp
        data = Hash.new
        data[:timestamp] = (timestamp < 5.minutes.ago) ? Time.now.to_i * 1000 : timestamp * 1000
        @current_computer.partitions.where(timestamp: timestamp).order(:name).each do |partition|
            data[partition.name] = (timestamp < 5.minutes.ago) ? nil : partition.usage.to_f / 1024 / 1024
        end
        render :json => data
    end

    def get_disk_reads
        disk_reads = Hash.new
        last_timestamp = @@time_range
        @current_computer.disks.select("timestamp, name, read, write, created_at")
                .where("created_at >= ?", @@time_range)
                .order(:timestamp, :name).each do |disk|
            while disk.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                disk_reads.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
            end
            last_timestamp = disk.created_at 
            disk_reads[disk.name] = [] if disk_reads[disk.name] == nil
            disk_reads[disk.name] << [disk.timestamp * 1000, disk.read.to_i]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            disk_reads.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
        end 
        render :json => disk_reads
    end

    def get_disk_reads_current
        timestamp = @current_computer.stats.last.timestamp
        data = Hash.new
        data[:timestamp] = (timestamp < 5.minutes.ago) ? Time.now.to_i * 1000 : timestamp * 1000
        @current_computer.disks.where(timestamp: timestamp).order(:name).each do |disk|
            data[disk.name] = (timestamp < 5.minutes.ago) ? nil : disk.read.to_i
        end
        render :json => data
    end

    def get_disk_writes
        disk_writes = Hash.new
        last_timestamp = @@time_range
        @current_computer.disks.select("timestamp, name, read, write, created_at")
                .where("created_at >= ?", @@time_range)
                .order(:timestamp, :name).each do |disk|
            while disk.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                disk_writes.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
            end
            last_timestamp = disk.created_at
            disk_writes[disk.name] = [] if disk_writes[disk.name] == nil
            disk_writes[disk.name] << [disk.timestamp * 1000, disk.write.to_i]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            disk_writes.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
        end
        render :json => disk_writes
    end

    def get_disk_writes_current
        timestamp = @current_computer.stats.last.timestamp
        data = Hash.new
        data[:timestamp] = (timestamp < 5.minutes.ago) ? Time.now.to_i * 1000 : timestamp * 1000
        @current_computer.disks.where(timestamp: timestamp).order(:name).each do |disk|
            data[disk.name] = disk.write.to_i
        end
        render :json => data
    end

    def get_interfaces_rx
        interfaces_rx = Hash.new
        last_timestamp = @@time_range
        @current_computer.interfaces.where("created_at >= ?", @@time_range)
                .order(:timestamp, :name).each do |interface|
            while interface.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                interfaces_rx.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
            end 
            last_timestamp = interface.created_at
            interfaces_rx[interface.name] = [] if interfaces_rx[interface.name] == nil
            interfaces_rx[interface.name] << [interface.timestamp * 1000, interface.rx.to_i * 8]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            interfaces_rx.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
        end
        render :json => interfaces_rx
    end

    def get_interfaces_rx_current
        timestamp = @current_computer.stats.last.timestamp
        data = Hash.new
        data[:timestamp] = (timestamp < 5.minutes.ago) ? Time.now.to_i * 1000 : timestamp * 1000
        @current_computer.interfaces.where(timestamp: timestamp).order(:name).each do |interface|
            data[interface.name] = (timestamp < 5.minutes.ago) ? nil : interface.rx.to_i * 8
        end
        render :json => data
    end

    def get_interfaces_tx
        interfaces_tx = Hash.new
        last_timestamp = @@time_range
        @current_computer.interfaces.where("created_at >= ?", @@time_range)
                .order(:timestamp, :name).each do |interface|
            while interface.created_at - last_timestamp > 5.minutes
                last_timestamp += 5.minutes
                interfaces_tx.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
            end
            last_timestamp = interface.created_at
            interfaces_tx[interface.name] = [] if interfaces_tx[interface.name] == nil
            interfaces_tx[interface.name] << [interface.timestamp * 1000, interface.tx.to_i * 8]
        end
        while last_timestamp < 5.minutes.ago
            last_timestamp += 5.minutes
            interfaces_tx.each { |name, data| data << [last_timestamp.to_i * 1000, nil] }
        end
        render :json => interfaces_tx
    end

    def get_interfaces_tx_current
        timestamp = @current_computer.stats.last.timestamp
        data = Hash.new
        data[:timestamp] = (timestamp < 5.minutes.ago) ? Time.now.to_i * 1000 : timestamp * 1000
        @current_computer.interfaces.where(timestamp: timestamp).order(:name).each do |interface|
            data[interface.name] = (timestamp < 5.minutes.ago) ? nil : interface.tx.to_i * 8
        end
        render :json => data
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
        def computer_params
            params.require(:computer).permit(:name, :api_key)
        end

        def get_computer
            @id = params['id']
            @current_computer = Computer.find_by_id(@id)
            if @current_computer == nil
                flash[:danger] = "Computer does not exist"
                redirect_to action: "index" 
            end
        end
end

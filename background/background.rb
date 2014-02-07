#!/usr/bin/ruby

require 'open3'
require 'sys/filesystem'
include Sys
require 'net/http'
require 'uri'
require 'json'

def get_load_average
    load_avg = File.read("/proc/loadavg")
    return load_avg.split(/\s+/)[0].to_f
end

def get_memory_usage
    memory_usage = (File.read("/proc/meminfo").split(/\r?\n/)).map do |line| 
        (line.split(/\s+/))[1].to_i
    end
    return memory_usage[0] - memory_usage[1] - memory_usage[2] - memory_usage[3]
end

def get_partition_stats
    disks = []
    Filesystem.mounts do |mount|
        stat = Filesystem.stat mount.mount_point
        next if stat.block_size * stat.blocks_available / 1024 == 0 || 
            stat.filesystem_id == 0 || mount.name == "rootfs"
        disks << {name: mount.name, cap: stat.blocks * stat.block_size / 1024,
                  usage: stat.blocks * stat.block_size / 1024 - 
                         stat.block_size * stat.blocks_available / 1024}
    end
    return disks
end

def get_processes
    processes = []
    stdin, stdout, stderr = Open3.popen3("ps aux --sort -%cpu | head -n15")
    stdout.readlines.each do |line|
        line_split = line.split(/\s+/)
        next if line_split[0] == "USER"
        processes << {name: line_split[10], load_usage: line_split[2], 
                      memory_usage: line_split[3]}
    end
    return processes
end

def ticks
    File.open("/proc/uptime", "r").each_line do |line|
        return line.split(" ")[0].to_f
    end
end

def get_disks_sector_info
    data = Hash.new
    file = File.open("/proc/diskstats", "r")
    file.each_line do |line|
        next if line.length < 13
        line_split = line.split(" ")
        next if line_split[5] == "0" && line_split[9] == "0"
        name = line_split[2]
        data[name] = [line_split[5].to_i, line_split[9].to_i] 
    end
    return data, ticks()
end

def get_disk_stats
    b_sectors, b_time = get_disks_sector_info
    sleep(1)
    e_sectors, e_time = get_disks_sector_info
    return e_sectors.keys.map { |key| 
        {name: "/dev/" + key, 
         read: ((e_sectors[key][0] - b_sectors[key][0]) * 512 / (e_time - b_time)).to_i,
         write: ((e_sectors[key][1] - b_sectors[key][1]) * 512 / (e_time - b_time)).to_i } }
end

def get_interfaces_stats
    b_info, b_time = get_interfaces_info
    sleep(1)
    e_info, e_time = get_interfaces_info
    return e_info.keys.map { |key|
        {name: key,
        rx: ((e_info[key][0] - b_info[key][0]) / (e_time - b_time)).to_i, 
        tx: ((e_info[key][1] - b_info[key][1]) / (e_time - b_time)).to_i } }
end

def get_interfaces_info
    data = Hash.new
    file = File.open("/proc/net/dev")
    count = 0
    file.each_line do |line|
        count += 1
        next if count <= 2
        line_split = line.split(" ")
        name = line_split[0]
        data[name] = [line_split[1].to_i, line_split[9].to_i]
    end
    return data, ticks()
end

def background_thread api_key, interval
    uri = URI.parse("http://localhost:32400/api/add_entry")
    while true
        begin
            b_i_info, b_i_time = get_interfaces_info
            b_d_sectors, b_d_time = get_disks_sector_info
            sleep(5)
            e_i_info, e_i_time = get_interfaces_info
            e_d_sectors, e_d_time = get_disks_sector_info

            interface_data = e_i_info.keys.map { |key|
                {name: key,
                 rx: ((e_i_info[key][0] - b_i_info[key][0]) / (e_i_time - b_i_time)).to_i, 
                 tx: ((e_i_info[key][1] - b_i_info[key][1]) / (e_i_time - b_i_time)).to_i } }
            disk_data = e_d_sectors.keys.map { |key| 
                {name: "/dev/" + key, 
                 read: ((e_d_sectors[key][0] - b_d_sectors[key][0]) * 512 / (e_d_time - b_d_time)).to_i,
                 write: ((e_d_sectors[key][1] - b_d_sectors[key][1]) * 512 / (e_d_time - b_d_time)).to_i } }


            data = { "api_key" => api_key, 
                     "load_average" => get_load_average, 
                     "memory_usage" => get_memory_usage, 
                     "disks" => disk_data, 
                     "programs" => get_processes, 
                     "partitions" => get_partition_stats,
                     "interfaces" => interface_data }
            headers = { "Content-Type" => "application/json" }
            http = Net::HTTP.new(uri.host, uri.port)
            request = Net::HTTP::Post.new(uri.request_uri, headers)
            request.body = data.to_json
            response = http.request request
            puts response.body
            sleep interval
        rescue
            puts "error"
        end
    end
end


if __FILE__ == $0
    background_thread 1, 30
end

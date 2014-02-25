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
    return Filesystem.mounts.map do |mount|
        stat = Filesystem.stat mount.mount_point
        next if stat.block_size * stat.blocks_available / 1024 == 0 || 
            stat.filesystem_id == 0 || mount.name == "rootfs"
        { name: mount.name, cap: stat.blocks * stat.block_size / 1024,
          usage: stat.blocks * stat.block_size / 1024 - 
                 stat.block_size * stat.blocks_available / 1024 }
    end
end

def get_stats
    processes = Hash.new
    stdin, stdout, stderr = Open3.popen3("ps aux --sort -%cpu")
    stdout.readlines.each do |line|
        line_split = line.split(/\s+/)
        next if line_split[0] == "USER"
        cmd = line_split[10..line_split.length].join(" ")
        cmd = cmd[1..-2] if cmd[0] == "[" && cmd[-1] == "]"
        processes[cmd.strip] = { load_usage: line_split[2], 
                                 memory_usage: line_split[3], 
                                 user: line_split[0] }
    end
    return processes
end

def get_program_info
    programs = Hash.new
    Dir.entries("/proc").select {|f| !File.directory?(f) && f.match(/^(\d)+$/) }.each do |pid|
        cmd_line = File.read("/proc/" + pid + "/cmdline").gsub("\u0000", " ")[0..-2]
        cmd_line = File.read("/proc/" + pid + "/stat").split(" ")[1][1..-2] if cmd_line == ""
        lines = File.readlines("/proc/" + pid + "/io")
        programs[cmd_line.strip] = [lines[4].split(":")[1].to_i, lines[5].split(":")[1].to_i]
    end
    return programs, ticks()
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
        next if !(name[-1].match(/^(\d)+$/)) 
        data[name] = [line_split[5].to_i, line_split[9].to_i] 
    end
    return data, ticks()
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

def background_thread url, api_key, interval
    uri = URI.parse(url + "/api/add_entry")
    while true
        begin
            b_i_info, b_i_time = get_interfaces_info
            b_d_sectors, b_d_time = get_disks_sector_info
            b_program_io, b_program_time = get_program_info
            sleep(interval)
            e_i_info, e_i_time = get_interfaces_info
            e_d_sectors, e_d_time = get_disks_sector_info
            e_program_io, e_program_time = get_program_info
            program_stats = get_stats
            
            interface_data = e_i_info.keys.map { |key|
                { name: key,
                  rx: ((e_i_info[key][0] - b_i_info[key][0]) / (e_i_time - b_i_time)).to_i, 
                  tx: ((e_i_info[key][1] - b_i_info[key][1]) / (e_i_time - b_i_time)).to_i } }
            disk_data = e_d_sectors.keys.map { |key| 
                { name: "/dev/" + key, 
                  read: ((e_d_sectors[key][0] - b_d_sectors[key][0]) * 512 / (e_d_time - b_d_time)).to_i,
                  write: ((e_d_sectors[key][1] - b_d_sectors[key][1]) * 512 / (e_d_time - b_d_time)).to_i } }
            program_data = e_program_io.keys.map { |key|
                next if b_program_io[key] == nil
                { name: key, 
                  load_usage: program_stats[key][:load_usage],
                  memory_usage: program_stats[key][:memory_usage],
                  user: program_stats[key][:user],
                  read: ((e_program_io[key][0] - b_program_io[key][0]) / 
                         (e_program_time - b_program_time)).to_i,
                  write: ((e_program_io[key][1] - b_program_io[key][1]) / 
                         (e_program_time - b_program_time)).to_i } }
            
            data = { api_key: api_key, 
                     load_average: get_load_average, 
                     memory_usage: get_memory_usage, 
                     disks: disk_data, 
                     programs: program_data, 
                     partitions: get_partition_stats,
                     interfaces: interface_data,
                     uptime: ticks }
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
    raise 'Must run as root' unless Process.uid == 0
    if ARGV.length != 3
        puts "run: #{__FILE__} [url] [computer api token] [interval]"
    else
        background_thread ARGV[0], ARGV[1].to_i, ARGV[2].to_i
    end
end

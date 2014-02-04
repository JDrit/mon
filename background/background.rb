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
    memory_usage = (File.read("/proc/meminfo").split /\r?\n/).map do |line| 
        (line.split /\s+/)[1].to_i
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

def get_disk_stats
    stdin, stdout, stderr = Open3.popen3("iostat")
    partitions = []
    stdout.readlines[6..-2].each do |line|
        line_split = line.split(/\s+/)
        partitions << {name: line_split[0], read: line_split[2], write: line_split[3]}
    end
    return partitions
end

def get_interfaces_stats
    stdin, stdout, stderr = Open3.popen3("sar -n DEV 1 1")
    interfaces = []
    output= stdout.readlines
    output[output.length - ((output.length - 5) / 2)..-1].each do |line|
        line_split = line.split(/\s+/)
        interfaces << {name: line_split[1], rx: line_split[4].to_i * 8, 
                       tx: line_split[5].to_i * 8}
    end
    return interfaces
end

def background_thread api_key, interval
    while true
        uri = URI.parse("http://localhost:3000/api/add_entry")
        data = { "api_key" => api_key, "load_average" => get_load_average, 
                "memory_usage" => get_memory_usage, "disks" => get_disk_stats, 
                "programs" => get_processes, "partitions" => get_partition_stats,
                "interfaces" => get_interfaces_stats }
        headers = { "Content-Type" => "application/json" }
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = data.to_json
        response = http.request request
        puts response.body
        sleep interval
    end
end


if __FILE__ == $0
    background_thread 1, 30
end

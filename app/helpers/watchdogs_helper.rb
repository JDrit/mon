module WatchdogsHelper
    def display_memory(mem)
        if mem.to_i > 1024 * 1024
            return (mem.to_f / 1024 / 1024).round(2).to_s + "GB"
        elsif mem.to_i > 1024
            return (mem.to_f / 1024).round(2).to_s + "MB"
        else
            return mem.to_s + "KB"
        end
    end

    def display_network_speed(bits)
        if bits.to_i > 1024 * 1024 * 1024 * 1024
            return (bits.to_f / 1024 / 1024 / 1024 / 1024).round(2).to_s + "Tb/s"
        elsif bits.to_i > 1024 * 1024 * 1024
            return (bits.to_f / 1024 / 1024 / 1024).round(2).to_s + "Gb/s"
        elsif bits.to_i > 1024 * 1024
            return (bits.to_f / 1024 / 1024).round(2).to_s + "Mb/s"
        elsif bits.to_i > 1024
            return (bits.to_f / 1024).round(2).to_s + "Kb/s"
        else
            return bits.to_s + "b/s"
        end
    end


    def display_disk_speed(bytes)
        if bytes.to_i > 1024 * 1024 * 1024 * 1024
            return (bytes.to_f / 1024 / 1024 / 1024 / 1024).round(2).to_s + "TB/s"
        elsif bytes.to_i > 1024 * 1024 * 1024
            return (bytes.to_f / 1024 / 1024 / 1024).round(2).to_s + "GB/s"
        elsif bytes.to_i > 1024 * 1024
            return (bytes.to_f / 1024 / 1024).round(2).to_s + "MB/s"
        elsif bytes.to_i > 1024
            return (bytes.to_f / 1024).round(2).to_s + "KB/s"
        else
            return bytes.to_s + "B/s"
        end
    end

end

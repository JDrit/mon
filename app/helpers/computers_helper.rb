module ComputersHelper
    def display_memory(mem)
        if mem.to_i > 1024 * 1024
            return (mem.to_f / 1024 / 1024).round(2).to_s + "GB"
        elsif mem.to_i > 1024
            return (mem.to_f / 1024).round(2).to_s + "MB"
        else
            return mem.to_i.round(2).to_s + "KB"
        end
    end

    def display_disk(cap)
        if cap.to_i > 1024 * 1024 * 1024
            return (cap.to_f / 1024 / 1024 / 1024).round(2).to_s + "TB"
        elsif cap.to_i > 1024 * 1024
            return (cap.to_f / 1024 / 1024).round(2).to_s + "GB"
        elsif cap.to_i > 1024
            return (cap.to_f / 1024).round(2).to_s + "MB"
        else
            return cap.to_i.round(2).to_s + "KB"
        end
    end

    def display_disk_speed(bytes)
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

    def display_uptime(seconds)
        return "- na -" if seconds.nil?
        mm, ss = seconds.divmod(60)
        hh, mm = mm.divmod(60)
        dd, hh = hh.divmod(24)
        return "%d days, %d hours, %d minutes and %d seconds" % [dd, hh, mm, ss]
    end
end

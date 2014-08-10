class Watchdog < ActiveRecord::Base
    belongs_to :user
    belongs_to :computer
    validates_numericality_of :cpu_load,
        greater_than: 0,
        allow_nil: true
    validates_numericality_of :memory_usage,
        greater_than: 0,
        allow_nil: true
    validates_numericality_of :disk_read,
        greater_than: 0,
        allow_nil: true
    validates_numericality_of :disk_write,
        greater_than: 0,
        allow_nil: true
    validates_numericality_of :rx,
        greater_than: 0,
        allow_nil: true
    validates_numericality_of :tx,
        greaer_than: 0,
        allow_nil: true
    validates :disk_percentage_left, 
        :inclusion => { :in => 1..100 },
        allow_nil: true
    validates_presence_of :computer
    validates_presence_of :user

    def memory_usage=(val)
        val = val.to_s
        if val.length == 0
            kb = nil
        elsif val[-1,1].downcase == "g"
            kb = val[0, val.length - 1].to_f * 1024 * 1024
        elsif val[-1,1].downcase == "m"
            kb = val[0, val.length - 1].to_f * 1024
        elsif val[-1,1].downcase == "k"
            kb = val[0, val.length - 1].to_f
        elsif val[-2,2].downcase == "gb"
            kb = val[0, val.length - 2].to_f * 1024 * 1024
         elsif val[-2,2].downcase == "mb"
            kb = val[0, val.length - 2].to_f * 1024
        elsif val[-2,2].downcase == "kb"
            kb = val[0, val.length - 2].to_f
        else
            kb = val
        end
        write_attribute :memory_usage, kb
    end
    
    def disk_read=(val)
        write_attribute :disk_read, get_bytes(val)
    end

    def disk_write=(val)
        write_attribute :disk_write, get_bytes(val)
    end

    def rx=(val)
        write_attribute :rx, get_bytes(val)
    end

    def tx=(val)
        write_attribute :tx, get_bytes(val)
    end

    private 
        def get_bytes(val)
            val = val.to_s
            if val.length == 0
                return nil
            elsif val[-1,1].downcase == "g"
                return val[0, val.length - 1].to_f * 1024 * 1024 * 1024
            elsif val[-1,1].downcase == "m"
                return val[0, val.length - 1].to_f * 1024 * 1024
            elsif val[-1,1].downcase == "k"
                return val[0, val.length - 1].to_f * 1024
            elsif val[-2,2].downcase == "gb"
                return val[0, val.length - 2].to_f * 1024 * 1024 * 1024
            elsif val[-2,2].downcase == "mb"
                return val[0, val.length - 2].to_f * 1024 * 1024
            elsif val[-2,2].downcase == "kb"
                return val[0, val.length - 2].to_f * 1024
            elsif val[-4,4].downcase == "gb/s"
                return val[0, val.length - 4].to_f * 1024 * 1024 * 1024
            elsif val[-4,4].downcase == "mb/s"
                return val[0, val.length - 4].to_f * 1024 * 1024
            elsif val[-4,4].downcase == "kb/s"
                return val[0, val.length - 4].to_f * 1024
            elsif val[-3,3].downcase == "b/s"
                return val[0, val.length - 3].to_i
            else
                return val.to_i
            end
        end
end

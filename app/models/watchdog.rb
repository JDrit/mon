class Watchdog < ActiveRecord::Base
    #before_save :change_base
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

    private
        def change_base
            self.memory_usage = memory_usage * 1024 if memory_usage != nil
            self.disk_read = disk_read * 1024 * 1024 if disk_read != nil
            self.disk_write = disk_write * 1024 * 1024 if disk_write != nil
            self.rx = rx * 1024 * 1024 if rx != nil
            self.tx = tx * 1024 * 1024 if tx != nil
        end
end

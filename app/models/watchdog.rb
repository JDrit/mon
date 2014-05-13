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
end

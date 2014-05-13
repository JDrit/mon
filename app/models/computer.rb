class Computer < ActiveRecord::Base
    attr_accessor :load_avg
    attr_accessor :mem_usage
    attr_accessor :disk_cap
    attr_accessor :disk_usage

    has_many :disks, dependent: :destroy
    has_many :partitions, dependent: :destroy
    has_many :stats, dependent: :destroy
    has_many :programs, dependent: :destroy
    has_many :interfaces, dependent: :destroy
    has_many :watchdogs, dependent: :destroy

    validates :name, presence: true, 
        uniqueness: { case_sensitive: false }, 
        length: { maximum: 50 }
    validates :api_key, presence: true, 
        uniqueness: { case_sensitive: false }, 
        length: { maximum: 50 }

end

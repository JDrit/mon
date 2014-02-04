class Computer < ActiveRecord::Base
    has_many :disks, dependent: :destroy
    has_many :partitions, dependent: :destroy
    has_many :stats, dependent: :destroy
    has_many :programs, dependent: :destroy
    has_many :interfaces, dependent: :destroy
end

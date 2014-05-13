class Stat < ActiveRecord::Base
    belongs_to :computer
    validates :load_average, :numericality => { :greater_then => 0 }
    validates :memory_usage, :numericality => { :greater_then => 0 }
    validates :network_up, :numericality => { :greater_then => 0 }
    validates :network_down, :numericality => { :greater_then => 0 }
end

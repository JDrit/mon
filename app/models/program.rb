class Program < ActiveRecord::Base
    belongs_to :computer
    before_save :truncate

    def truncate
        self.name = name.truncate(255)
    end
end

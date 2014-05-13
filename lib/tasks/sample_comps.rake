namespace :db do
    desc "Fill database with sample data"
    task populate: :environment do
        Computer.create!(name: "jd's desktop", api_key: "1")
        User.create!(name: "jd", email: "jd@jd.com", password: "foobar", password_confirmation: "foobar")
    end
end

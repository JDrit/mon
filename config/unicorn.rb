# config/unicorn.rb
preload_app true

# Set the working application directory
working_directory "/home/jd/Documents/git/mon"

# Unicorn PID file location
pid "/home/jd/Documents/git/mon/tmp/pids/unicorn.pid"

# Path to logs
stderr_path "/home/jd/Documents/git/mon/log/unicorn.log"
stdout_path "/home/jd/Documents/git/mon/log/unicorn.log"

# Unicorn socket
listen "/tmp/unicorn.mon.sock"

# Number of processes
worker_processes 5

# Time-out
timeout 30

before_fork do |server, worker|
    Signal.trap 'TERM' do
        puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
        Process.kill 'QUIT', Process.pid
    end

    defined?(ActiveRecord::Base) and
        ActiveRecord::Base.connection.disconnect!
    end

    after_fork do |server, worker|
       Signal.trap 'TERM' do
           puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
       end

    defined?(ActiveRecord::Base) and 
        ActiveRecord::Base.establish_connection
end

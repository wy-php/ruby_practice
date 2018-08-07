# Sample verbose configuration file for Unicorn (not Rack)
#
# This configuration file documents many features of Unicorn
# that may not be needed for some applications. See
# https://bogomips.org/unicorn/examples/unicorn.conf.minimal.rb
# for a much simpler configuration file.
#
# See https://bogomips.org/unicorn/Unicorn/Configurator.html for complete
# documentation.

# Use at least one worker per core if you're on a dedicated server,
# more will usually help for _short_ waits on databases/caches.
app_path = File.expand_path( File.join(File.dirname(__FILE__), '..', '..'))
app_name = 'practice'
app_folder = "#{app_path}/#{app_name}"
log_folder = "#{app_folder}/shared/log"
pids_folder = "#{app_folder}/shared/tmp/pids"

#工作进程设置。如果环境中没有设置就设置4个
worker_processes Integer(ENV['UNICORN_WORKERS'] || 4)

#设置工作目录，这里设置项目的根目录
working_directory Rails.root

#预加载程序，以节省内存。
preload_app true

#unicorn监听的端口号，这里使用一个backlog以便在繁忙时进行更快的进行故障转移。
listen "tmp/to/.unicorn.sock", :backlog => 64
listen 8074, :tcp_nopush => true

#超时时间
timeout 60

#pid的保存文件路径
pid "#{pids_folder}/unicorn.pid"

#错误输出目录
stderr_path "#{log_folder}/unicorn_err.log"

#普通的日志输出目录
stdout_path "#{log_folder}/unicorn.log"

# 修正无缝重启unicorn后更新的Gem未生效的问题，原因是config/boot.rb会优先从ENV中获取BUNDLE_GEMFILE，
# 而无缝重启时ENV['BUNDLE_GEMFILE']的值并未被清除，仍指向旧目录的Gemfile
before_exec do |server|
  puts Rails.root
  ENV['BUNDLE_GEMFILE'] = "#{Rails.root}/Gemfile"
end
# Since Unicorn is never exposed to outside clients, it does not need to
# run on the standard HTTP port (80), there is no reason to start Unicorn
# as root unless it's from system init scripts.
# If running the master process as root and the workers as an unprivileged
# user, do this to switch euid/egid in the workers (also chowns logs):
# user "unprivileged_user", "unprivileged_group"

# Help ensure your application will always spawn in the symlinked
# "current" directory that Capistrano sets up.

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy


# Enable this flag to have unicorn test client connections by writing the
# beginning of the HTTP headers before calling the application.  This
# prevents calling the application for connections that have disconnected
# while queued.  This is only guaranteed to detect clients on the same
# host unicorn runs on, and unlikely to detect disconnects even on a
# fast LAN.
check_client_connection false

#防止多次运行钩子的局部变量
run_once = true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  # Occasionally, it may be necessary to run non-idempotent code in the
  # master before forking.  Keep in mind the above disconnect! example
  # is idempotent and does not need a guard.
  if run_once
    # do_something_once_here ...
    run_once = false # prevent from firing again
  end

  # 仅推荐在内存受限的时候安装，如果服务器可以容纳两倍于配置的工作进程服务的时候则建议配置。
  # 这个是允许一个新的进程逐步递增淘汰停止老的进程，去避免"惊群"(当一个进程过来的时候，如果是有多个子进程空闲沉睡的的话，此时
  # 只有一个进程被最先使用，其他的都不会被使用，所以浪费了资源开销)现象，特别是在配置了preload_app false 的时候。最后一个将会发出退出信号杀死老进程。
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Send 'QUIT' signal to unicorn error!"
    end
  end

  # 通过沉睡主进程并不能很快的离开
  # Throttle the master from forking too quickly by sleeping.  Due
  # to the implementation of standard Unix signal handlers, this
  # helps (but does not completely) prevent identical, repeated signals
  # from being lost when the receiving process is busy.
  sleep 1
end

after_fork do |server, worker|
  # per-process listener ports for debugging/admin/migrations
  # addr = "127.0.0.1:#{9293 + worker.nr}"
  # server.listen(addr, :tries => -1, :delay => 5, :tcp_nopush => true)

  # the following is *required* for Rails + "preload_app true",
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection

  # if preload_app is true, then you may also want to check and
  # restart any other shared sockets/descriptors such as Memcached,
  # and Redis.  TokyoCabinet file handles are safe to reuse
  # between any number of forked children (assuming your kernel
  # correctly implements pread()/pwrite() system calls)
end
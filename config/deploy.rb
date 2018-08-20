# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

#在部署期间，列出的文件夹将从应用程序的共享文件夹中链接到每个发布目录。
# .bundle 文件也是会被设置在shared文件夹下的，该目录中有一个配置文件，配置所有的gem包的存放位置的，存放目录一般是shared/bundle/ruby/2.3.0/gems
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
#在部署期间，列出的文件将从应用程序的共享文件夹中链接到每个发布目录。可用于持久性配置文件，如database.yml等文件ls。
#注意这里rails是5.2版本的，从这个版本开始，config/secrets.yml变成了config/master.key，即低于5.2版本的话要引入的是secrets.yml,否则会报错。注意这些手动添加的配置中需要有对应的内容，否则也会报错
append :linked_files, 'config/database.yml','config/redis.yml', 'config/config.yml', 'config/master.key'

#服务器上的ruby版本以及gemset名
@gem_version = 'ruby-2.3.0@practice'

#项目仓库配置
@project_name = "ruby_practice"
@git_url = 'git@github.com:wy-php'
@repo_url = "#{@git_url}/#{@project_name}.git"

# 服务器上部署的路径配置
@app_dir = 'practice'
@complete_app_dir = "/home/live/#{@app_dir}"

#输入要发布的分支
# ask(:use_branch, 'master', echo: true)
# @branch = fetch(:use_branch)
@branch = 'master'

#进行参数设置
set :deploy_to, @complete_app_dir  #部署的服务器的路径。默认是 { "/var/www/#{fetch(:application)}" }
set :application, @app_dir         #部署到的服务器的项目名
# set :scm, :git                   #配置源码管理工具,在Capfile中引入即可，这里不建议引入否则会提醒。目前支持 :git 、:hg 、 :svn，默认是：git
set :repo_url, @repo_url           #部署的仓库的地址配置
set :branch, @branch               #仓库的分支，默认是master
set :pty, false                    #是否使用SSHKit 详见 https://github.com/capistrano/sshkit/
set :log_level, :debug             #使用SSHKit的时候，选择的日志的层级。有:info, :warn，:error, :debug
set :format, :pretty               #还有其他的变量 :dot和 :pretty,使用airbrussh的时候打印的是:warn or :error，使用:dot或者:pretty打印配置的。
set :keep_releases, 5              #保持最近多少次的部署，在服务器上是release文件夹中存在多少个对应的源码的文件夹。

#设置release的目录格式
set :release_name, Time.now.strftime('%Y%m%d%H%M%S')

#格式化部署的时候显示的工具,设置其颜色以及保存的日志目录和字符宽度。在3.5以上的版本中 默认的
set :format_options, color: false, truncate: 80, log_file: "log/capistrano.log", command_output: true

#配置rvm的ruby版本以及gemset
set :rvm_ruby_version, @gem_version

#如果db/migrate文件没有改变就跳过
set :conditionally_migrate, true

#配置assets的目录，压缩编译静态文件在该配置下的目录进行。
set :assets_manifests, ['app/assets/config/manifest.js']

#虽然迁移一般是针对数据库的，但是在rails中数据库的迁移和rails框架密切相关，因此这里设置为应用 :app，而不是 :db
set :migration_role, :app

#创建文件夹public/images, public/javascripts, 以及 public/stylesheets在每个部署的服务器上
set :normalize_asset_timestamps, %w{public/images public/javascripts public/stylesheets}

#设置编译的静态资源角色
set :assets_roles, [:web, :app]

#设置部署的服务器端的共享文件夹目录名。默认: shared
set :shared_directory, "shared"

#设置部署的服务器端的发布的文件夹目录名。默认: releases
set :releases_directory, "releases"

#设置指向当前最新成功部署发布文件夹的当前链接的名称。默认: current
set :current_directory, "current"

#capistrano3版本及以上引入whenever的时候带上该命令是可以执行whenever -i的，即更新crontab的配置。
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

#配置unicorn的运行的目录
set :unicorn_config_path, "#{current_path}/config/unicorn.rb"

#执行deploy中进行的操作
after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  task :restart do
    invoke 'unicorn:start'
  end
end
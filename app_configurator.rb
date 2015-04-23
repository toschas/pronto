class AppConfigurator
  attr_accessor :rails_app_name, :client_app_name, :ruby_version, :rails_env,
    :nginx_server_name, :nginx_root, :nginx_aliases, :nginx_proxies, :user

  def initialize(args)
    @rails_app_name = args[:rails_app_name]
    @client_app_name = args[:client_app_name]
    @ruby_version = args[:ruby_version]
    @rails_env = args[:rails_env]
    @nginx_server_name = args[:nginx_server_name]
    @nginx_root = args[:nginx_root]
    @nginx_aliases = args[:nginx_aliases]
    @nginx_proxies = args[:nginx_proxies]
    @user = args[:user]
  end

  def configure
    puts 'Creating app directories...'
    create_app_directories
    puts 'Creating shared directories...'
    create_shared_directories
    puts 'Create rails configuration files (application.yml, database.yml)'
    create_rails_yml_files
    puts 'Configuring Puma services...'
    configure_puma_upstart
    puts 'Creating Nginx configuration...'
    configure_nginx
    puts "Installing Ruby v#{ruby_version}"
    install_ruby
  end

  private

  def create_app_directories
    [rails_app_name, client_app_name].each do |app_name|
      system(%Q{mkdir -p ~/#{app_name}})
    end
  end

  def create_shared_directories
    %w(tmp/sockets tmp/pids log config).each do |dir|
      system(%Q{mkdir -p ~/#{rails_app_name}/shared/#{dir}})
    end
  end

  def create_rails_yml_files
    %w(database.yml application.yml).each do |file|
      system(%Q{touch ~/#{rails_app_name}/shared/config/#{file}})
    end
  end

  def configure_puma_upstart
    set_jungle_config
    create_puma_app_file
    copy_jungle_files
  end

  def set_jungle_config
    content = read_file("#{ENV['HOME']}/puma.conf")
    %w(setuid setgid).each do |prefix|
      content.gsub!("#{prefix} apps", "#{prefix} #{user}")
    end
    content.gsub!("-C config/puma.rb", "-C config/puma.rb -e #{rails_env}")
    write_file("#{ENV['HOME']}/puma.conf", content)
  end

  def create_puma_app_file
    content = "/home/#{user}/#{rails_app_name}/current"
    write_file("#{ENV['HOME']}/puma_app.conf", content)
  end

  def copy_jungle_files
    system(%Q{sudo cp ~/puma.conf ~/puma-manager.conf /etc/init})
    system(%Q{sudo mv ~/puma_app.conf /etc/puma.conf})
  end

  def configure_nginx
    generate_nginx_config
    copy_nginx_config
  end

  def generate_nginx_config
    content = <<-EOT
    #{puma_upstart}

    server {
      listen *:80;
      server_name #{nginx_server_name};

      root /home/#{user}/#{client_app_name}/current/#{nginx_root};
      access_log /home/#{user}/#{rails_app_name}/current/log/nginx.access.log;
      error_log /home/#{user}/#{rails_app_name}/current/log/nginx.error.log;

    #{append_nginx_aliases}

    #{append_root_alias}

    #{append_reverse_proxies}

    #{append_assets}
    }
    EOT
    write_file("#{ENV['HOME']}/#{nginx_server_name}", content)
  end

  def copy_nginx_config
    system(%Q{sudo cp ~/#{nginx_server_name} /etc/nginx/sites-enabled})
  end

  def puma_upstart
    <<-EOT
    upstream puma {
      server unix:///home/#{user}/#{rails_app_name}/shared/tmp/sockets/puma.sock;
    }
    EOT
  end

  def append_nginx_aliases
    content = ''
    nginx_aliases.each do |nginx_alias|
      content << <<-EOT
      location #{nginx_alias[:location]} {
        alias #{nginx_alias[:alias]};
        gzip_static       on;
        expires           max;
        add_header        Cache-Control public;
      }
      EOT
    end
    content
  end

  def append_root_alias
    <<-EOT
    location / {
      alias /home/#{user}/#{client_app_name}/current/#{nginx_root};
      gzip_static       on;
      expires           max;
      add_header        Cache-Control public;
    }
    EOT
  end

  def append_reverse_proxies
    content = ""
    nginx_proxies.each do |proxy|
      content << <<-EOT
    location #{proxy[:location]} {
      proxy_pass #{proxy[:proxy]};
      proxy_set_header  X-Real-IP  $remote_addr;
      proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header  X-Forwarded-Proto http;
      proxy_set_header  Host $http_host;
      proxy_redirect    off;
      proxy_next_upstream error timeout invalid_header http_502;
    }
      EOT
    end
    content
  end

  def append_assets
    <<-EOT
    location ^~ /assets/ {
      gzip_static on;
      expires max;
      add_header Cache-Control public;
    }
    EOT
  end

  def install_ruby
    system(%Q{rbenv install #{ruby_version}})
  end

  def read_file(path)
    File.read(path)
  end

  def write_file(path, content)
    File.open(path, 'w') do |f|
      f.write(content)
    end
  end
end

user = ENV['USER']

puts %q{What is the name of your rails (API) application? }
rails_app_name = gets.chomp

puts %q{On which Ruby version does your app run on? }
ruby_version = gets.chomp

puts %q{What environment do you plan to deploy (e.g. staging, production...)? }
rails_env = gets.chomp

puts %q{What is the name of you client application? }
client_app_name = gets.chomp

puts %q{Enter Nginx server name: }
nginx_server_name = gets.chomp

puts %q{Enter relative path to a directory that contains index page of you client app (e.g. /app, /dist...): }
nginx_root = gets.chomp

nginx_aliases = []
loop do
  puts %q{Are there any Nginx aliases you would like to add? (y/N) }
  if %w(Y y).includes?(gets.chomp)
    puts %q{Enter Nginx location url and alias path (e.g. /my_location, /my/custom/path/): }
    nginx_aliases << { location: ARGV[0].chomp, alias: ARGV[1].chomp }
  else
    break
  end
end

nginx_proxys = []
loop do
  puts %q{Are there any Nginx reverse proxy's you would like to add? (y/N) }
  if %w(Y y).includes?(gets.chomp)
    puts %q{Enter Nginx location url and proxy url (e.g. /my/location/url, http://localhost:9999): }
    nginx_proxys << { location: ARGV[0].chomp, proxy: ARGV[1].chomp }
  else
    break
  end
end

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
  %w(database.yml application.yml) do |file|
    system(%Q{touch ~/#{rails_app_name}/shared/config/#{file}})
  end
end

def configure_puma_upstart
  set_jungle_config
  create_puma_app_file
  copy_jungle_files
end

def set_jungle_config
  content = read_file("~/puma.conf")
  %w(setuid setgid).each do |prefix|
    content.gsub!("#{prefix} apps", "#{prefix} #{user}")
  end
  content.gsub!("-C config/puma.rb", "-C config/puma.rb -e #{rails_env}")
  write_file("~/puma.conf", content)
end

def create_puma_app_file
  content = "/home/#{user}/#{rails_app_name}/current"
  write_file("~/puma_app.conf", content)
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
  write_file("~/#{nginx_server_name}", content)
end

def copy_nginx_config
  system(%Q{sudo cp ~/#{nginx_server_name} /etc/nginx/sites-enabled}
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

def read_file(path)
  File.read(path)
end

def write_file(path, content)
  File.open(path, 'w') do |f|
    f.write(content)
  end
end

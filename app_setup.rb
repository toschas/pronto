require('./app_configurator')

params = { user: ENV['USER'] }

puts %q{What is the name of your rails (API) application? }
params[:rails_app_name] = gets.chomp

puts %q{On which Ruby version does your app run on? }
params[:ruby_version] = gets.chomp

puts %q{What environment do you plan to deploy (e.g. staging, production...)? }
params[:rails_env] = gets.chomp

puts %q{What is the name of you client application? }
params[:client_app_name] = gets.chomp

puts %q{Enter Nginx server name: }
params[:nginx_server_name] = gets.chomp

puts %q{Enter relative path to a directory that contains index page of you client app (e.g. /app, /dist...): }
params[:nginx_root] = gets.chomp

params[:nginx_aliases] = []
loop do
  puts %q{Are there any Nginx aliases you would like to add? (y/N) }
  if %w(Y y).include?(gets.chomp)
    puts %q{Enter Nginx location url and alias path (e.g. /my_location, /my/custom/path/): }
    al = gets.chomp.split(',')
    params[:nginx_aliases] << { location: al[0].chomp, alias: al[1].chomp }
  else
    break
  end
end

params[:nginx_proxies] = []
loop do
  puts %q{Are there any Nginx reverse proxy's you would like to add? (y/N) }
  if %w(Y y).include?(gets.chomp)
    puts %q{Enter Nginx location url and proxy url (e.g. /my/location/url, http://localhost:9999): }
    proxy = gets.chomp.split(',')
    params[:nginx_proxies] << { location: proxy[0].chomp, proxy: proxy[1].chomp }
  else
    break
  end
end

configurator = AppConfigurator.new(params)
configurator.configure

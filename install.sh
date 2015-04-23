#!/bin/sh
echo "================ UPDATING SYSTEM... ================="
sudo apt-get update
echo "================ INSTALLING DEPENDENCIES... ================="
	sudo apt-get -y install git-core curl zlib1g-dev build-essential libssl-dev \
    libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev \
    libcurl4-openssl-dev python-software-properties libffi-dev imagemagick nginx \
    postgresql-common postgresql postgresql-contrib libpq-dev

echo "================ INSTALLING RBENV... ================"
cd
export RBENV_ROOT="$HOME/.rbenv"
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
echo 'source $HOME/.bash_profile' >> ~/.bashrc
. $HOME/.bash_profile

echo "================ INSTALLING RUBY-BUILD... ================"
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
echo "================ INSTALLING RBENV-BINSTUBS... ================"
git clone git://github.com/ianheggie/rbenv-binstubs.git ~/.rbenv/plugins/rbenv-binstubs
echo "================ INSTALLING RBENV-GEM-REHASH ================"
git clone git://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash
echo "================ INSTALLING RBENV-DEFAULT-GEMS ================"
git clone git://github.com/sstephenson/rbenv-default-gems.git ~/.rbenv/plugins/rbenv-default-gems
echo "bundler" >> ~/.rbenv/default-gems

echo "================ INSTALLING RUBY v2.2.1... ================"
rbenv install 2.2.1
rbenv global 2.2.1
echo "gem: --no-ri --no-rdoc" >> ~/.gemrc

echo "================ REMOVING NGINX DEFAULT CONFIGURATION ================"
sudo rm /etc/nginx/sites-enabled/default

echo "================ DOWNLOADING PUMA JUNGLE-TOOLS ================"
cd
wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma-manager.conf
wget https://raw.githubusercontent.com/puma/puma/master/tools/jungle/upstart/puma.conf

exec $SHELL

# PRONTO #

Couple of scripts for easy (Rails + Puma + Nginx) server setup.

---

## Usage ##

### Installing dependencies ###
Clone the repo to you home directory:

```
git clone https://github.com/toschaslabs/pronto ~/pronto
```

Make the script executable by running:

```
cd ~/pronto
chmod +x ./install.sh
```

Finally, run the installation script:

```
./install.sh
```
---

### Assumptions ###
Before running the application setup script, you should be aware of some assumptions that `app_setup.rb` script makes:

- you are deploying Rails **API** application and **separate** client application;

- you are using **Capistrano** for deploying Rails application;

- you are planning to use upstart [jungle-tools](https://github.com/puma/puma/tree/master/tools/jungle/upstart) for managing Puma.

### Running the setup script ###

```
cd ~/pronto
ruby app_setup.rb
```



## Details ##

`install.sh` contains commands for:

- updating Ubuntu system dependencies (`apt-get update`);

- installing other necessary libraries (see installing dependencies in `install.sh`);

- installing PostgreSQL server;

- installing [rbenv](https://github.com/sstephenson/rbenv);

- installing various [rbenv](https://github.com/sstephenson/rbenv) plugins:
    - [ruby-build](https://github.com/sstephenson/ruby-build)
    - [rbenv-binstubs](https://github.com/ianheggie/rbenv-binstubs)
    - [rbenv-gem-rehash](https://github.com/sstephenson/rbenv-gem-rehash)
    - [rbenv-default-gems](https://github.com/sstephenson/rbenv-default-gems);
- installing [Ruby](https://www.ruby-lang.org/en/) v2.2.1 (for general purpose);

- removing default Nginx config from `/etc/nginx/sites-enabled/`;

- downloading Puma upstart [jungle-tools](https://github.com/puma/puma/tree/master/tools/jungle/upstart).

---

## License ##
Pronto is free software, and may be redistributed under the terms specified in the [LICENSE](https://github.com/toschaslabs/pronto/blob/master/LICENSE) file.

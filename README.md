# PRONTO #

Couple of scripts for easy (Rails + Puma + Nginx) server setup.

---

## Install ##

Navigate to home directory and download the script:

```
cd
wget https://raw.githubusercontent.com/toschaslabs/pronto/master/install.sh
```

Make the script executable by running:

```
chmod +x ./install.sh
```

Finally, run the installation script:

```
./install.sh
```

---

## Details ##

`install.sh` contains commands for:

- updating Ubuntu system dependencies (`apt-get update`);

- installing other necessary libraries (see installing dependencies in `install.sh`);

- installing PostgreSQL server;

- installing [rbenv](https://github.com/sstephenson/rbenv);

- installing various **[rbenv](https://github.com/sstephenson/rbenv) plugins:
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


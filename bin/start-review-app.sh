#! /bin/bash

/usr/sbin/sshd

bundle exec rails db:schema_load_or_migrate
bundle exec rails server -b 0.0.0.0

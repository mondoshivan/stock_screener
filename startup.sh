#!/bin/bash

export PATH="${PATH}:${HOME}/.rbenv/shims:/usr/local/bin"

if [ "$APP_ENV" == "production" ]; then
  bundle install --with production
  ruby $APP_FILE -p 80
else
#  if $(mysql -u root < database_remove.sql > /dev/null 2>&1); then
#    echo ""
#  fi
  if [ "$APP_ENV" == "test" ]; then
    bundle install --with test
    rspec test/spec_handler.rb
  else
    bundle install --with development
    # mysql -u root < $(dirname $MAIN_APP_FILE)/database_create.sql
    shotgun -I "$(pwd)" $APP_FILE -p 45675 -o '0.0.0.0'
  fi
fi



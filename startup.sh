#!/bin/bash

if [ "$APP_ENV" == "production" ]; then
  bundle install --with production
  ruby $APP_FILE -p 80 -e production
else
  if [ "$APP_ENV" == "test" ]; then
    bundle install --with test
    rspec test/spec_handler.rb
  else
    bundle install --with development
    ruby $APP_FILE -p 45678
  fi
fi



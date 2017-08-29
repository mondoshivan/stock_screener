#!/bin/bash

if [ "$APP_ENV" == "production" ]; then
  bundle install --with production
  rackup $APP_FILE -p 4567 -E production
else
  if [ "$APP_ENV" == "test" ]; then
    bundle install --with test
    rspec test/spec_handler.rb
  else
    bundle install --with development
    ruby $APP_FILE -p 4567
  fi
fi



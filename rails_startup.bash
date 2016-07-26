#!/bin/bash

cd /home/app/webapp

echo "*** MIGRATING DATABASE ***"
bundle exec rake RAILS_ENV=$PASSENGER_APP_ENV db:create
bundle exec rake RAILS_ENV=$PASSENGER_APP_ENV db:migrate
echo "*** COMPLETED ***"
echo "*** PASSENGER_APP_ENV ***"
echo $PASSENGER_APP_ENV
if [[ $PASSENGER_APP_ENV = "production" ]]
then
    echo "*** PRECOMPILING ASSETS ***"
    bin/recompile_assets -e production
    echo "*** COMPLETED ***"
fi

if [[ -e /home/app/webapp/bin/delayed_job ]]
then
    echo "*** STARTING DELAYED_JOB ***"
    bin/delayed_job restart $PASSENGER_APP_ENV -n 6
    echo "*** COMPLETED ***"
fi

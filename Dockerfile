# use KDUX base Rails image, configure only project-specific items here
#FROM broadinstitute/kdux-rails-baseimage
FROM liefeld/rubybase20
#FROM phusion/passenger-full:0.9.18

# Or, instead of the 'full' variant, use one of these:
#FROM phusion/passenger-ruby19
#FROM phusion/passenger-ruby22:0.9.17

# Set correct environment variables.
#ENV HOME /root

# Use baseimage-docker's init process.
#CMD ["/sbin/my_init"]

# If you're using the 'customizable' variant, you need to explicitly opt-in
# for features. Uncomment the features you want:
#
#   Build system and git.
#RUN /pd_build/ruby2.2.sh
#RUN /pd_build/jruby9.0.sh
#RUN /pd_build/ruby2.1.sh
#   Python support.
#RUN /pd_build/python.sh
#   Node.js and Meteor support.
#RUN /pd_build/nodejs.sh

# Install imagemagick & sphinx + dependencies
#RUN apt-get update && apt-get install -y -qq --no-install-recommends imagemagick ghostscript sphinxsearch build-essential unzip net-tools bc curl ssmtp
#RUN apt-get install libaio1
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set timezone correctly
#RUN echo America/New_York | sudo tee /etc/timezone && sudo dpkg-reconfigure --frontend noninteractive tzdata

# Create temporary SSL certificate
#RUN mkdir /etc/pki/tls
#RUN mkdir /etc/pki/tls/certs
#RUN mkdir /etc/pki/tls/private
#RUN openssl req -newkey rsa:4096 -days 365 -nodes -x509 \
#    -subj "/C=US/ST=Massachusetts/L=Cambridge/O=Broad Institute/OU=BITS DevOps/CN=docker-host/emailAddress=devops@broadinstitute.org" \
#    -keyout /etc/pki/tls/private/localhost.key \
#    -out /etc/pki/tls/certs/localhost.crt
#RUN rm -f /etc/service/nginx/down


#RUN apt-get install libmysql-ruby 
RUN apt-get update && apt-get install -y libmysqlclient-dev

# Set up project dir, install gems, set up script to migrate database and precompile static assets on run
RUN mkdir /home/app/webapp
#COPY Gemfile /home/app/webapp/Gemfile
#COPY Gemfile.lock /home/app/webapp/Gemfile.lock
#RUN mkdir /home/app/webapp/app
COPY .  /home/app/webapp
RUN chmod -R u+rwx /home/app/webapp
 
WORKDIR /home/app/webapp
RUN bundle install --deployment
RUN bundle exec rake assets:precompile RAILS_ENV=rds

COPY rails_startup.bash /etc/my_init.d/rails_startup.bash
COPY set_user_permissions.bash /etc/my_init.d/set_user_permissions.bash

# Configure NGINX
RUN rm /etc/nginx/sites-enabled/default
COPY webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/service/nginx/down
RUN passenger-config build-native-support



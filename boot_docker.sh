#!/bin/bash

# usage error message
usage=$(
cat <<EOF
$0 [OPTION]
-e VALUE	set the environment, defaults to 'development'. Running in 'production' will cause container to spawn headlessly.
-d VALUE	set the project directory to mount inside Docker container, defaults to current working directory (`pwd`)
-m VALUE	set the MYSQL_LOCALHOST variable, only used in development, defaults to 10.0.2.2
-s VALUE	set the SECRET_KEY variable, necessary for decrypting DatStat connection info from the database (no default value)
-p VALUE	set the ATCP_PORTAL_DATABASE_PASSWORD variable, used in production only (no default value)
-h VALUE	set the PROD_HOSTNAME variable (used for callbacks)
-H COMMAND	print this text
EOF
)

# defaults, note there is no default for SECRET_KEY or PROD_DB_PASSWORD
PROJECT_DIR=`pwd`
PASSENGER_APP_ENV="development"
MYSQL_LOCALHOST="10.0.2.2"
PROD_HOSTNAME="at-docker.broadinstitute.org"

# certificate & key paths, no need to configure manually
#SSL_BASE_PATH="/etc/pki/tls"
#CERT_FILE="/certs/localhost.crt"
#KEY_FILE="/private/localhost.key"

while getopts "e:h:d:m:s:k:p:H" OPTION; do
case $OPTION in
	e)
		PASSENGER_APP_ENV="$OPTARG"
		;;
	d)
		PROJECT_DIR="$OPTARG"
		;;
	m)
  	MYSQL_LOCALHOST="$OPTARG"
  	;;
	s)
		SECRET_KEY="$OPTARG"
		;;
	p)
		ATCP_PORTAL_DATABASE_PASSWORD="$OPTARG"
		;;
	h)
		PROD_HOSTNAME="$OPTARG"
		;;
	H)
		echo "$usage"
		exit 0
		;;
	*)
    echo "unrecognized option"
    echo "$usage"
    ;;
	esac
done

if [[ $PASSENGER_APP_ENV = "production" ]]
then
     # no prod yet
     echo prod
else
	#docker run --rm -it --name a-t_portal -p 80:80 -p 443:443 -p 3306:3306 -p 25:25 -h docker-host.com -v $PROJECT_DIR:/home/app/webapp:rw -e PASSENGER_APP_ENV=$PASSENGER_APP_ENV -e MYSQL_LOCALHOST=$MYSQL_LOCALHOST -e SSL_BASE_PATH=$SSL_BASE_PATH -e CERT_FILE=$CERT_FILE -e KEY_FILE=$KEY_FILE a-t_portal_docker

        # docker run --rm -it --name gs_recipes -p 80:80 -p 443:443 -p 3306:3306 -p 25:25 -v $PROJECT_DIR:/home/app/webapp:rw -e PASSENGER_APP_ENV=$PASSENGER_APP_ENV -e MYSQL_LOCALHOST=$MYSQL_LOCALHOST  liefeld/gs_recipes

        #docker run --rm -it --name gs_recipes -p 80:80 -p 443:443 -p 3306:3306 -p 25:25 -e PASSENGER_APP_ENV=$PASSENGER_APP_ENV -e MYSQL_LOCALHOST=$MYSQL_LOCALHOST  liefeld/gs_recipes

        docker run --rm -it --name gs_dot_org -p 80:80 -p 443:443 -p 3306:3306 -p 25:25 -v $PROJECT_DIR/altpublic:/home/app/webapp/public -e PASSENGER_APP_ENV=$PASSENGER_APP_ENV -e MYSQL_LOCALHOST=$MYSQL_LOCALHOST liefeld/testgp 

fi

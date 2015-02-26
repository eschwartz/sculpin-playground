#!/bin/sh
# From https://github.com/rudimeier/bash_ini_parser

if [ -z "$1" ]; then
  echo "Unable to determine deploy environment"
  exit 1
else
   DEPLOY_ENV=$1
fi

echo "Generating Sculpin content for $DEPLOY_ENV environment."

# Generate content
rm -rf output_$DEPLOY_ENV
./sculpin generate --env=$DEPLOY_ENV

echo "\nContent generation successful."


# Deploy to s3
# Ini parser from http://www.tuxz.net/blog/Parse_ini_files_with_bash_and_sed/
CONFIG_FILE="s3.ini"
SECTION="$DEPLOY_ENV"

eval `sed -e 's/[[:space:]]*\=[[:space:]]*/=/g' \
    -e 's/;.*$//' \
    -e 's/[[:space:]]*$//' \
    -e 's/^[[:space:]]*//' \
    -e "s/^\(.*\)=\([^\"']*\)$/\1=\"\2\"/" \
   < $CONFIG_FILE \
    | sed -n -e "/^\[$SECTION\]/,/^\s*\[/{/^[^;].*\=.*/p;}"`

if [ -z "$s3Path" ]; then
  echo "Unable to determine s3 path for env $DEPLOY_ENV.";
  exit 1
fi

echo "Deploying to $s3Path";
aws s3 sync ./output_$DEPLOY_ENV $s3Path

echo "\nDeployment successful."
exit 0;
#!/bin/sh
# From https://github.com/rudimeier/bash_ini_parser

if [[ "$1" != "" ]]; then
  DEPLOY_ENV=$1
elif [[ "$TRAVIS_BRANCH" != "" ]]; then
  DEPLOY_ENV=$TRAVIS_BRANCH
else
  echo "Unable to determine deploy environment"
  exit 1
fi

echo "Generating Sculpin content for $DEPLOY_ENV environment."

# Generate content
rm -r output_$DEPLOY_ENV
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

echo "Deploying to $s3Path";

if [[ $TRAVIS == true ]]; then
  aws s3 sync ./output_$DEPLOY_ENV $s3Path
else
  echo "\nusing $awsProfile AWS profile";
  aws s3 sync ./output_$DEPLOY_ENV $s3Path --profile $awsProfile
fi

echo "\n"
echo "Deployment successful."

exit 0;
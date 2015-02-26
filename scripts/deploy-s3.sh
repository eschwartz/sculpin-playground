#!/bin/sh

if [ -z "$1" ]; then
  echo "Missing deploy env (arg 1)"
  exit 1
else
   DEPLOY_ENV=$1
fi
if [ -z "$2" ]; then
  echo "Missing Github username (arg 2)."
  exit 1
else
  GITHUB_USER=$2
fi
if [ -z "$3" ]; then
  echo "Missing Github password (arg 3)."
  exit 1
else
  GITHUB_PASS=$3;
fi



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

# Clone content repo
echo "\nCloning content repo $contentRepo (branch $DEPLOY_ENV) into tmp_source_repo"
eval `git clone \
  --depth 1 \
  --branch $DEPLOY_ENV \
  https://${GITHUB_USER}:${GITHUB_PASS}@github.com/${contentRepo} \
  tmp_source_repo`

echo "Copying sources into repo."
cp -R tmp_source_repo/source/* ./source


echo "Generating Sculpin content for $DEPLOY_ENV environment."

# Generate content
rm -rf output_$DEPLOY_ENV
./sculpin generate --env=$DEPLOY_ENV

echo "\nContent generation successful."



if [ -z "$s3Path" ]; then
  echo "Unable to determine s3 path for env $DEPLOY_ENV.";
  exit 1
fi

echo "Deploying to $s3Path";
aws s3 sync ./output_$DEPLOY_ENV $s3Path

echo "\nDeployment successful."
exit 0;
#!/bin/sh
# From https://github.com/rudimeier/bash_ini_parser
. scripts/read_ini.sh
read_ini s3.ini

# Generate content
rm -r output_prod
./sculpin generate --env=prod

# Deploy to s3
aws s3 sync ./output_prod/ $INI__s3path --profile $INI__profile

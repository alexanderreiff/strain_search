#!/usr/bin/env bash
#we don't want to run this out in the wild.
bundle check || bundle install
echo "Kicking off: $@"

if [ -n "$ELASTICSEARCH_URL" ]; then
  dockerize --wait $ELASTICSEARCH_URL --timeout 30s $@
else
  eval $@
fi

#!/bin/bash

# Debug, echo every command
#set -x

JS_RUNTIME_ENV_PREFIX="${JS_RUNTIME_ENV_PREFIX:-JS_RUNTIME_}"

# Each bundle is generated with a unique hash name to bust browser cache.
# Use shell `*` globbing to fuzzy match.
js_bundles="${JS_RUNTIME_TARGET_BUNDLE:-/app/build/static/js/*.js}"
# Get exact filenames.
js_bundle_filenames=`ls $js_bundles`

if [ ! "$?" = 0 ]
then
  echo "Error injecting runtime env: bundle not found '$js_bundles'. See: https://github.com/mars/create-react-app-buildpack/blob/master/README.md#user-content-custom-bundle-location"
fi

for js_bundle_filename in $js_bundle_filenames
do

  echo "Injecting runtime env into $js_bundle_filename (from .profile.d/inject_js_runtime_env.sh)"

  # Render runtime env vars into bundle.
  ruby -E utf-8:utf-8 \
    -r /app/.heroku-js-runtime-env/injectable_env.rb \
    -e "InjectableEnv.replace('$js_bundle_filename', "/^$JS_RUNTIME_ENV_PREFIX/")"
    
  gzip -k -f $js_bundle_filename
done

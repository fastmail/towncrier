#!/bin/sh

AUTH=admin:secret

# Create statuses
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Up -F description='The service is operating normally' -F icon=ok-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Down -F description='The service is unavailable' -F icon=remove-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Warning -F description='The service is operating in a degraded capacity' -F icon=warning-sign

# And services
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F name=Website -F description='My website'

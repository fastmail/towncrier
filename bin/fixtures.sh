#!/bin/sh

AUTH=admin:secret

# Create statuses
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Up -F description='The service is operating normally' -F icon=ok-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Down -F description='The service is unavailable' -F icon=remove-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Warning -F description='The service is operating in a degraded capacity' -F icon=warning-sign

# Make a group
curl -u $AUTH -i http://localhost:3000/admin/api/v1/groups -F name=Primary -F description='Primary services'

# And services
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F name=first -F group=primary -F description='My website' -F order=10
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F name=second -F group=primary -F description='My website' -F order=30
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F name=third -F group=primary -F description='My website' -F order=20

# Add an events
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services/first/events -F status=up -F message='Adding an event via curl to notify the service is up'


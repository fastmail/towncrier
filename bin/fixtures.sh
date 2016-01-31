#!/bin/sh

AUTH=admin:secret

# Create statuses
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Up -F description='The service is operating normally' -F icon=ok-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Down -F description='The service is unavailable' -F icon=remove-sign
curl -u $AUTH -i http://localhost:3000/admin/api/v1/statuses -F name=Warning -F description='The service is operating in a degraded capacity' -F icon=warning-sign

# Make a group
curl -u $AUTH -i http://localhost:3000/admin/api/v1/groups -F name=Primary -F description='Primary services'

# And services
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=web-client -F order=10 -F name='Web client' -F description='Access to services via the web client'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=login-sessions -F order=20 -F name='Login & sessions' -F description='Login & sessions'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=mail-delivery -F order=30 -F name='Mail delivery' -F description='Mail delivery and routing'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=mail-access -F order=40 -F name='Mail access (IMAP/POP)' -F description='Mail access via the IMAP and POP3 protocols'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=calendar -F order=45 -F name='Calendar (CalDAV)' -F description='Calendar access via the CalDAV protocol'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=file-storage -F order=50 -F name='File storage (FTP/DAV)' -F description='File storage access via the FTP and WebDAV protocols'
curl -u $AUTH -i http://localhost:3000/admin/api/v1/services -F id=contacts -F order=70 -F name='Contacts (LDAP)' -F description='Contacts access via the LDAP protocol'

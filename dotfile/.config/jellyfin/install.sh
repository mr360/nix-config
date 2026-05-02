#!/bin/sh

set -x

ADMIN_USERNAME="$JELLYFIN_ADMIN_USERNAME"
ADMIN_PASSWORD="$JELLYFIN_ADMIN_PASSWORD"
log_file="/tmp/jellyfin-init.log"

JELLYFIN_SERVER="$JELLYFIN_SERVER_URL"
AUTH_SERVER="$AUTH_SERVER_URL"
JELLYFIN_SERVER_NAME="$JELLYFIN_SERVER_NAME"
OID_ID="$JELLYFIN_OID_ID"
OID_SECRET="$JELLYFIN_OID_SECRET"
BYPASS_DOCKER_ADDRESS="$BYPASS_DOCKER_ADDRESS"

{
  echo "Waiting for Jellyfin to start listening on port 8096..."
  sleep 30
  while ! curl -s --max-time 5 --fail "${JELLYFIN_SERVER}/health" > /dev/null; do
      sleep 1
  done
  echo "Jellyfin is now listening on port 8096"

  curl "${JELLYFIN_SERVER}/Startup/Configuration" \
    -H 'Content-Type: application/json' \
    --data-raw '{"ServerName": "'${JELLYFIN_SERVER_NAME}'", "UICulture":"en-GB","MetadataCountryCode":"US","PreferredMetadataLanguage":"en"}' \
    -vv
  curl "${JELLYFIN_SERVER}/Startup/User" \
    -vv
  curl "${JELLYFIN_SERVER}/Startup/User" \
    -H 'Content-Type: application/json' \
    --data-raw '{"Name":"'${ADMIN_USERNAME}'","Password":"'${ADMIN_PASSWORD}'"}' \
    -vv
  curl "${JELLYFIN_SERVER}/Startup/RemoteAccess" \
    -H 'Content-Type: application/json' \
    --data-raw '{"EnableRemoteAccess":false,"EnableAutomaticPortMapping":false}' \
    -vv
  curl "${JELLYFIN_SERVER}/Startup/Complete" \
    -X 'POST' \
    -vv

  TOKEN=$(curl -X POST "${JELLYFIN_SERVER}/Users/AuthenticateByName" \
    -H 'Content-Type: application/json' \
    -H 'Authorization: MediaBrowser Client="Installer", Device="Docker", DeviceId="a1a2a3", Version="1.0"'\
    --data-raw '{"Username":"'${ADMIN_USERNAME}'","Pw":"'${ADMIN_PASSWORD}'"}' | jq -r .AccessToken) 
  
  echo "Dowloading latest SSO plugin and installing in Jellyfin" 
  ssoPluginDownloadLink=$(curl https://raw.githubusercontent.com/9p4/jellyfin-plugin-sso/manifest-release/manifest.json | jq -r .[0].versions[0].sourceUrl)
  curl -L -o temp.zip $ssoPluginDownloadLink && unzip temp.zip -d "/config/data/plugins/jellyfin-plugin-sso" && rm temp.zip
  chown abc:users /config/data/plugins/jellyfin-plugin-sso
  chown abc:users /config/data/plugins/jellyfin-plugin-sso/*.*

  echo "Rebooting the Jellyfin container now!" 
  curl "${JELLYFIN_SERVER}/System/Restart" \
    -X 'POST' \
    -vv

  echo "Waiting for Jellyfin to start listening on port 8096..."
  sleep 30
  while ! curl -s --max-time 5 --fail "${JELLYFIN_SERVER}/health" > /dev/null; do
      sleep 1
  done
  echo "Jellyfin is now listening on port 8096"

  echo "Setting up SSO login settings OPENID"
  curl -v -X POST -H 'Authorization: MediaBrowser Client="Installer", Device="Docker", DeviceId="a1a2a3", Version="1.0", Token="'${TOKEN}'"' -H 'Content-Type: application/json' -d '{"oidEndpoint": "'${AUTH_SERVER}'", "oidClientId": "'${OID_ID}'", "oidSecret": "'${OID_SECRET}'", "enabled": true, "enableAuthorization": true, "enableAllFolders": true, "enabledFolders": [], "adminRoles": ["admin"], "roles": [], "enableFolderRoles": false, "folderRoleMapping": [],"disablePushedAuthorization": true, "roleClaim": "groups", "oidScopes" : ["groups"]}' "${JELLYFIN_SERVER}/sso/OID/Add/authelia?api_key=${TOKEN}"

echo "Setting up networking settings"
curl -v -X POST -H 'Authorization: MediaBrowser Client="Installer", Device="Docker", DeviceId="a1a2a3", Version="1.0", Token="'${TOKEN}'"' -H 'Content-Type: application/json' -d '{"AutoDiscovery":false,"EnableUPnP":false,"EnableRemoteAccess":false,"KnownProxies":["'${BYPASS_DOCKER_ADDRESS}'"]}' "${JELLYFIN_SERVER}/System/Configuration/Network"

curl "${JELLYFIN_SERVER}/System/Configuration/Branding" \
    -H 'Authorization: MediaBrowser Client="Installer", Device="Docker", DeviceId="a1a2a3", Version="1.0", Token="'${TOKEN}'"' \
    -H 'Content-Type: application/json' \
    --data-raw '{"CustomCss":"a.raised.emby-button,\n.loginDisclaimerContainer,\n.loginDisclaimer,\n.manualLoginForm {\n  all: unset;\n}\n\n.btnQuick,\n.btnSelectServer,\n.btnForgotPassword,\na.raised.emby-button,\n.emby-button.block,\n.loginDisclaimerContainer,\n.loginDisclaimer {\n  margin-left: auto;\n  margin-right: auto;\n  margin-bottom: 1em;\n  color: inherit !important;\n}\n\n.btnForgotPassword {\n  display: none !important;\n}\n\n.manualLoginForm > :not(:first-child) {\n  display: none !important;\n}\n\n.sso-icon {\n  width: 25px;\n  height: 25px;\n  vertical-align: middle;\n  margin-right: 5px;\n}","LoginDisclaimer":"<form action=\"'${JELLYFIN_SERVER}'/sso/OID/start/authelia\">\n  <button class=\"raised block emby-button button-submit\">\n    <img src=\"https://www.authelia.com/svgs/branding/logo-cropped.svg\" alt=\"Authelia Logo\" class=\"sso-icon\">\n    Sign in with Authelia\n  </button>\n</form>","SplashscreenEnabled":false}' \
    -vv

  echo "Rebooting the Jellyfin container! Setup completed" 
  curl "${JELLYFIN_SERVER}/System/Restart" \
    -X 'POST' \
    -vv
  
} 2>&1 | tee "${log_file}"


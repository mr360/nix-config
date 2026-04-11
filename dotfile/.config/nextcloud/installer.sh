#!/bin/bash
set -e

#cd /config/www/nextcloud

# Required environment variables
: "${MYSQL_ROOT_USER:?MYSQL_ROOT_USER is required}"
: "${MYSQL_ROOT_PASSWORD:?MYSQL_ROOT_PASSWORD is required}"
: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_HOST:?MYSQL_HOST is required}"
: "${REDIS_HOST:?REDIS_HOST is required}"

# Optional admin credentials
ADMIN_USER="${NEXTCLOUD_ADMIN_USER:-admin}"
ADMIN_PASS="${NEXTCLOUD_ADMIN_PASSWORD:-adminpassword}"

echo "⏳ Waiting for database (${MYSQL_HOST})..."

# Wait for DB to be reachable (better than occ db:status before install)
until php -r "
\$host = getenv('MYSQL_HOST');
\$parts = explode(':', \$host);
\$fp = @fsockopen(\$parts[0], \$parts[1] ?? 3306, \$errno, \$errstr, 2);
if (\$fp) { fclose(\$fp); exit(0); } else { exit(1); }
"; do
  sleep 3
done

echo "✅ Database is reachable"

# Install only if not already installed
if [ ! -f config/config.php ]; then
  echo "🚀 Installing Nextcloud..."
  occ maintenance:install \
    --database "mysql" \
    --database-name "${MYSQL_DATABASE}" \
    --database-host "${MYSQL_HOST}" \
    --database-user "${MYSQL_ROOT_USER}" \
    --database-pass "${MYSQL_ROOT_PASSWORD}" \
    --admin-user "${ADMIN_USER}" \
    --admin-pass "${ADMIN_PASS}" \
    --data-dir "/data"
fi

echo "⚙️ Applying configuration..."

# Trusted domains
occ config:system:set trusted_domains 0 --value="cloud.mr360.me"
occ config:system:set trusted_domains 1 --value="nextcloud"
occ config:system:set trusted_domains 2 --value="localhost"
occ config:system:set trusted_domains 3 --value="onlyoffice-documentserver"

# Proxy + URL settings
occ config:system:set trusted_proxies 0 --value="172.18.0.0/16"
occ config:system:set overwrite.cli.url --value="https://cloud.mr360.me"
occ config:system:set overwriteprotocol --value="https"

# Redis config
occ config:system:set redis host --value="${REDIS_HOST}"
occ config:system:set redis port --value=6379 --type=integer
occ config:system:set redis timeout --value=1.5 --type=double

occ config:system:set memcache.local --value="\\\\OC\\\\Memcache\\\\Redis"
occ config:system:set memcache.locking --value="\\\\OC\\\\Memcache\\\\Redis"
occ config:system:set memcache.distributed --value="\\\\OC\\\\Memcache\\\\Redis"

# File locking
occ config:system:set filelocking.enabled --value=true --type=boolean

# Logging
occ config:system:set loglevel --value=2 --type=integer
occ config:system:set logtimezone --value="Australia/Melbourne"
occ config:system:set logfile --value="/var/www/html/data/nextcloud.log"

# Retention
occ config:system:set trashbin_retention_obligation --value="auto, 7"
occ config:system:set versions_retention_obligation --value="auto, 7"

# Previews
occ config:system:set enable_previews --value=true --type=boolean
occ config:system:set preview_max_x --value=256 --type=integer
occ config:system:set preview_max_y --value=256 --type=integer
occ config:system:set preview_max_memory --value=256 --type=integer

# Preview providers
occ config:system:set enabledPreviewProviders 0 --value="OC\\\\Preview\\\\PNG"
occ config:system:set enabledPreviewProviders 1 --value="OC\\\\Preview\\\\JPEG"
occ config:system:set enabledPreviewProviders 2 --value="OC\\\\Preview\\\\GIF"
occ config:system:set enabledPreviewProviders 3 --value="OC\\\\Preview\\\\BMP"
occ config:system:set enabledPreviewProviders 4 --value="OC\\\\Preview\\\\XBitmap"
occ config:system:set enabledPreviewProviders 5 --value="OC\\\\Preview\\\\MP3"
occ config:system:set enabledPreviewProviders 6 --value="OC\\\\Preview\\\\TXT"
occ config:system:set enabledPreviewProviders 7 --value="OC\\\\Preview\\\\MarkDown"
occ config:system:set enabledPreviewProviders 8 --value="OC\\\\Preview\\\\MP4"
occ config:system:set enabledPreviewProviders 9 --value="OC\\\\Preview\\\\Movie"
occ config:system:set enabledPreviewProviders 10 --value="OC\\\\Preview\\\\SVG"
occ config:system:set enabledPreviewProviders 11 --value="OC\\\\Preview\\\\PDF"
occ config:system:set enabledPreviewProviders 12 --value="OC\\\\Preview\\\\HEIC"
occ config:system:set enabledPreviewProviders 13 --value="OC\\\\Preview\\\\BMP2"
occ config:system:set enabledPreviewProviders 14 --value="OC\\\\Preview\\\\MKV"

# Background jobs
occ config:system:set backgroundjobs_mode --value="cron"

# Disable web upgrades
occ config:system:set upgrade.disable-web --value=true --type=boolean

echo "⚙️ Installing applications..."
#occ app:install files_archive
occ app:install onlyoffice

# List all installed apps
occ app:list

# Disable all apps except 'files'
occ app:disable admin_audit
occ app:disable comments
occ app:disable contacts
occ app:disable dashboard
occ app:disable gallery
occ app:disable richdocuments
occ app:disable federation
occ app:disable tasks

occ app:enable dav
occ app:enable files
occ app:enable activity
occ app:enable onlyoffice
#occ app:enable files_archive
occ app:enable files_external
occ app:enable previewgenerator

echo "⚙️ Setting up application settings..."
occ config:app:set onlyoffice DocumentServerUrl --value="${ONLYOFFICE_EXTERNAL_DOCUMENT_SERVER}"
occ config:app:set onlyoffice DocumentServerInternalUrl --value="${ONLYOFFICE_INTERNAL_DOCUMENT_SERVER}"
occ config:app:set onlyoffice StorageUrl --value="${NEXTCLOUD_INTERNAL}"
occ config:app:set onlyoffice jwt_secret --value="${ONLYOFFICE_JWT_TOKEN}"  

echo "⚙️ Tuning PHP settings..."
cat <<EOF >> /config/php/www2.conf
; Custom tuning
pm = dynamic
pm.max_children = 20
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
EOF

echo "✅ Nextcloud setup complete"

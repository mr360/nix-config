#!/bin/bash
set -euo pipefail

ORG_ID=$(psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -A -c "SELECT id FROM organizations LIMIT 1;" | xargs)

psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
INSERT INTO users (
    id,
    email,
    username,
    hashed_password,
    created_at,
    updated_at,
    status,
    rbac_roles,
    login_type,
    avatar_url,
    deleted,
    last_seen_at,
    quiet_hours_schedule,
    name,
    github_com_user_id,
    hashed_one_time_passcode,
    one_time_passcode_expires_at,
    is_system
)
VALUES (
    'e8c1936e-81c8-426e-9820-99d4f271a076',
    'admin@mr360.me',
    'admin',
    '\x',
    '2026-04-17 16:17:59.94163+00',
    '2026-04-17 16:31:46.488932+00',
    'active',
    ARRAY['owner'],
    'oidc',
    '',
    FALSE,
    '2026-04-17 16:31:46.488932+00',
    '',
    'admin',
    NULL,
    NULL,
    NULL,
    FALSE
);
"

psql -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
INSERT INTO organization_members (
    user_id,
    organization_id,
    created_at,
    updated_at,
    roles
)
VALUES (
    'e8c1936e-81c8-426e-9820-99d4f271a076',
    '$ORG_ID',
    '2026-04-17 16:17:59.97921+00',
    '2026-04-17 16:17:59.97921+00',
    ARRAY[]::text[]
);
"

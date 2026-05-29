-- Add up migration script here
ALTER TYPE SCRIPT_LANG ADD VALUE IF NOT EXISTS 'starrocks';
UPDATE config set config = jsonb_set(config, '{worker_tags}', config->'worker_tags' || '["starrocks"]'::jsonb) where name = 'worker__native' and config->'worker_tags' @> '["mysql"]'::jsonb AND NOT config->'worker_tags' @> '"starrocks"'::jsonb;

INSERT INTO resource_type (workspace_id, name, schema, description)
VALUES (
  'admins',
  'starrocks',
  '{
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "object",
    "properties": {
      "host":     { "type": "string", "description": "StarRocks FE host" },
      "port":     { "type": "integer", "default": 9030, "description": "Query port (default 9030)" },
      "database": { "type": "string" },
      "user":     { "type": "string" },
      "password": { "type": "string", "password": true },
      "ssl":      { "type": "boolean", "default": false }
    },
    "required": ["host", "database"],
    "order": ["host", "port", "database", "user", "password", "ssl"]
  }',
  'StarRocks OLAP database connection (MySQL-protocol compatible)'
)
ON CONFLICT (workspace_id, name) DO UPDATE
  SET schema = EXCLUDED.schema,
      description = EXCLUDED.description;

#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
  echo "Reading .env file..."
  # Clean up and export env vars, handling potential carriage returns (\r)
  export $(grep -v '^#' .env | sed 's/\r$//' | xargs)
else
  echo "Error: .env file not found."
  exit 1
fi

export PGPASSWORD=$DB_PASSWORD_MASTER

echo "Attempting to dump schema from host: $DB_HOST_MASTER, port: $DB_PORT_MASTER, database: $DB_DATABASE_MASTER"

# Try using host command first
if command -v pg_dump >/dev/null 2>&1; then
  echo "pg_dump found. Dumping schema directly..."
  pg_dump -h "$DB_HOST_MASTER" -p "$DB_PORT_MASTER" -U "$DB_USERNAME_MASTER" -d "$DB_DATABASE_MASTER" --schema-only -f schema_dump.sql
  
  echo "pg_dumpall found. Dumping roles directly..."
  pg_dumpall -h "$DB_HOST_MASTER" -p "$DB_PORT_MASTER" -U "$DB_USERNAME_MASTER" --roles-only -f roles_dump.sql
else
  echo "pg_dump not found on host. Searching for running PostgreSQL docker container..."
  CONTAINER_ID=$(docker ps --filter "status=running" --format "{{.ID}} {{.Image}} {{.Names}}" | grep -E "postgres|postgis|odiseo|db" | head -n 1 | awk '{print $1}')
  
  if [ -n "$CONTAINER_ID" ]; then
    echo "Found running PostgreSQL container: $CONTAINER_ID"
    echo "Dumping schema via docker exec..."
    docker exec -i "$CONTAINER_ID" pg_dump -U "$DB_USERNAME_MASTER" -d "$DB_DATABASE_MASTER" --schema-only > schema_dump.sql
    
    echo "Dumping roles via docker exec..."
    docker exec -i "$CONTAINER_ID" pg_dumpall -U "$DB_USERNAME_MASTER" --roles-only > roles_dump.sql
  else
    echo "Error: Neither pg_dump nor a running PostgreSQL docker container was found."
    echo "Please ensure you can run pg_dump or have Docker running, or run the following command manually:"
    echo "  pg_dump -h $DB_HOST_MASTER -p $DB_PORT_MASTER -U $DB_USERNAME_MASTER -d $DB_DATABASE_MASTER --schema-only -f schema_dump.sql"
    exit 1
  fi
fi

echo "Schema and roles successfully dumped to schema_dump.sql and roles_dump.sql!"
ls -la schema_dump.sql roles_dump.sql

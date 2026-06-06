#!/usr/bin/env bash
set -e

# Use Railway volume if available, otherwise fall back to local path
export DB_PATH="${DB_PATH:-/data/app.sqlite}"

# Create the data directory if it doesn't exist (for local runs)
mkdir -p "$(dirname "$DB_PATH")"

echo "==> Running database setup..."
php bin/setup.php

echo "==> Starting PHP server on port ${PORT:-8000}..."
exec php -S "0.0.0.0:${PORT:-8000}" -t public

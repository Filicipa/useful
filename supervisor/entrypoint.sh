#!/bin/sh
set -e

echo "Running migrations"
php artisan migrate --force

echo "Optimize"
php artisan optimize

echo "Starting supervisord"
exec supervisord -c /supervisor/supervisord.conf
#!/bin/bash
set -e

# Function to initialize database if needed
init_database() {
    echo "Checking database initialization..."
    if ! PGPASSWORD=$DB_PASSWORD psql -h db -U weechatbot -d weechatbot -c "SELECT 1 FROM wcb_users LIMIT 1" >/dev/null 2>&1; then
        echo "Database tables not found. Initializing..."
        PGPASSWORD=$DB_PASSWORD psql -h db -U weechatbot -d weechatbot -f /home/weechat/weechatbot/dbschema.psql
        echo "Database initialized."
    else
        echo "Database already initialized."
    fi
}

# Wait for PostgreSQL to be ready
until PGPASSWORD=$DB_PASSWORD psql -h db -U weechatbot -d weechatbot -c '\q'; do
    echo "PostgreSQL is unavailable - sleeping"
    sleep 1
done

# Initialize database if needed
init_database

echo "PostgreSQL is up - starting WeeChat in tmux"

# Create WeeChat config directory if it doesn't exist
mkdir -p /home/weechat/.weechat/python/autoload

# Start WeeChat in tmux
tmux new-session -d -s weechat 'weechat --dir /home/weechat/.weechat'

# Keep container running and show WeeChat logs
tail -f /home/weechat/.weechat/logs/weechat.log /dev/null 
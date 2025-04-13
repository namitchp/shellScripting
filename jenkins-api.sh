APP_NAME="connectx-api::q"
APP_SCRIPT="dist/index.js"  # Adjust to your app's entry point

# Ensure pm2 is available for the current user
if ! command -v pm2 &> /dev/null; then
    echo "Error: PM2 is not available in this user's environment."
    exit 1
fi

# Check if the app is already running in pm2
if pm2 list | grep -q "$APP_NAME"; then
    echo "🔁 $APP_NAME is already running. Restarting..."
    pm2 restart "$APP_NAME"
else
    echo "🚀 $APP_NAME is not running. Starting..."
    pm2 start "$APP_SCRIPT" --name "$APP_NAME"
fi
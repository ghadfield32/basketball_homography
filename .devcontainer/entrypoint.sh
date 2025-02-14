#!/bin/bash
# Start Xvfb in the background
Xvfb :0 -screen 0 1024x768x24 &

# Execute the CMD
exec "$@"

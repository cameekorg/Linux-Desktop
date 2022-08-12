#!/bin/bash

echo ""
echo "Create Docker Volumes"
echo "---------------------"

echo "Apps-Shared with path /apps/shared"
docker run -v /apps/shared --name Apps-Shared ubuntu /bin/bash

echo "Data with path /data"
docker run -v /data --name Data-Shared ubuntu /bin/bash
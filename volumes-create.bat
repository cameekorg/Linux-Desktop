@echo.
@echo "Create Docker Volumes"
@echo "---------------------"

@echo.
@echo "Shared Persistent Apps with path /shared/apps"
docker run -v shared-apps:/shared/apps --name shared-apps oraclelinux:8.6 /bin/bash

@echo.
@echo "Shared Persistent Data with path /shared/data"
docker run -v shared-data:/shared/data --name shared-data oraclelinux:8.6 /bin/bash
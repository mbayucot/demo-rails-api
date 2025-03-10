# Define variables
DOCKER_COMPOSE = docker compose
SERVICE_APP = app
SERVICE_DB = db
SERVICE_REDIS = redis
SERVICE_MONGO = mongo

# Build the project
build:
	$(DOCKER_COMPOSE) build

# Start all services
start:
	$(DOCKER_COMPOSE) up

# Stop all services
stop:
	$(DOCKER_COMPOSE) down

# Restart all services
restart:
	$(DOCKER_COMPOSE) down && $(DOCKER_COMPOSE) up

# Run Rails Console
console:
	$(DOCKER_COMPOSE) exec $(SERVICE_APP) rails console

# Run a Bash shell in the app container
shell:
	$(DOCKER_COMPOSE) exec $(SERVICE_APP) bash

# Enter PostgreSQL CLI inside the database container
db-cli:
	$(DOCKER_COMPOSE) exec $(SERVICE_DB) psql -U postgres -d demo_rails_api_development

# Run MongoDB shell
mongo-cli:
	$(DOCKER_COMPOSE) exec $(SERVICE_MONGO) mongosh

# List all MongoDB databases
mongo-dbs:
	$(DOCKER_COMPOSE) exec $(SERVICE_MONGO) mongosh --eval "show dbs"

# List all collections in the MongoDB database
mongo-collections:
	$(DOCKER_COMPOSE) exec $(SERVICE_MONGO) mongosh --eval "use demo_mongo_development; show collections"

# Query MongoDB logs from FileImportLog collection
mongo-logs:
	$(DOCKER_COMPOSE) exec $(SERVICE_MONGO) mongosh --eval "use demo_mongo_development; db.file_import_logs.find().pretty()"

# Run RSpec tests
test:
	$(DOCKER_COMPOSE) run --rm $(SERVICE_APP) bundle exec rspec
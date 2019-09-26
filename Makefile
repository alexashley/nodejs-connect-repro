MAKEFLAGS += --silent

.PHONY: env

default:
	echo "No default target"

env:
	docker-compose up -d
	./scripts/keycloak-init.sh

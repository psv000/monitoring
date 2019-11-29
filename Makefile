# VERSION?=develop
DOCKER_REGISTRY?=jfrog.space307.tech/docker-local
# DOCKER_MAIN_FILE=dockerfiles/Dockerfile.app
DEV_COMPOSE_FLAGS=-f dockerfiles/docker-compose.yml
BASE_IMAGE_VERSION=1.13.0.4
PROMETHEUS_PORTS=9151 9181

.PHONY:  dev_env_up dev_env_deploy dev_env_test dev_env_down
dev_env_up: COMPOSE_FLAGS=${DEV_COMPOSE_FLAGS}
dev_env_up: env_up
dev_env_test: COMPOSE_FLAGS=${DEV_COMPOSE_FLAGS}
dev_env_test: env_test
dev_env_down: COMPOSE_FLAGS=${DEV_COMPOSE_FLAGS}
dev_env_down: env_down

.PHONY: env_up env_test env_down cleanup
env_up: env_down
	docker-compose $(COMPOSE_FLAGS) pull
	docker-compose $(COMPOSE_FLAGS) up -d $(NAME)
env_down:
	docker-compose $(COMPOSE_FLAGS) down -v
cleanup:
	docker system prune -f -a
	docker rm -f $$(docker ps -aq)

.PHONY: open_ports close_ports
open_ports:
	expr=""
	for port in  $(PROMETHEUS_PORTS); \
    do \
		expr=$$expr"-L $$port:127.0.0.1:$$port "; \
    done; \
	expr=$$expr"j"; \
	echo $$expr; \
	ssh $$expr
close_ports:
	$$(ps -ax | grep ssh | grep -v grep | grep -v /bin/sh | grep -v ssh-agent | awk '{print "kill -9", $$1}')
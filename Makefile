#!/usr/bin/make

# Paramétrage de make
.PHONY: env

# Paramètres obligatoires
APP_ENVIRONMENT = localhost
COMPOSE_FILES = -f .cicd/compose/base.yml -f .cicd/compose/dev.yml
COMPOSE_PROJECT_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

# Chargement de la configuration environnementale
include .cicd/env/$(APP_ENVIRONMENT).env
export $(shell sed 's/=.*//' .cicd/env/$(APP_ENVIRONMENT).env)
export $(shell APP_ENVIRONMENT=$(APP_ENVIRONMENT))

# Paramètres extrapolés
COMPOSE_PROJECT_PREFIX = $(subst .,,$(COMPOSE_PROJECT_NAME))

# Commandes publiques

## Misc

help: ## Affichage de ce message d'aide
	@printf "\033[36m%s\033[0m (v%s)\n\n" $$(basename $$(pwd)) $$(git describe --tags --always)
	@echo "Commandes\n"
	@for MKFILE in $(MAKEFILE_LIST); do \
		grep -E '^[a-zA-Z0-9\._-]+:.*?## .*$$' $$MKFILE | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m  %s\n", $$1, $$2}'; \
	done
	@echo ""
	@$(MAKE) --no-print-directory urls

## Application

gong: ## Déclenchement des procédures de sauvetage
	docker-compose run --rm gong

## Contrôle des conteneurs

clean: envsubst stop ## Suppression des conteneurs. Les volumes Docker sont conservés
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES) rm -f

dev: env envsubst clean build  ## Démarrage de l'application et des outils de développement
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES) up \
			--remove-orphans \
			-d
	@$(MAKE) --no-print-directory help

logs: envsubst  ## Affiche un flux des logs de conteneurs de l'application
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES) logs -f

start: envsubst ## Démarrage de l'application
	docker-compose up \
		--remove-orphans \
		-d

stop: envsubst ## Arrêt de l'application
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES) stop

prune: clean ## Purge des artefacts créés par Docker. ATTENTION : les volumes Docker sont supprimés
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES)  down \
		--rmi=local

# Commandes privées

build: # Construction des images Docker de l'application
	docker-compose --project-directory $(COMPOSE_PROJECT_DIR) $(COMPOSE_FILES) build

env: # Génération du fichier .env courant en fonction de l'environnement d'exécution
	cat .cicd/env/$(APP_ENVIRONMENT).env > ./.env
	echo "\n# app\nAPP_ENVIRONMENT=$(APP_ENVIRONMENT)" >> ./.env

envsubst: # Regénération des fichiers dépendants de la configuration environnementale
	envsubst < .cicd/compose/base.yml.dist > .cicd/compose/base.yml
	envsubst < .cicd/compose/dev.yml.dist > .cicd/compose/dev.yml

urls: # Affichage de la liste des URL publiques
	@echo "Services"
	@echo
	@echo "  Application"
	@echo
	@echo "    \033[36mnginx\033[0m : http://$(NGINX_HOSTNAME)"
	@echo
	@echo "  Développement"
	@echo
	@echo "    \033[36mtraefik\033[0m : http://$(TRAEFIK_HOSTNAME)"

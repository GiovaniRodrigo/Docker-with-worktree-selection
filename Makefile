# =========================
# Forçar bash
# =========================
SHELL := /bin/bash

# =========================
# Target padrão
# =========================
.DEFAULT_GOAL := help

APP_DIR := app
SERVICE := app

.PHONY: help select build up down restart logs ps bash \
        composer composer-install composer-update composer-require \
        artisan artisan-migrate artisan-seed artisan-key artisan-cache \
        php tinker


# =========================
# Help
# =========================
help: ## Mostra este help
	@echo ""
	@echo "📘 Uso:"
	@echo "  make <comando> [variáveis]"
	@echo ""
	@echo "📦 Comandos disponíveis:"
	@awk 'BEGIN {FS = ":.*##"} \
		/^[a-zA-Z0-9_-]+:.*##/ { \
			printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 \
		}' $(MAKEFILE_LIST)
	@echo ""
	@echo "🔧 Variáveis úteis:"
	@echo "  PROJECT_NAME=meu-projeto"
	@echo "  CMD=\"comando docker compose\""
	@echo "  cmd=\"comando artisan/php/composer\""
	@echo "  pkg=\"vendor/pacote\""
	@echo ""


# =========================
# Seleção interativa
# =========================
select: ## Menu interativo para escolher o projeto
	@if [ -z "$(CMD)" ]; then \
		echo ""; \
		echo "❌ Erro: nenhum comando informado."; \
		echo ""; \
		echo "📘 Uso correto:"; \
		echo "  make select CMD=up"; \
		echo "  make select CMD=build"; \
		echo "  make select CMD=\"exec app php artisan migrate\""; \
		echo ""; \
		exit 1; \
	fi
	@echo "📦 Projetos disponíveis em $(APP_DIR):"
	@projects=($$(ls -d $(APP_DIR)/*/ 2>/dev/null | xargs -n1 basename)); \
	if [ $${#projects[@]} -eq 0 ]; then \
		echo "❌ Nenhum projeto encontrado em $(APP_DIR)/"; exit 1; \
	fi; \
	select PROJECT_NAME in "$${projects[@]}"; do \
		if [ -n "$$PROJECT_NAME" ]; then \
			echo "✔️ Projeto selecionado: $$PROJECT_NAME"; \
			echo "👉 Executando: $(CMD)"; \
			export PROJECT_NAME=$$PROJECT_NAME; \
			docker compose \
				-f docker-compose.yml \
				-f $(APP_DIR)/$$PROJECT_NAME/docker-compose.yml \
				$(CMD); \
			break; \
		else \
			echo "❌ Opção inválida"; \
		fi; \
	done


# =========================
# Docker Compose (direto)
# =========================
build: ## Build do docker-compose do projeto
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml build

up: ## Sobe os containers em background
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml up -d

down: ## Derruba os containers
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml down

restart: ## Reinicia os containers
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml restart

logs: ## Mostra logs (use s=service)
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml logs -f $(s)

ps: ## Lista containers
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml ps

bash: ## Acessa o bash do container app
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) bash


# =========================
# PHP
# =========================
php: ## Executa comando PHP (use cmd="-v")
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php $(cmd)

tinker: ## Abre o Laravel Tinker
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan tinker


# =========================
# Composer
# =========================
composer: ## Executa composer (use cmd="dump-autoload")
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) composer $(cmd)

composer-install: ## Composer install
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) composer install

composer-update: ## Composer update
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) composer update

composer-require: ## Composer require (use pkg=vendor/pacote)
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) composer require $(pkg)


# =========================
# Laravel / Artisan
# =========================
artisan: ## Executa artisan (use cmd="make:model User")
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan $(cmd)

artisan-migrate: ## Roda migrations
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan migrate

artisan-seed: ## Roda seeders
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan db:seed

artisan-key: ## Gera APP_KEY
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan key:generate

artisan-cache: ## Limpa caches
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec $(SERVICE) php artisan optimize:clear

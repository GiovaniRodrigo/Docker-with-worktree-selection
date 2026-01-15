# =========================
# Forçar bash
# =========================
SHELL := /bin/bash

APP_DIR := app

.PHONY: select build up down restart logs ps bash

# =========================
# Seleção interativa
# =========================
select:
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
# Execução direta (sem menu)
# =========================
build:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml build

up:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml up -d

down:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml down

logs:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml logs -f $(s)

ps:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml ps

bash:
	docker compose -f docker-compose.yml -f $(APP_DIR)/$(PROJECT_NAME)/docker-compose.yml exec app bash

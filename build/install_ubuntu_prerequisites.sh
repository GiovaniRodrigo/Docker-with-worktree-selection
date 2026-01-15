#!/bin/bash

# Este script instala o Docker e o Docker Compose em sistemas Ubuntu.
# Ele deve ser executado com privilégios de superusuário (sudo).

# --- Funções de Log ---
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# --- Verificação de Privilégios ---
if [ "$EUID" -ne 0 ]; then
    log_error "Este script precisa ser executado com sudo. Exemplo: sudo ./install_ubuntu_prerequisites.sh"
    exit 1
fi

log_info "Iniciando a instalação dos pré-requisitos do Docker no Ubuntu..."

# --- Atualizar Pacotes ---
log_info "Atualizando a lista de pacotes..."
apt update
if [ $? -ne 0 ]; then
    log_error "Falha ao atualizar a lista de pacotes."
    exit 1
fi
log_success "Lista de pacotes atualizada."

# --- Instalar Docker ---
log_info "Instalando Docker..."
apt install -y docker.io
if [ $? -ne 0 ]; then
    log_error "Falha ao instalar o Docker."
    exit 1
fi
log_success "Docker instalado."

# --- Instalar Docker Compose ---
log_info "Instalando Docker Compose..."
apt install -y docker-compose
if [ $? -ne 0 ]; then
    log_error "Falha ao instalar o Docker Compose."
    exit 1
fi
log_success "Docker Compose instalado."

# --- Adicionar Usuário ao Grupo Docker ---
log_info "Adicionando o usuário atual ('${SUDO_USER}') ao grupo 'docker'..."
# SUDO_USER é a variável que contém o nome de usuário que invocou o sudo.
if getent group docker | grep -q "\b${SUDO_USER}\b"; then
    log_info "Usuário '${SUDO_USER}' já é membro do grupo 'docker'."
else
    usermod -aG docker "${SUDO_USER}"
    if [ $? -ne 0 ]; then
        log_error "Falha ao adicionar o usuário '${SUDO_USER}' ao grupo 'docker'."
        log_info "Você precisará adicionar manualmente: sudo usermod -aG docker ${SUDO_USER}"
    else
        log_success "Usuário '${SUDO_USER}' adicionado ao grupo 'docker'. Você precisará fazer logout e login novamente para que as alterações tenham efeito."
    fi
fi

log_success "Instalação dos pré-requisitos concluída."
log_info "Lembre-se de fazer logout e login novamente para que as permissões do grupo 'docker' sejam aplicadas."

exit 0

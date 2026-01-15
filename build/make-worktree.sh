#!/bin/bash

set -e # Exit immediately if a command exits with a non-zero status.

# --- Functions ---
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1" >&2
}

# --- Main Script ---
if [ -z "$1" ]; then
    log_error "Uso: make-worktree <nome-do-worktree> [branch-base]"
    log_info "Exemplo: make-worktree minha-feature main"
    exit 1
fi

WORKTREE_NAME=$1
BASE_BRANCH=${2:-main} # Default to 'main' if no base branch is provided
WORKTREE_PATH="../${WORKTREE_NAME}"

log_info "Criando worktree '${WORKTREE_NAME}' a partir da branch '${BASE_BRANCH}' em '${WORKTREE_PATH}'..."

if [ -d "$WORKTREE_PATH" ]; then
    log_error "O diretório '${WORKTREE_PATH}' já existe. Por favor, escolha outro nome para o worktree."
    exit 1
fi

# Create a new branch for the worktree from the base branch
git fetch origin
git branch "${WORKTREE_NAME}" "origin/${BASE_BRANCH}"

# Create the worktree
git worktree add "${WORKTREE_PATH}" "${WORKTREE_NAME}"

if [ $? -ne 0 ]; then
    log_error "Falha ao criar o worktree. Verifique se o nome do worktree já não está em uso."
    # Clean up the created branch if worktree creation failed
    git branch -d "${WORKTREE_NAME}"
    exit 1
fi

log_success "Worktree '${WORKTREE_NAME}' criado com sucesso em '${WORKTREE_PATH}'."
log_info "Para começar a usar, execute: cd ${WORKTREE_PATH}"

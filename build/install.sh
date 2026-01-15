#!/bin/bash

# --- Configuration ---
PROJECT_NAME="default" # Default project name, can be overridden by user input or environment variable

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

check_and_install_prerequisites() {
    log_info "Verificando pré-requisitos (Docker e Docker Compose)..."
    if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
        log_success "Docker e Docker Compose encontrados."
        return 0
    fi

    log_error "Docker ou Docker Compose não encontrados."
    read -p "Gostaria de tentar instalar os pré-requisitos para Ubuntu agora? (s/N): " choice
    case "$choice" in
      s|S )
        log_info "Executando './install_ubuntu_prerequisites.sh' com sudo..."
        if sudo ./install_ubuntu_prerequisites.sh; then
            log_success "Pré-requisitos instalados. Por favor, faça logout e login para que as alterações de grupo do Docker tenham efeito antes de continuar."
            exit 0
        else
            log_error "A instalação dos pré-requisitos falhou. Por favor, corrija os erros e tente novamente."
            exit 1
        fi
        ;;
      * )
        log_error "Instalação cancelada. Por favor, instale Docker e Docker Compose manualmente."
        exit 1
        ;;
    esac
}

check_and_install_prerequisites

# Ensure 'app/' directory exists
if [ ! -d "app/" ]; then
    log_info "Diretório 'app/' não encontrado. Criando 'app/'..."
    mkdir -p "app/"
    log_success "Diretório 'app/' criado."
fi

# --- Project Selection (if multiple Laravel apps in 'app/') ---
log_info "Verificando projetos disponíveis em 'app/'..."
available_projects=($(ls -d app/*/ 2>/dev/null | xargs -n1 basename))

if [ ${#available_projects[@]} -eq 0 ]; then
    log_error "Nenhum projeto Laravel encontrado em 'app/'. Por favor, coloque seu projeto (ex: 'meu_projeto/') dentro do diretório 'app/'. Exemplo: 'app/meu_projeto/'. Depois, execute este script novamente."
    exit 1
fi

if [ ${#available_projects[@]} -eq 1 ]; then
    PROJECT_NAME="${available_projects[0]}"
    log_info "Apenas um projeto encontrado: ${PROJECT_NAME}. Selecionado automaticamente."
else
    log_info "Múltiplos projetos encontrados. Por favor, selecione um:"
    select selected_project in "${available_projects[@]}"; do
        if [ -n "$selected_project" ]; then
            PROJECT_NAME="$selected_project"
            log_success "Projeto selecionado: ${PROJECT_NAME}."
            break
        else
            log_error "Seleção inválida. Por favor, tente novamente."
        fi
    done
fi

log_info "Definindo PROJECT_NAME=${PROJECT_NAME} para o ambiente."
export PROJECT_NAME=${PROJECT_NAME} # Export for Makefile usage


# --- Docker Setup ---
log_info "Construindo imagens Docker (make build)..."
make build
if [ $? -ne 0 ]; then
    log_error "Falha ao construir imagens Docker. Verifique suas configurações do Docker e o Makefile."
    exit 1
fi
log_success "Imagens Docker construídas com sucesso."

# --- Git Worktree Validation ---
log_info "Validando se o projeto '${PROJECT_NAME}' é um repositório git..."
# Checa pela existência do arquivo ou diretório .git
if [ ! -e "app/${PROJECT_NAME}/.git" ]; then
    log_error "O diretório 'app/${PROJECT_NAME}' não é um repositório git ou worktree."
    log_info "Para configurar um novo worktree, você pode usar o comando 'make-worktree'."
    log_info "Exemplo de uso: make-worktree <nome-do-novo-worktree>"
    exit 1
fi
log_success "Projeto '${PROJECT_NAME}' é um repositório git válido."

log_info "Subindo containers Docker (make up)..."
make up
if [ $? -ne 0 ]; then
    log_error "Falha ao subir containers Docker. Verifique suas configurações do Docker e o Makefile."
    exit 1
fi
log_success "Containers Docker subidos com sucesso."

# --- Application Specific Setup ---

log_info "Instalando dependências PHP via Composer (make composer-install)..."
make composer-install
if [ $? -ne 0 ]; then
    log_error "Falha ao instalar dependências Composer. Verifique o log acima para detalhes."
    exit 1
fi
log_success "Dependências Composer instaladas."

log_info "Gerando chave da aplicação Laravel (make artisan-key)..."
make artisan-key
if [ $? -ne 0 ]; then
    log_error "Falha ao gerar a chave da aplicação Laravel."
    exit 1
fi
log_success "Chave da aplicação Laravel gerada."

log_info "Executando migrações do banco de dados (make artisan-migrate)..."
make artisan-migrate
if [ $? -ne 0 ]; then
    log_error "Falha ao executar migrações do banco de dados. Verifique o log acima para detalhes."
    exit 1
fi
log_success "Migrações do banco de dados concluídas."

# --- Install make-worktree script ---
install_make_worktree() {
    log_info "Tentando instalar o script 'make-worktree'..."
    if [ -f "make-worktree.sh" ]; then
        if command -v sudo &> /dev/null; then
            log_info "Copiando 'make-worktree.sh' para '/usr/local/bin/make-worktree' com sudo..."
            sudo cp make-worktree.sh /usr/local/bin/make-worktree
            sudo chmod +x /usr/local/bin/make-worktree
            log_success "Script 'make-worktree' instalado com sucesso. Você pode usá-lo globalmente."
        else
            log_error "Comando 'sudo' não encontrado. Não foi possível instalar 'make-worktree.sh' globalmente. Você pode executá-lo localmente com './make-worktree.sh'."
        fi
    else
        log_info "Script 'make-worktree.sh' não encontrado, pulando a instalação."
    fi
}

install_make_worktree

# --- Post-installation ---
log_success "Instalação completa! A aplicação está rodando em containers Docker."
log_info "Para acessar o bash do container: make bash"
log_info "Para derrubar os containers: make down"
log_info "Para ver os logs: make logs"
log_info "Você pode precisar acessar http://localhost ou o endereço configurado no seu ambiente Docker."

exit 0
# Dockerized Application with Worktree Selection

## Overview
This project provides a boilerplate for a Dockerized application, designed to facilitate development with multiple worktrees. It integrates Docker for containerization, `docker-compose` for multi-container orchestration, and a `Makefile` for simplifying common development tasks. The `app/` directory is intended to house the main application code, which can be organized into sub-modules like `feature/1` and `main`.

## Getting Started

### Prerequisites
- Docker (with Docker Compose)
- Make

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/GiovaniRodrigo/Docker-with-worktree-selection.git
    cd Docker-with-worktree-selection
    ```
2.  **Build and run the Docker containers:**
    ```bash
    make build
    make up
    ```
    This will build the Docker images and start the services defined in `docker-compose.yml`.

### Usage

This project utilizes a `Makefile` to streamline common Docker operations and project switching.

#### Project Selection

The `select` command allows you to interactively choose a project from the `app/` directory and execute a `make` command against it.

1.  **Select a project and run a command (interactive):**
    ```bash
    make CMD="up" select
    ```
    This will list available projects (e.g., `feature/1`, `main`, `feature`, `hotfix`, `test`) and prompt you to choose one. Once selected, it will run `docker compose -f docker-compose.yml -f app/<selected_project>/docker-compose.yml up -d`.

    Other examples using `make select` with different `CMD` values:
    ```bash
    make CMD="build" select      # Build services for a selected project
    make CMD="down" select       # Stop services for a selected project
    make CMD="logs" select       # View logs for a selected project (requires service name input)
    make CMD="ps" select         # List running services for a selected project
    ```

#### Direct Commands (with PROJECT_NAME)

For non-interactive use, you can set the `PROJECT_NAME` environment variable and then run any of the following `make` commands. These commands will combine the root `docker-compose.yml` with the one found in `app/$(PROJECT_NAME)/docker-compose.yml`.

-   **Build services for a specific project:**
    ```bash
    PROJECT_NAME=main make build
    ```
-   **Start services for a specific project:**
    ```bash
    PROJECT_NAME=main make up
    ```
-   **Stop services for a specific project:**
    ```bash
    PROJECT_NAME=main make down
    ```
-   **View logs for a specific project:**
    ```bash
    PROJECT_NAME=main make logs s="<service_name>"
    # e.g., PROJECT_NAME=main make logs s="app"
    ```
-   **List running services for a specific project:**
    ```bash
    PROJECT_NAME=main make ps
    ```
-   **Access a service's shell for a specific project:**
    ```bash
    PROJECT_NAME=main make bash
    ```

#### Development Workflow

1.  **Start development:** Use `make CMD="up" select` to choose your project and bring up its services.
2.  **Stop development:** Use `make CMD="down" select` to stop the services of your chosen project.
3.  **Rebuild a specific project's services:** If you make changes to your `Dockerfile` or `docker-compose.yml` within a project, use `PROJECT_NAME=<your_project> make build`.
4.  **Access a service's shell:** When services are running, `PROJECT_NAME=<your_project> make bash` will give you a shell inside the `app` service of your selected project.

#### Worktrees

This project is structured to support `git worktree` for managing multiple branches concurrently.

1.  **Add a new worktree:**
    ```bash
    git worktree add ../<new_worktree_name> <branch_name>
    # e.g., git worktree add ../feature-branch feature/new-feature
    ```
2.  **Navigate to the worktree and develop:**
    ```bash
    cd ../feature-branch
    # Make your changes, then build and run as usual, remember to set PROJECT_NAME or use select
    PROJECT_NAME=main make build
    PROJECT_NAME=main make up
    ```

## Project Structure

-   `.github/`: GitHub Actions workflows (e.g., Dependabot).
-   `app/`: Contains the main application source code.
    -   `feature/`: A module or sub-application.
    -   `hotfix/`: A module or sub-application.
    -   `test/`: A module or sub-application.
    -   `main/`: Another module or the main entry point.
-   `config_files/`: Configuration files for services (e.g., Nginx default config).
-   `Dockerfile`: Defines the Docker image for the primary application service.
-   `docker-compose.yml`: Defines and runs multi-container Docker applications.
-   `Makefile`: Provides convenient commands for building, running, and managing the application.

## Configuration

-   **`docker-compose.yml`**: Modify this file to add, remove, or configure services (e.g., databases, other microservices).
-   **`Dockerfile`**: Customize this file to change the application's environment, dependencies, or build process.
-   **`config_files/default.conf`**: Use this for web server configurations (e.g., Nginx).

## Contributing
Please refer to the `CONTRIBUTING.md` file for guidelines on how to contribute to this project.

## License
This project is licensed under the MIT License - see the `LICENSE` file for details.

# Containerization Documentation

## Table of Contents

- [Description](#description)
- [Quickstart](#quickstart)
- [How to Build the Image](#how-to-build-the-image)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Running the Containers](#running-the-containers)
- [Troubleshooting](#troubleshooting)
- [Useful Links](#useful-links)

---

## Description

This repository provides a Dockerized setup for the `Truck Signs API` application. The main goal of the project is to enable seamless deployment and scalability of the backend application, leveraging Docker and container orchestration tools. This README includes steps for setting up, configuring, and running the application in a containerized environment.

---

## Quickstart

All commands should be executed in a terminal that supports `bash`, such as the Linux shell, macOS terminal, or Git Bash on Windows.

#### Virtual Environment Setup

For local development, it is recommended to set up a Python virtual environment:

1. Create a virtual environment:
   ```bash
   python3 -m venv venv
   ```
2. Activate the virtual environment:
   ```bash
   source venv/bin/activate
   ```
3. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

---

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Configure the environment variables as described in the [Configuration](#configuration) section.

3. Build the Docker image:

   ```bash
   docker build -t truck_signs .
   ```

4. Start the database container:

   ```bash
   docker run -d \
   --name truck_signs_db \
   --env-file ./settings/.env \
   -v /path/to/data:/var/lib/postgresql/data \
   -p 5432:5432 \
   postgres:13
   ```

5. Start the application container:

   ```bash
   docker run -d \
   --name truck_signs_web \
   --env-file ./settings/.env \
   -v $(pwd):/app \
   -p 8020:5000 \
   truck_signs
   ```

   **Explanation of Flags:**

   - `-d`: Runs the container in detached mode.
   - `--name`: Names the container for easier identification.
   - `--network`: Connects the container to the specified network for inter-container communication.
   - `--env-file`: Provides environment variables from a file.
   - `-v $(pwd):/app`: Mounts the current working directory to `/app` in the container for dynamic updates.
   - `-p 8020:5000`: Maps the container's port 5000 to the host's port 8020, exposing the application.

6. Verify the setup:
   ```bash
   docker ps
   ```

---

## How to Build the Image

See dockerfile [here](https://github.com/Zeebuhh/truck_signs_api/blob/main/Dockerfile)

Once the Dockerfile is in place, proceed with building the image as described below.

---

1. Ensure the Dockerfile is in the root of the project directory.

2. Build the image:
   ```bash
   docker build -t truck_signs .
   ```

---

## Usage

(Optional) To create a superuser for managing the application:

```bash
python manage.py createsuperuser
```

---

### Configuration

#### Environment File Setup

Before running the application, copy the example `.env` file into the settings directory and configure it:

```bash
cd truck_signs_designs/settings
cp simple_env_config.env .env
```

This `.env` file should contain all necessary environment variables. Update the values as needed for your environment. See the details below for the required variables.

#### Required Variables:

- **`SECRET_KEY`**: The secret key used by the application for encryption and securing sensitive data.
- **`DB_NAME`**: The name of the database used by the application (e.g., `truck_signs_db`).
- **`DB_USER`**: The username for connecting to the database.
- **`DB_PASSWORD`**: The password for the database user.
- **`DB_HOST`**: The hostname or address of the database server (e.g., `localhost` or a remote URL).
- **`DB_PORT`**: The port number on which the database server is running (e.g., `5432` for PostgreSQL).

#### Optional Variables:

- **`STRIPE_PUBLISHABLE_KEY`**: The publishable key for Stripe, used to handle payments in the application.
- **`STRIPE_SECRET_KEY`**: The secret key for Stripe, used for secure communication with the Stripe API.
- **`EMAIL_HOST_USER`**: The email address used as the sender for outgoing emails (e.g., a support or admin email).
- **`EMAIL_HOST_PASSWORD`**: The password for the email host user.

#### Example:

```env
DB_NAME=truck_signs_db
DB_USER=admin
DB_PASSWORD=securepassword
DB_HOST=localhost
DB_PORT=5432

# Optional
STRIPE_PUBLISHABLE_KEY=your_publishable_key
STRIPE_SECRET_KEY=your_secret_key
EMAIL_HOST_USER=your_email@example.com
EMAIL_HOST_PASSWORD=your_email_password
```

### Running the Containers

1. Start the database container.
2. Start the application container.

---

## Troubleshooting

- **Persistent Data:** Ensure that the database data persists across container restarts. Verify the data volume is correctly mounted with the `-v` flag during container setup.
- **Database Connection Issues:** Verify the database container is running and the network settings are correctly configured. Use `docker logs truck_signs_db` to check for errors.
- **Application Not Starting:** Check the application logs with `docker logs truck_signs_web`.
- **Environment Variables:** Ensure all required environment variables are set in the `.env` file.

---

## Useful Links

- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Django Documentation](https://docs.djangoproject.com/)

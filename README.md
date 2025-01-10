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

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Configure the environment variables as described in the [Configuration](#configuration) section.

3. Build the Docker image:

   ```bash
   docker build -t truck_signs .
   ```

4. Create a Docker network:

   ```bash
   docker network create truck_signs_network
   ```

5. Start the database container:

   ```bash
   docker run -d \
   --name truck_signs_db \
   --network truck_signs_network \
   --env-file ./settings/.env \
   -v /path/to/data:/var/lib/postgresql/data \
   -p 5432:5432 \
   --restart on-failure \
   postgres:13
   ```

   **Explanation of Flags:**

   - `-d`: Runs the container in detached mode (in the background).
   - `--name`: Assigns a name to the container for easier management.
   - `--network`: Specifies the network for the container, allowing communication between the app and database containers.
   - `--env-file`: Loads environment variables from the specified file.
   - `-v`: Mounts a volume for persistent database storage, ensuring data isn't lost on container restart.
   - `-p`: Maps the container's port 5432 to the host machine's port 5432.
   - `--restart on-failure`: Ensures the container restarts automatically if it crashes.

6. Start the application container:

   ```bash
   docker run -d \
   --name truck_signs_web \
   --network truck_signs_network \
   --env-file ./settings/.env \
   -v $(pwd):/app \
   -p 8020:5000 \
   --restart on-failure \
   truck_signs
   ```

   **Explanation of Flags:**

   - `-d`: Runs the container in detached mode.
   - `--name`: Names the container for easier identification.
   - `--network`: Connects the container to the specified network for inter-container communication.
   - `--env-file`: Provides environment variables from a file.
   - `-v $(pwd):/app`: Mounts the current working directory to `/app` in the container for dynamic updates.
   - `-p 8020:5000`: Maps the container's port 5000 to the host's port 8020, exposing the application.
   - `--restart on-failure`: Automatically restarts the container if it fails.

7. Verify the setup:
   ```bash
   docker ps
   ```

---

## How to Build the Image

### Dockerfile Setup

The `Dockerfile` is a critical component for containerizing the Truck Signs API. Below is an example Dockerfile used for building the application image:

```dockerfile
# Base frame of the container-image is the python version that was used to develop the app
FROM python:3.8-slim

# Creates a directory in the container that contains all files/assets of the project
WORKDIR /app

# Copies the files of the current folder from the host into the /app directory of the container during build process
COPY . /app

# Installs system-wide dependencies for compilation and network verification
# Deletes cache files of package source information to reduce the size of the container
RUN apt-get update && \
    apt-get install -y build-essential gcc netcat-openbsd && \
    rm -rf /var/lib/apt/lists/*

# Installs the dependencies for the app as specified in the requirements.txt file
RUN python -m pip install --upgrade pip && \
    python -m pip install -r requirements.txt

# Sets the execution rights if the entrypoint script is not executable
RUN chmod +x ./entrypoint.sh

# Opens container port 8020 for interaction
EXPOSE 8020

# Entrypoint is outsourced in /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
```

**Explanation of Each Step:**

1. **`FROM python:3.8-slim`**:

   - Specifies the base image. In this case, a lightweight Python image is used for efficiency.

2. **`WORKDIR /app`**:

   - Sets the working directory inside the container where all subsequent commands are executed.

3. **`COPY . /app`**:

   - Copies all files from the host's current directory to the `/app` directory in the container.

4. **`RUN apt-get update ...`**:

   - Installs necessary system-wide dependencies and cleans up to minimize image size.

5. **`RUN python -m pip install ...`**:

   - Upgrades pip and installs Python dependencies from the `requirements.txt` file.

6. **`RUN chmod +x ./entrypoint.sh`**:

   - Ensures the `entrypoint.sh` script has execution permissions.

7. **`EXPOSE 8020`**:

   - Exposes port 8020 to allow external access to the containerized application.

8. **`ENTRYPOINT ["/app/entrypoint.sh"]`**:
   - Defines the entry point for the container, delegating further commands to the `entrypoint.sh` script.

Once the Dockerfile is in place, proceed with building the image as described in the [How to Build the Image](#how-to-build-the-image) section.

---

1. Ensure the Dockerfile is in the root of the project directory.
2. Build the image:
   ```bash
   docker build -t truck_signs .
   ```

---

## Usage

### Security Notes

- Avoid storing sensitive information (e.g., passwords, tokens, SSH keys) in the repository. Use environment variables or `.env` files instead.
- Do not expose IP addresses or other sensitive data in your Git repository.

(Optional) To create a superuser for managing the application:

```bash
python manage.py createsuperuser
```

### Entry Point Changes

To prevent errors caused by repeated migrations, the `entrypoint.sh` script has been modified. Now, migrations are only created in the development environment, and the `migrate` command is always run:

```bash
# entrypoint.sh changes

echo "Running migrations..."
if [ "$DJANGO_ENV" = "development" ]; then
  echo "Running makemigrations in development mode..."
  python manage.py makemigrations
fi
python manage.py migrate
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

---

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

#### Database Configuration Changes

The following section in `base.py` was uncommented to enable the use of a PostgreSQL database in the project. This allows the application to connect to the database container using environment variables:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': os.getenv('DB_NAME', 'trucksigns_db'),
        'USER': os.getenv('DB_USER', 'trucksigns_user'),
        'PASSWORD': os.getenv('DB_PASSWORD', 'supertrucksignsuser!'),
        'HOST': os.getenv('DB_HOST', 'localhost'),
        'PORT': os.getenv('DB_PORT', '5432'),
    }
}
```

This configuration is essential for connecting Django to the PostgreSQL database, leveraging environment variables for flexibility and security. Ensure all required environment variables are set in the `.env` file as described above.

Additionally, the following environment variables can be included for specific functionalities like Stripe integration and email configuration:

```env
STRIPE_PUBLISHABLE_KEY=yourStripeKey
STRIPE_SECRET_KEY=yourStripeSecretKey
EMAIL_HOST_USER=yourEmailUser
EMAIL_HOST_PASSWORD=yourEmailPassword
```

- The `STRIPE_*` variables can be obtained from a Stripe developer account.
- `EMAIL_HOST_USER` and `EMAIL_HOST_PASSWORD` are used for sending transactional emails. These values are optional if email functionality is not required.

### Running the Containers

1. Start the database container as described in the [Quickstart](#quickstart).
2. Start the application container as described in the [Quickstart](#quickstart).

---

## Troubleshooting

- **Persistent Data:** Ensure that the database data persists across container restarts. Verify the data volume is correctly mounted with the `-v` flag during container setup.
- **Network Communication:** Confirm that all containers are in the same Docker network (`truck_signs_network`) to enable proper communication. Use `docker network inspect truck_signs_network` to verify.
- **Database Connection Issues:** Verify the database container is running and the network settings are correctly configured. Use `docker logs truck_signs_db` to check for errors.
- **Application Not Starting:** Check the application logs with `docker logs truck_signs_web`.
- **Environment Variables:** Ensure all required environment variables are set in the `.env` file.

---

## Useful Links

- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Django Documentation](https://docs.djangoproject.com/)

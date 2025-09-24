# RAM Database Initialization Script

## Content

This folder includes the following scripts:

| Script Templates        | Description                                                      |
| ----------------------- | ---------------------------------------------------------------- |
| app_database_init.sql   | Create the application database, schemas, users and roles        |
| vector_storage_init.sql | [Optional] Used to enable vector storage to PostgreSQL database  |
| database_cleanup.sql    | Delete all created artifacts from database                       |

> **Please note that scripts are written for `psql` command line and won't run e.g. on pgAdmin query.**

## Prerequisites

> **Linux Only**: These database initialization scripts are designed specifically for Linux environments and use bash-specific features. They are not compatible with Windows or macOS.

### Installing envsubst

The `envsubst` tool is required to substitute environment variables in the SQL templates.

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install gettext-base
```

**CentOS/RHEL/Fedora:**

```bash
# CentOS/RHEL
sudo yum install gettext

# Fedora
sudo dnf install gettext
```

**Alpine Linux:**

```bash
apk add gettext
```

### Installing PostgreSQL Client (psql)

**Ubuntu/Debian:**

```bash
sudo apt-get install postgresql-client
```

**CentOS/RHEL/Fedora:**

```bash
sudo yum install postgresql
```

## Environment Configuration

### 1. Copy and Configure Environment File

```bash
cp sample.env .env
```

### 2. Edit the .env File

Open `.env` in your preferred text editor and configure the following variables:

```env
# Database Connection Settings
DB_HOST=localhost
DB_PORT=5432
ADMIN_DB_USERNAME=postgres
ADMIN_DB_PASSWORD=your_admin_password_here
INIT_DB_NAME=postgres

# Application Database Settings
APP_DB_NAME=your_app_database_name
APP_DB_USERNAME=your_app_user
APP_DB_PASSWORD=your_app_password

# Schema Settings (if applicable)
APP_SCHEMA=public
VECTOR_SCHEMA=vector_store

# Additional customizable variables
# (Check your SQL templates for specific variables)
```

## Create the Database manually

### Basic Usage

[Here is the complete script to run the database initialization](./create_db.sh).

After editing the environment variables, you can run the following command to finish creating the databases needed for SAS Retrieval Agent Manager:

```bash
./create_db.sh
```

## Troubleshooting

### Common Issues

1. "envsubst: command not found"
    - Solution: Install gettext package (see installation instructions above)

2. "psql: command not found"
    - Solution: Install PostgreSQL client (see installation instructions above)

3. "FATAL: password authentication failed"
    - Check your `ADMIN_DB_PASSWORD` in `.env`
    - Verify the username and database name
    - Ensure the PostgreSQL server is running

4. "could not connect to server"
    - Verify `DB_HOST` and `DB_PORT` in `.env`
    - Check if PostgreSQL server is accessible
    - Test connection: `psql -h $DB_HOST -p $DB_PORT -U $ADMIN_DB_USERNAME -d $INIT_DB_NAME -c "SELECT version();"`

5. Environment variables not being substituted
    - Ensure variables in your SQL templates use the format `${VARIABLE_NAME}`
    - Check that all variables are defined in your `.env` file
    - Verify the `.env` file doesn't have Windows line endings (CRLF) if running on Linux

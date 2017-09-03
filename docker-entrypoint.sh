#!/usr/bin/env bash
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	  local var="$1"
	  local fileVar="${var}_FILE"
	  local def="${2:-}"
	  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		    exit 1
	  fi
	  local val="$def"
	  if [ "${!var:-}" ]; then
		    val="${!var}"
	  elif [ "${!fileVar:-}" ]; then
		    val="$(< "${!fileVar}")"
	  fi
	  export "$var"="$val"
    unset "$fileVar"
}

prepare_virtenv() {
    echo >&2 "Creating Python virtualenv..."
    virtualenv -v .env
}

install_with_pip() {
    echo >&2 "Installing Python dependencies..."
    . .env/bin/activate
    pip install -r "$REQUIREMENTS_FILE"
}

result=$(prepare_virtenv)
status=$?

if [[ $status = 0 ]]; then
    result=$(install_with_pip)
    status=$?
fi

if [[ $status = 0 ]]; then
    . .env/bin/activate
    python manage.py runserver 0.0.0.0:"$DJANGO_PORT"
fi

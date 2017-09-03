FROM python:3.6-alpine
LABEL maintainer="Aristobulo Meneses <aristobulo@menecio.me>"

# Used by docker build command, has to be set with --build-arg or will use default value
ARG DJANGO_USER=django
ARG DJANGO_HOME=/opt/django
ARG DJANGO_PRJ_DIR=app

# Used by docker run, has to be set with -e or will use default value
ENV DJANGO_PORT 8000
ENV REQUIREMENTS_FILE requirements.txt

# Alpine doesn't include groupadd by default, shadow package is needed
RUN apk add --update --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community \
    shadow \
    bash

RUN pip install virtualenv

# Create django's home directory, permissions will be ajusted later
RUN mkdir -m 777 -p -v $DJANGO_HOME

# Create a new django user & group, otherwise will use root.
# Normally user ID 1000 is a good guess for the current user
RUN groupadd -r $DJANGO_USER -g 1000 && \
    useradd -u 1000 -r -g $DJANGO_USER -m -d $DJANGO_HOME -s /bin/false -c "Django User" $DJANGO_USER && \
    chown $DJANGO_USER:$DJANGO_USER $DJANGO_HOME && \
    chmod 755 $DJANGO_HOME

# Using ADD $DJANGO_PRJ_DIR $DJANGO_HOME/app will set `root` user as owner,
# this is an old and docker issue: https://github.com/moby/moby/issues/6119
# this way I can bind a local directory into my docker volume without having
# permissions set to `root` but to `django`
VOLUME $DJANGO_PRJ_DIR

WORKDIR $DJANGO_HOME/$DJANGO_PRJ_DIR

# Use django user from now and on...
USER $DJANGO_USER

EXPOSE $DJANGO_PORT

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

# Django Template

Simple dockerized application, use it as a template to save time when
creating or trying to dockerize a Django project.

## Features

- Python 3.6
- Lightweight (uses Alpine)
- Does **not** run processes as root user
- Customizable


## Customizable

This template uses some specific build arguments and environment variables to
make it easy to customize.

Available build arguments:

- `DJANGO_USER`: username of new django user.
- `DJANGO_HOME`: home directory path of new django user
- `DJANGO_PRJ_DIR`: path to your django project sources

Available environment variables:

- `DJANGO_PORT`: port used to serve your django application.
- `REQUIREMENTS_FILE`: requirements.txt file path, to be used by pip 


## Quickstart

- Build your django image
`docker build -t my_django .`

- Run a new container using your newly created image
`docker run --mount type=bind,source=$(pwd),target=/opt/django/app -p 8000:8000`


## Attention!

In order to avoid running this container using **root** as user, you will need 
to mount a volume, binding your sources directory to `$DJANGO_HOME/$DJANGO_PRJ_DIR`.

That's what's `--mount type=bind,source=$(pwd),target=/opt/django/app` for.


- Why not just using `ADD`? 

`ADD . /opt/django/app`, because it will still use **root** to include your 
sources on the docker container.


- But you could use `ADD` and after `RUN` to update the owner and permissions?
Yes, but this will duplicate the layers used, thus increasing the size of your
image 2x the size of your source.

If you have a couple of minutes you can see here **why** here:
https://github.com/moby/moby/issues/6119



## How to use build arguments

If you want to change default username, default home directory or the project 
directory, just build your image like this:

`docker build --build-arg DJANGO_USER=jonsnow --build-arg DJANGO_HOME=/thenorth --build-arg DJANGO_PRJ_DIR=winterfell -t django:got .`

This will generate a docker image that will run with **jonsnow** as owner, 
**/thenorth** as **jonsnow**'s home and **/thenorth/winterfell** as your django 
project directory. 


## How to use environment variables

Let's continue with our little example, you can change the default port and/or
the requirements.txt file at runtime:

`docker run -it --name game_of_django --mount type=bind,source=$(pwd)/sources/winterfell,target=/thenorth/winterfell -e DJANGO_PORT=4000 -p 4000:4000 django:got`


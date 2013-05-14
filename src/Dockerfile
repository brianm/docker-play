maintainer	Brian McCallister <brianm@skife.org>
from base

env DEBIAN_FRONTEND noninteractive

# required for honcho
env USER xncore

run apt-get update
run apt-get install -y netcat python python-pip

run pip install honcho
copy ./Procfile /Procfile

cmd	/bin/bash -c honcho start
expose 8000


maintainer	Brian McCallister <brianm@skife.org>
from	base
run	apt-get update
run 	DEBIAN_FRONTEND=noninteractive apt-get install -y netcat python python-pip
run	pip install honcho
insert	./Procfile /Procfile
env	USER xncore
cmd	/bin/bash -c honcho start
expose	8000


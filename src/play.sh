#!/bin/bash

function or_die() {
    ec=$?
    if [ ! ec ]
    then
        echo "failed!"
        exit $ec
    fi
}

from="ubuntu:12.10"
to="brianm/play"

img=$(docker run -d $from /bin/bash -c ls); or_die
docker wait $img; or_die
docker commit $img $to

img=$(tar -cf - -C ./a_dir . | docker run -i -a stdin $to /bin/bash -c "mkdir -p /srv/a; tar xpf - -C /srv/a")
docker wait $img; or_die
docker commit $img $to

img=$(docker commit -run '{"PortSpecs":["8000"],
                           "Cmd":["/bin/bash","-c","ls -l; ls -l /srv"],
                           "Env":["DEBIAN_FRONTEND=noninteractive",
                                  "USER=xncore",
                                  "PORT=8000"]}' \
                    $img $to); or_die

#!/bin/bash
#
set -e

image=quay.io/travisci/travis-$1
major_begin=${5:-1}
major_end=${4:-1}
minor_begin=${3:-1}
minor_end=${2:-1}

test -r /project/.travis.yml || {
    echo .travis.yml not found;
    exit 1;
}

docker pull "$image"
CONTAINER_ID=$(grep 'docker/' /proc/1/cgroup | tail -1 | sed 's/^.*\///' | cut -c 1-12)
WORKER=$(docker run -d --volumes-from "$CONTAINER_ID" -w /project -u travis "$image" \
    bash -c 'while [[ ! -r /tmp/.exit ]]; do sleep 1; done')

echo "Travis CI container $WORKER started"
set +e

if [[ "$minor_end" == "0" ]]; then
    echo -e "\e[44mRun tests for local build\e[0m"
    docker exec "$WORKER" rm -rf /home/travis/build/*

    echo generate /project/.travis.sh >| /project/.travis.sh.compile-error.txt
    travis compile --no-interactive >|/project/.travis.sh 2>>/project/.travis.sh.compile-error.txt

    # More verbose apg-get update
    sed -i 's#sudo apt-get update -qq 2>&1 >/dev/null#test -z "$(find /var/lib/apt/lists/ -mmin -60)" && sudo apt-get update#' /project/.travis.sh
    sed -i '/travis_fold start git\.checkout/,/travis_fold end git\.checkout/c \
    travis_cmd cp\\ -r\\ /project\\ . \
    travis_cmd cd\\ project' /project/.travis.sh
    sed -i '/\.gitmodules/,/^fi/d' /project/.travis.sh

    chmod a+rwx /project/.travis.sh
    docker exec -i "$WORKER" /project/.travis.sh
else
    for i in $(seq "$major_begin" "$major_end"); do
        for j in $(seq "$minor_begin" "$minor_end"); do
            echo -e "\e[44mRun tests for build $i.$j\e[0m"
            docker exec "$WORKER" rm -rf /home/travis/build/*

            echo generate /project/.travis.sh.local >| /project/.travis.sh.compile-error.txt
            travis compile --no-interactive >|/project/.travis.sh.local 2>>/project/.travis.sh.compile-error.txt

            echo generate /project/.travis.sh.remote >> /project/.travis.sh.compile-error.txt
            travis compile --no-interactive $i.$j >|/project/.travis.sh.remote 2>>/project/.travis.sh.compile-error.txt
            # More verbose apg-get update
            sed -i 's#sudo apt-get update -qq 2>&1 >/dev/null#test -z "$(find /var/lib/apt/lists/ -mmin -60)" && sudo apt-get update#' /project/.travis.sh.remote
            sed -i '/travis_fold start git\.checkout/,/travis_fold end git\.checkout/c \
            travis_cmd cp\\ -r\\ /project\\ . \
            travis_cmd cd\\ project' /project/.travis.sh.remote
            sed -i '/\.gitmodules/,/^fi/d' /project/.travis.sh.remote
            echo "merge head of .travis.sh.remote and tail of .travis.sh.local" >> /project/.travis.sh.compile-error.txt
            # get head from remote
            sed '/^EOFUNC_EXPORT/,$d' .travis.sh.remote >| .travis.sh
            # get tail from local
            sed '1,/^EOFUNC_EXPORT/c EOFUNC_EXPORT' .travis.sh.local >> .travis.sh

            chmod a+rwx /project/.travis.sh
            docker exec -i "$WORKER" /project/.travis.sh
            status=$?
            if [ "$status" -gt 0 ]
            then
                if [[ "x$KEEP" == "x" ]]; then
                    # stop $WORKER if KEEP in not set
                    docker exec "$WORKER" touch /tmp/.exit;
                    docker stop -t 1 "$WORKER";
                    docker rm "$WORKER";
                fi
                exit $status
            fi
        done
    done
fi

if [[ "x$KEEP" == "x" ]]; then
    docker exec $WORKER touch /tmp/.exit;
    docker stop -t 1 $WORKER;
    docker rm $WORKER;
fi
echo Travis CI container removed

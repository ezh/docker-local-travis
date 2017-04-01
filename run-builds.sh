#!/usr/bin/env sh
set -euo pipefail

language=$(sed -n 's/language: //p' .travis.yml)
image=quay.io/travisci/travis-$language
docker pull "$image"
CONTAINER_ID=$(cat /proc/1/cgroup | grep 'docker/' | tail -1 | sed 's/^.*\///' | cut -c 1-12)
WORKER=$(docker run -d --volumes-from $CONTAINER_ID -w /project -u travis "$image" \
    bash -c 'while [[ ! -r /tmp/.exit ]]; do sleep 1; done')
echo Travis CI container $WORKER started
for i in $(seq 1 "${LOCAL_TRAVIS_MAX_BUILDS:-10}")
do
    set +e
    travis compile "1.$i" 2>/tmp/compile-error.txt | \
        sed '/travis_fold start git\.checkout/,/travis_fold end git\.checkout/d' | \
        sed '/\.gitmodules/,/^fi/d' | \
        sed '/^cd */d' | \
        docker exec -i $WORKER bash -
    status=$?
    set -e
    if [ "$status" -gt 0 ]
    then
        if grep -q "undefined method \`config' for nil:NilClass" /tmp/compile-error.txt
        then
            status=0
        fi
        exit $status
    fi
done
docker exec $WORKER bash -c "touch /tmp/.exit"
docker stop -t 1 $WORKER
docker rm $WORKER
echo Travis CI container removed
echo "There may be more builds in the matrix, but only $i were run."

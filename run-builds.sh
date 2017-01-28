#!/usr/bin/env sh
set -euo pipefail

language=$(sed -n 's/language: //p' .travis.yml)
image=quay.io/travisci/travis-$language
docker pull "$image"
for i in $(seq 1 "${LOCAL_TRAVIS_MAX_BUILDS:-10}")
do
    set +e
    travis compile "1.$i" 2>/tmp/compile-error.txt | \
        sed '/travis_fold start git\.checkout/,/travis_fold end git\.checkout/d' | \
        sed '/\.gitmodules/,/^fi/d' | \
        sed '/^cd */d' | \
        docker \
            run \
            -i \
            --rm \
            --volumes-from "$(cat /cidfile.txt)" \
            -w /project \
            -u travis \
            "$image" \
            bash -
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
echo "There may be more builds in the matrix, but only $i were run."

# ferhai/local-travis Docker image

The `ferhai/local-travis` Docker image is useful for running your Travis
builds against your local version before pushing. This way if you want
to do local testing, you don’t need to keep a separate way of making and
invoking your build in sync with Travis.

## Quick start

Docker is required. The following command assumes a fairly standard
docker installation:

`docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v
$(pwd):/project -v $(pwd)/cidfile.txt:/cidfile.txt --cidfile cidfile.txt
ferhai/local-travis ; rm cidfile.txt`

This will run the builds defined in the `.travis.yml` in your current
directory.

## How it works

The command running in the docker image uses Travis Ci’s open-source
[travis-build](https://github.com/travis-ci/travis-build) to make
build scripts from the `.travis.yml` file. Each build script is modified
so that it works against the local copy instead of making a new clone of
the repository, and then run on one of Travis CI’s Docker images for the
language specified in the `.travis.yml` file.

The Docker socket must be mounted so that the container can make use of
the host’s Docker. The current directory containing the `.travis.yml`
file must be mounted as `/project`. The cidfile must be created and
mounted so that the containers running the builds can share the mounted
project from the first docker container. 

## Options

By default only the first 10 builds in Travis CI’s “matrix” will be run,
to prevent massively parallel builds taking too long as they are run in
serial locally. This can be changed by passing the
`LOCAL_TRAVIS_MAX_BUILDS` environment variable to the container.

## Application of license

Copyright 2016 Fergal Hainey

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Contributing

I will be very happy to take contributions for features, bug fixes,
documentation, or anything else via GitHub merge requests! I commit to
reviewing all merge requests received within 2 weeks. Please note that
all contributions shall fall under the same license as the project, and
that Fergal Hainey will remain the only listed copyright holder for ease
of maintenance and to make changing license easier if necessary.

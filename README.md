# local-travis Docker image

```
cd travis_project

docker run --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/project -e KEEP=YES travis jvm 4 4
```

arguments:
* environment - name of travis container (quay.io/travisci/travis-$1)
* minor build number `to` (optional, default 1)
* minor build number `from` (optional, default 1)
* major build number `to` (optional, default 1)
* major build number `from` (optional, default 1)

### Run tests with local configuration

Don't request Travis through API about configuration.

```
docker run --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/project -e KEEP=YES travis jvm 0
```

### Run two tests with configuration from Travis.org

```
docker run --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/project -e KEEP=YES travis jvm 2
```

# KEEP

Keep docker container running even after test completed

## How it works

The command running in the docker image uses Travis Ci’s open-source
[travis-build](https://github.com/travis-ci/travis-build) to make
build scripts from the `.travis.yml` file. Each build script is modified
so that it works against the local copy instead of making a new clone of
the repository, and then run on one of Travis CI’s Docker images for the
language specified in the `.travis.yml` file.

The Docker socket must be mounted so that the container can make use of
the host’s Docker. The current directory containing the `.travis.yml`
file must be mounted as `/project`.

## Application of license

Ten thousand thanks to Fergal Hainey!

Copyright 2017 Alexey Aksenov
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

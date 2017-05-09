FROM ruby:2.3-alpine

RUN apk add --no-cache bash build-base docker && \
    gem install bundler travis && \
    travis && \
    git clone https://github.com/travis-ci/travis-build.git && \
    cd travis-build && \
    ln -s `pwd` ~/.travis/travis-build && \
    bundle install --gemfile ~/.travis/travis-build/Gemfile && \
    apk del build-base

COPY run-tests.sh /run-tests.sh
VOLUME /project
WORKDIR /project
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]
ENTRYPOINT ["/run-tests.sh"]

FROM ruby:2.3-alpine
RUN apk add --no-cache build-base docker && \
    gem install bundler travis && \
    travis && \
    git clone https://github.com/travis-ci/travis-build.git && \
    cd travis-build && \
    ln -s `pwd` ~/.travis/travis-build && \
    bundle install --gemfile ~/.travis/travis-build/Gemfile && \
    apk del build-base
COPY run-builds.sh /run-builds.sh
VOLUME /project
WORKDIR /project
CMD ["sh", "/run-builds.sh"]

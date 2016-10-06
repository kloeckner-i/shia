FROM alpine:3.4
MAINTAINER kloeckner.i <dev@kloeckner-i.com>
RUN apk update
RUN apk add docker openssh-client
COPY ./docker/ssh /root/.ssh
RUN chmod -R 700 /root/.ssh
ENV BUILD_PACKAGES="ruby-dev build-base" \
    DEV_PACKAGES="zlib-dev yaml-dev ca-certificates" \
    RUBY_PACKAGES="ruby ruby-io-console ruby-bigdecimal ruby-json yaml"
RUN \
  echo 'gem: --no-document --no-ri' >> ~/.gemrc && \
  cp ~/.gemrc /etc/gemrc && \
  chmod uog+r /etc/gemrc

RUN mkdir -p /shia
WORKDIR /shia
COPY . ./

RUN \
  apk add --no-cache $BUILD_PACKAGES $RUBY_PACKAGES $DEV_PACKAGES && \
  gem install -N bundler && \
  gem build shia.gemspec && \
  gem install shia-*.gem && \
  rm -rf /usr/lib/ruby/gems/*/cache/* && \
  rm -rf /root/.bundle/cache/* && \
  apk del build-base

CMD shia -h

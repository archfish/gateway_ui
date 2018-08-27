FROM ruby:2.4-alpine as Builder

ARG FOLDERS_TO_REMOVE
ARG BUNDLE_WITHOUT
ARG RAILS_ENV
ARG NODE_ENV
ARG APP_ROOT

ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV RAILS_ENV ${RAILS_ENV}
ENV NODE_ENV ${NODE_ENV}
ENV SECRET_KEY_BASE=foo

RUN apk add --update --no-cache \
    build-base \
    git \
    nodejs \
    yarn \
    tzdata

WORKDIR ${APP_ROOT}

COPY ./ ./

RUN gem source --remove https://rubygems.org/ \
    && gem source --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ \
    && bundle config --global frozen 1 \
    && bundle install -j4 --retry 3 \
    && yarn install \
    && bundle exec rake assets:clean[0] \
    && bundle exec rake assets:precompile \
    && bundle exec rake tmp:clear \
    && bundle exec rake log:clear \
    && rm -rf /usr/local/bundle/cache/*.gem \
    && find /usr/local/bundle/gems/ -name "*.c" -delete \
    && find /usr/local/bundle/gems/ -name "*.o" -delete \
    && rm -rf $FOLDERS_TO_REMOVE

FROM ruby:2.4-alpine
LABEL maintainer="weihailang[A]gmail.com"

ARG ADDITIONAL_PACKAGES
ARG EXECJS_RUNTIME
ARG APP_ROOT
ARG RAILS_ENV

RUN apk add --update --no-cache \
    $ADDITIONAL_PACKAGES \
    tzdata \
    file

RUN addgroup -g 1001 -S rails \
    && adduser -u 1001 -S rails -G rails

USER rails

COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=rails:rails ${APP_ROOT} ${APP_ROOT}

ENV RAILS_ENV ${RAILS_ENV}
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV EXECJS_RUNTIME $EXECJS_RUNTIME
ENV GATEWAY_BACKEND="localhost:9093"

WORKDIR ${APP_ROOT}

EXPOSE 3000

CMD [ "bundle", "exec", "rails", "s", "-b", "0.0.0.0" ]

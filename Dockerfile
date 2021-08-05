FROM ruby:2.7.4-alpine

RUN apk add --update --upgrade build-base postgresql-dev

RUN mkdir -p /pgdiff

WORKDIR /pgdiff

COPY lib /pgdiff
COPY bin /pgdiff
COPY Gemfile Gemfile.lock /pgdiff/

RUN bundle install
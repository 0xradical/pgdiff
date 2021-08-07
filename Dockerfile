FROM ruby:2.7.4-alpine

RUN apk add --update --upgrade build-base postgresql postgresql-dev less

RUN mkdir -p /pgdiff
RUN mkdir -p /pgdiff/migrations

WORKDIR /pgdiff

COPY lib /pgdiff/lib
COPY bin /pgdiff/bin
COPY Gemfile Gemfile.lock /pgdiff/

RUN bundle install
# pgdiff

This is my attempt at building a postgres database structure diff tool
that generates [DDL](https://en.wikipedia.org/wiki/Data_definition_language) statements that when applied, 
makes a target database structurally equivalent to a source database.

It can also create a structure folder from any database. This folder contains almost all
structural components of a postgres database: aggregates, composites, domains, enums, functions,
tables, views, extensions, roles and schemas.

## Motivation

Image you keep a structure.sql file that describes your database structure. This tool is responsible for,
given a change in this structure.sql file, generate the corresponding DDL statements, when run in the target database,
applies the changes that match the updated structure.sql.

## Getting Started

In order to use and test this tool, I've set up docker compose files that 
describe how to spin up two databases representing source and target, respectively. 
Their respective structures are initially loaded based off their files under entrypoints.

## Prerequisites

* Docker
* Docker Compose
* Make
* Ruby (>= 2.7)
* Bundler
* Postgres Development Libraries

On Apple Silicon, after installing the libpq, running gem install pg -v '1.2.3' -- --with-pg-config=/opt/homebrew/opt/libpq/bin/pg_config

## Setup

Run the following commands:

```bash
  bundle install
```

## Usage

* Structural diff tool:

```bash
  ruby bin/pgdiff.rb
```

* Destructure tool:

```bash
  ruby bin/destructure.rb
```

Both of these commands, with no arguments, will
return the help menu which will guide you how to use
them properly. It's pretty self-explanatory.

If you want examples, run the following make tasks:

* make structure-example
* make pgdiff-example

<!-- LICENSE -->
## License

Distributed under the Apache License. See `LICENSE` for more information.

# pgdiff

This is my attempt at building a postgres database structure diff tool
that generates [DDL](https://en.wikipedia.org/wiki/Data_definition_language) statements that when applied, 
makes a target database structurally equivalent to a source database.

It can also create a structure folder from any database. This folder contains almost all
structural components of a postgres database: aggregates, composites, domains, enums, functions,
tables, views, extensions, roles and schemas.

## Usage

<!-- LICENSE -->
## License

Distributed under the Apache License. See `LICENSE` for more information.

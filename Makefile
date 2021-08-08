VERSION := 0.0.3

build:
	@docker build -f Dockerfile . -t thiagobrandam/pgdiff:$(VERSION)
	@docker build -f Dockerfile.database . -t thiagobrandam/pgdiff-database

push:
	@docker push thiagobrandam/pgdiff:$(VERSION)

up:
	@make -s down
	@docker-compose up -d source.database.io
	@docker-compose up -d target.database.io

run-%:
	@make -s down
	@docker-compose up $*.database.io

down:
	@docker-compose down

console: up
	@bundle exec pry -r ./lib/pgdiff.rb -r ./bin/console.rb

sql: up
	@bundle exec ruby -r ./lib/pgdiff.rb -r ./bin/console.rb

diff: up
	@rm -f pgdiff.sql
	@echo 'Generating pgdiff.sql'
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/test.rb
	@echo 'Applying generated pgdiff.sql'
	@cat pgdiff.sql
	@docker run --rm -ti --name pgdiff_migration --network pgdiff --env-file ${PWD}/database.env -v ${PWD}/pgdiff.sql:/pgdiff.sql thiagobrandam/pgdiff:$(VERSION) sh -c "cat /pgdiff.sql | PGPASSWORD=\$$POSTGRES_PASSWORD psql -h target.database.io -U \$$POSTGRES_USER -d \$$POSTGRES_DB"
	@echo 'Generating another pgdiff.sql to compare'
	@mv pgdiff.sql pgdiff.initial.sql
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/test.rb
	@cat pgdiff.sql

test: up
	@bundle exec rake test

psql-source:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54532 -d pgdiff

psql-target:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54533 -d pgdiff
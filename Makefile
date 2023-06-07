VERSION := 1.0.1

build:
	@docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile . -t classpert/pgdiff:$(VERSION) --push
	@docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile.database . -t classpert/pgdiff-database --push

push:
	@docker push classpert/pgdiff:$(VERSION)

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

bash:
	@docker run --rm -it classpert/pgdiff:$(VERSION) sh

diff: up
	@rm -f pgdiff.sql
	@echo 'Generating pgdiff.sql'
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/test.rb
	@echo 'Applying generated pgdiff.sql'
	@cat pgdiff.sql
	@docker run --rm -ti --name pgdiff_migration --network pgdiff --env-file ${PWD}/database.env -v ${PWD}/pgdiff.sql:/pgdiff.sql classpert/pgdiff:$(VERSION) sh -c "cat /pgdiff.sql | PGPASSWORD=\$$POSTGRES_PASSWORD psql -h target.database.io -U \$$POSTGRES_USER -d \$$POSTGRES_DB"
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
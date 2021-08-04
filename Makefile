build:
	@docker build . -t thiagobrandam/pgdiff

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

diff: up
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/diff.rb
	@echo 'Applying generated pgdiff.sql'
	@docker exec -ti target.database.io sh -c "cat /pgdiff/pgdiff.sql | psql -U \$$POSTGRES_USER -d \$$POSTGRES_DB"

test: up
	@bundle exec rake test

psql-source:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54532 -d pgdiff

psql-target:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54533 -d pgdiff
build:
	@docker build . -t thiagobrandam/pgdiff

up:
	@make -s down
	@docker-compose up -d source.database.io
	@docker-compose up -d target.database.io

down:
	@docker-compose down

console: up
	@bundle exec pry -r ./lib/pgdiff.rb -r ./bin/console.rb

test: up
	@bundle exec rake test

psql-source:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54532 -d pgdiff

psql-target:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54533 -d pgdiff
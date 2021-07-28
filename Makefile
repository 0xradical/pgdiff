build:
	@docker build . -t thiagobrandam/pgdiff

up:
	@make -s down
	@docker-compose up -d source.database.io
	@docker-compose up -d target.database.io

down:
	@docker-compose down

console:
	@bundle exec pry -r ./lib/pgdiff.rb
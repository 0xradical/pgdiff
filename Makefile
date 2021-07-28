build:
	@docker build . -t thiagobrandam/pgdiff

up:
	@make -s down
	@docker-compose up source.database.io
	@docker-compose up target.database.io

down:
	@docker-compose down
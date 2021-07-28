docker-build:
	@docker build . -t thiagobrandam/pgdiff

docker-up:
	@docker-compose up source.database.io
	@docker-compose up target.database.io
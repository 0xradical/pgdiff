.PHONY: clean

build:
	@docker build -f Dockerfile . -t pgdiff --push

clean:
	@rm -rf output
	@mkdir output

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
	@docker run --rm -it pgdiff sh

# run this to make sure that diff is working
# i.e., the structures should have no difference
# when the diff is applied
diff: up
	@rm -f pgdiff.sql
	@echo 'Generating pgdiff.sql'
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/test.rb
	@echo 'Applying generated pgdiff.sql'
	@cat pgdiff.sql
	@docker run --rm -ti --name pgdiff_migration --network pgdiff --env-file ${PWD}/database.env -v ${PWD}/pgdiff.sql:/pgdiff.sql pgdiff sh -c "cat /pgdiff.sql | PGPASSWORD=\$$POSTGRES_PASSWORD psql -h target.database.io -U \$$POSTGRES_USER -d \$$POSTGRES_DB"
	@echo 'Generating another pgdiff.sql to compare'
	@mv pgdiff.sql pgdiff.initial.sql
	@bundle exec ruby -r ./lib/pgdiff.rb ./bin/test.rb
	@cat pgdiff.sql

structure-example: clean up
	@ruby bin/destructure.rb --source-host 0.0.0.0 \
	                         --source-port 54532 \
													 --source-user postgres \
													 --source-password postgres \
													 --source-database pgdiff \
													 --output-dir ./output

pgdiff-example: clean up
	@ruby bin/pgdiff.rb --source-host 0.0.0.0 \
	                    --source-port 54533 \
											--source-user postgres \
											--source-password postgres \
											--source-database pgdiff \
											--target-host 0.0.0.0 \
											--target-port 54532 \
											--target-user postgres \
											--target-password postgres \
											--target-database pgdiff \
											--output-dir ./output

test: up
	@bundle exec rake test

psql-source:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54532 -d pgdiff

psql-target:
	@PGPASSWORD=postgres psql -U postgres -h 0.0.0.0 -p 54533 -d pgdiff

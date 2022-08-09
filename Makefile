.PHONY: help bundle

default: help

logs: #: Tails the logs for the app (tail -f log/development.log)
	docker-compose logs -f app

routes: #: Rails routes (rake routes)
	docker-compose run --rm app bundle exec rails routes

up: #: Starts the app in the background
	docker-compose up -d

test: #: Run the tests
	docker-compose run --rm app bundle exec rspec

down: #: Stops the app
	docker-compose down

bundle: #: Installs gems, docker-compose down must be run before
	docker-compose run --rm app bundle install

console: #: Start a rails console
	docker-compose run --rm app bundle exec rails console

bash: #: Start a bash shell
	docker-compose run --rm app bash

build: #: Build the app
	docker-compose build app

dbmigrate: #: Migrate the database
	docker-compose run --rm app bundle exec rails db:migrate
	docker-compose run --rm -e RAILS_ENV=test app bundle exec rails db:migrate

dbcreate: #: Create the database
	docker-compose run --rm app bundle exec rails db:create db:schema:load

dbseed: #: Seed the database
	docker-compose run --rm app bundle exec rails db:seed

dbdrop: #: Drop the database
	docker-compose run --rm app bundle exec rails db:drop

chown: #: Change owner and group of all files in repo to current user
	sudo chown -R $(USER):$(USER) *

prune: #: Remove unused images from local machine
	docker image prune

zip: #: Zip repo to share with others
	cd .. && zip -r sp_project.zip simplepractice-interview-test/ --exclude \*.git\* \*tmp\* \*log\* \*tags\*

help: #: Show help topics
	@grep "#:" Makefile* | grep -v "@grep" | sort | sed "s/\([A-Za-z_ -]*\):.*#\(.*\)/$$(tput setaf 3)\1$$(tput sgr0)\2/g"

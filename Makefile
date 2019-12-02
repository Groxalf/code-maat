.PHONY: build
APP_REPO := git@git.mitula.com:maven/Mitula.git

build:
	docker-compose build

analyze:
	cd app && git log --pretty=format:'[%h] %aN %ad %s' --date=short --numstat --after=2017-01-01 --no-renames -- . ":(exclude).*" ":(exclude)pom.xml" ":(exclude)*.txt" ":(exclude)*.js" ":(exclude)*.css" ":(exclude)*.properties " > ../data/app.log
	docker-compose run maat -l /data/app.log -a coupling -c git > results/coupling.csv
	docker-compose run maat -l /data/app.log -a author-churn -c git > results/author-churn.csv
	docker-compose run maat -l /data/app.log -a age -c git > results/age.csv
	docker-compose run maat -l /data/app.log -a summary -c git > results/summary.csv
	docker-compose run maat -l /data/app.log -a abs-churn -c git > results/absolute-churn.csv
	docker-compose run maat -l /data/app.log -a revisions -c git > results/revision.csv
	
download-app: clean
	git clone ${APP_REPO} app

clean:
	rm -rf app/
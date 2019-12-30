.PHONY: build
#APP_REPO := git@git.mitula.com:maven/Mitula.git
#APP_NAME := mitula
APP_REPO := git@git.mitula.com:maven/NestoriaSite.git
APP_NAME := nestoria
#APP_REPO := git@git.mitula.com:maven/MitulaFrases.git
#APP_NAME := frases
#APP_REPO := git@git.mitula.com:mitulagroup/alerts.git
#APP_NAME := alerts

build:
	docker-compose build

analyze: download-app
	mkdir -p results/${APP_NAME}
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a coupling -c git > results/${APP_NAME}/coupling.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a author-churn -c git > results/${APP_NAME}/author-churn.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a age -c git > results/${APP_NAME}/age.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a summary -c git > results/${APP_NAME}/summary.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a abs-churn -c git > results/${APP_NAME}/absolute-churn.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a revisions -c git > results/${APP_NAME}/revision.csv
	
download-app: clean
	git clone ${APP_REPO} ${APP_NAME}
	export FIRST_COMMIT_DATE=$(cd ${APP_NAME} && git log --reverse --pretty='%ad' --date=format:'%Y/%m/%d' | sed -n 1p)
	mkdir -p data/${APP_NAME}
	cd ${APP_NAME} && git log --pretty=format:'[%h] %aN %ad %s' --date=short --numstat --after=${FIRST_COMMIT_DATE} --no-renames -- . ":(exclude)pom.xml" ":(exclude)*.txt" ":(exclude)*.js" ":(exclude)*.css" ":(exclude)*.properties" > ../data/${APP_NAME}/${APP_NAME}.log
	make clean

clean:
	rm -rf ${APP_NAME}/
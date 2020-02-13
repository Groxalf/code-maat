.PHONY: build start mitula nestoria alerts frases mitula_business create_log

start:
	docker build -t mitula-quality .
	docker run -it mitula-quality

process_apps: mitula nestoria alerts mitula_business frases

mitula: export APP_REPO=git@gitlab.mad.mitulagroup.net:maven/Mitula.git
mitula: export APP_NAME=mitula
mitula:
	make analyze

nestoria: export APP_REPO=git@gitlab.mad.mitulagroup.net:maven/NestoriaSite.git
nestoria: export APP_NAME=nestoria
nestoria:
	make analyze

alerts: export APP_REPO=git@gitlab.mad.mitulagroup.net:mitulagroup/alerts.git
alerts: export APP_NAME=alerts
alerts:
	make analyze

frases: export APP_REPO=git@gitlab.mad.mitulagroup.net:maven/MitulaFrases.git
frases: export APP_NAME=frases
frases:
	make analyze

mitula_business: export APP_REPO=git@gitlab.mad.mitulagroup.net:maven/MitulaBusiness.git
mitula_business: export APP_NAME=mitula_business
mitula_business:
	make analyze

build:
	docker-compose build

analyze: download-app create_log
	mkdir -p results/${APP_NAME}
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a coupling -c git > results/${APP_NAME}/coupling.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a author-churn -c git > results/${APP_NAME}/author-churn.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a age -c git > results/${APP_NAME}/age.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a summary -c git > results/${APP_NAME}/summary.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a abs-churn -c git > results/${APP_NAME}/absolute-churn.csv
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a revisions -c git > results/${APP_NAME}/revision.csv
	
download-app: clean
	git clone ${APP_REPO} apps/${APP_NAME}

create_log: export FIRST_COMMIT_DATE=$(shell cd apps/${APP_NAME} && git log --reverse --pretty='%ad' --date=format:'%Y/%m/%d' | sed -n 1p)
create_log:
	mkdir -p data/${APP_NAME}
	cd apps/${APP_NAME} && git log --pretty=format:'[%h] %aN %ad %s' --date=short --numstat --after=${FIRST_COMMIT_DATE} --no-renames -- . ":(exclude)pom.xml" ":(exclude)*.txt" ":(exclude)*.js" ":(exclude)*.css" ":(exclude)*.properties" > ../../data/${APP_NAME}/${APP_NAME}.log
	make clean

clean:
	rm -rf apps/${APP_NAME}/
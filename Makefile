.PHONY: build start mitula nestoria alerts frases mitula_business

start: mitula nestoria alerts frases mitula_business

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
	docker-compose run maat -l /data/${APP_NAME}/${APP_NAME}.log -a revisions -c git > results/${APP_NAME}/revision.csv
	
download-app: clean
	git clone ${APP_REPO} ${APP_NAME}

create_log: export FIRST_COMMIT_DATE=$(cd ${APP_NAME} && git log --reverse --pretty='%ad' --date=format:'%Y/%m/%d' | sed -n 1p)
create_log:
	mkdir -p data/${APP_NAME}
	cd ${APP_NAME} && git log --pretty=format:'[%h] %aN %ad %s' --date=short --numstat --after=${FIRST_COMMIT_DATE} --no-renames -- . ":(exclude)pom.xml" ":(exclude)*.txt" ":(exclude)*.js" ":(exclude)*.css" ":(exclude)*.properties" > ../data/${APP_NAME}/${APP_NAME}.log
	make clean

clean:
	rm -rf ${APP_NAME}/
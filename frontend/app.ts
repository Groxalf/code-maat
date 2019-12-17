import mustacheExpress = require("mustache-express");

const csv = require("csvtojson");
const _ = require('lodash');
const express = require('express');

const PORT = 8001;

const app = express();
app.engine('mustache', mustacheExpress());
app.set('view engine', 'mustache');
app.set('views', __dirname + '/templates');

app.get('/coupling/:app_name', async (req, res) => {
    const appName = req.params['app_name'];
    res.render("coupling.mustache", {files: JSON.stringify(await retrieveCoupledClasses(appName))})
});

app.get('/revisions/:app_name', async (req, res) => {
    const appName = req.params['app_name'];
    async function parseRevisions() {
        return [{
            file: "parent",
            parent: "",
            revisions: 0
        }, ...(await retrieveRevision({appName, minRevisions: 20})).map(c => ({...c, parent: "parent"}))];
    }
    res.render("revisions.mustache", {files: JSON.stringify(await parseRevisions())})
});


app.listen(PORT, () => console.log(`Server running on port: ${PORT}`));

function retrieveAbsoluteChurn(): Promise<Array<{ date: string, added: string, deleted: string }>> {
    return new Promise((resolve => {
        csv()
            .fromFile("results/absolute-churn.csv")
            .then(jsonObject => {
                resolve(jsonObject);
            });
    }));
}

function getFileName(path) {
    return path.substr(path.lastIndexOf("/") + 1, path.length);
}

function retrieveRevision({appName, minRevisions = 0}: { appName: string, minRevisions: number }): Promise<Array<{ file: string; revisions: number }>> {
    return new Promise((resolve => {
        csv()
            .fromFile(`results/${appName}/revision.csv`)
            .then(json => json.map(it => (
                {
                    file: getFileName(it.entity),
                    path: it.entity,
                    revisions: Number.parseInt(it["n-revs"])
                })))
            .then(revisions => revisions.filter(revision => revision.revisions > minRevisions))
            .then(resolve)
    }));
}

function retrieveCoupledClasses(appName: string): Promise<Array<{ file: string, coupled: Array<{ file: string, coupledFile: string, degree: string, path: string }> }>> {
    return new Promise((resolve) => {
        csv()
            .fromFile(`results/${appName}/coupling.csv`)
            .then(json =>
                json.map(it => ({
                    file: getFileName(it.entity),
                    coupledFile: getFileName(it.coupled),
                    degree: it.degree,
                    path: it.entity
                }))
            ).then(files => _.groupBy(files, 'coupledFile'))
            .then(files => Object.keys(files).map(it => ({
                file: it,
                coupled: files[it]
            })))
            .then(resolve)
    })
}
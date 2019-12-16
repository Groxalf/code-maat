import * as fs from "fs";
import mustacheExpress = require("mustache-express");

const csv = require("csvtojson");
const _ = require('lodash');
const Mustache = require('mustache');
const express = require('express');

const PORT = 8001;

const app = express();
app.engine('mustache', mustacheExpress());
app.set('view engine', 'mustache');
app.set('views', __dirname + '/templates');

app.get('/coupling', async (req, res) => {
    res.render("coupling.mustache", {classes: JSON.stringify(await retrieveCoupledClasses())})
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

function retrieveRevision({minRevisions = 0}: { minRevisions: number }): Promise<Array<{ file: string; revisions: number }>> {
    return new Promise((resolve => {
        csv()
            .fromFile("results/revision.csv")
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

function retrieveCoupledClasses(): Promise<Array<{ file: string, coupled: Array<{ file: string, coupledFile: string, degree: string, path: string }> }>> {
    return new Promise((resolve) => {
        csv()
            .fromFile("results/coupling.csv")
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
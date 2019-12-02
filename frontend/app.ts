const csv = require("csvtojson");
const d3 = require("d3");
const {JSDOM} = require("jsdom");
const fs = require("fs");

async function start() {
    try {
        const data = (await retrieveRevision({minRevisions: 30})).map(it => Object.assign(it, {parent:"code"}));
        const dom = new JSDOM();
        let body = dom.window.document.body;
        data.unshift({parent: "", file: "code", revisions: undefined});

        const vWidth = 1500;
        const vHeight = 768;
        const svg = d3.select(body).append("svg").attr('width', vWidth).attr('height', vHeight);
        const div = d3.select(body).append("div")
            .attr("class", "tooltip")
            .style("opacity", 0);


        const stratify = d3.stratify()
            .id(d =>d.file)
            .parentId(d =>d.parent);
        const treeData = stratify(data);
        treeData.each(d => d.file = d.id);

        drawViz(treeData);

        function drawViz(vData) {
            const vLayout = d3.treemap().size([vWidth, vHeight]).padding(4);
            const vRoot = d3.hierarchy(vData).sum(d =>d.data.revisions);
            const vNodes = vRoot.descendants();
            vLayout(vRoot);
            const vSlices = svg.selectAll('rect').data(vNodes).enter().append('rect');
            vSlices.attr('x', d =>d.x0)
                .attr('y', d =>d.y0)
                .attr('width', d =>d .x1 - d.x0)
                .attr('height', d =>d.y1 - d.y0)
                .style("stroke", "black")
                .style("fill", "#69b3a2")
                .on("mouseover", function(d) {
                    div.transition()
                        .duration(200)
                        .style("opacity", .9);
                    div	.html(d.data.id)
                        .style("left", (d3.event.pageX) + "px")
                        .style("top", (d3.event.pageY - 28) + "px");
                });

            svg.selectAll('svg').data(vNodes).enter()
                .append('text')
                .attr('x', d => d.x0)
                .attr('y', d => d.y0)
                .text( d => { if (d.data.depth>0) return d.data.id })
                .attr("dy", "1em")
                .attr("dx", "1em")
                .attr("fill", "white");
        }

        console.log(data);
    } catch (e) {
        console.log(e);
    }

}

function retrieveAbsoluteChurn(): Promise<Array<{ date: string, added: string, deleted: string }>> {
    return new Promise((resolve => {
        csv()
            .fromFile("results/absolute-churn.csv")
            .then(jsonObject => {
                resolve(jsonObject);
            });
    }));
}

function retrieveRevision({minRevisions = 0}: { minRevisions: number }): Promise<Array<{ file: string; revisions: number }>> {
    return new Promise((resolve => {
        csv()
            .fromFile("results/revision.csv")
            .then(json => json.map(it => ({file: it.entity.substr(it.entity.lastIndexOf("/") + 1, it.entity.length), revisions: Number.parseInt(it["n-revs"])})))
            .then(revisions => revisions.filter(revision => revision.revisions > minRevisions))
            .then(resolve)
    }));
}

start();
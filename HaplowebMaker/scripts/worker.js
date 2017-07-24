self.importScripts("FastaParsing.js", "MJAlgo.js");

Printer = function () {
    this.indent = "  ";
    this.newline = "\n";
    this.countingOffset = 1;
    this.l = [];
    this.printString = function (s) {
        this.l.push(s);
    };
    this.close = function () {};
    this.toText = function () {
        return this.l.join("");
    }
}

function setProgress(stepsDone, stepsToDo) {
    self.postMessage([
        {
            "key" : ["progress"],
            "val" : Math.floor(stepsDone / stepsToDo * 100)
        }
    ]);
}
function setFileVal(i, key, val) {
    self.postMessage([
        {
            "key" : ["faFiles", i, key],
            "val" : val
        }
    ]);
}
function calculateFaFile(project, i) {
    try {
        // ok, set that we are processing this file
        setFileVal(i, "start", Date.now());
        setFileVal(i, "status", "running.label");
        // read the file content to a fasta file
        var fc = parsing_FastaParser.parseFasta(project["faFiles"][i]["data"]);
        setProgress(++stepsDone, stepsToDO);
        setFileVal(i, "endParsing", Date.now());
        // end parsing - now run mj algo
        var m = new mj_MJAlgo();
        var current = fc.h;
        while(current != null && current != undefined) {
            var seqName = current.item.first, seq = current.item.second;
            if(project["upperLowerCase"]) {
                m.addSequence(seqName.toUpperCase(), seq.toUpperCase());
            } else {
                m.addSequence(seqName, seq);
            }
            current = current.next;
        }
        m.finishedAddingSequences();
        m.runMJ(project["epsilon"]);
        var p = new Printer();
        m.finalizeNetwork().printTxt(p);
        setFileVal(i, "mj", p.toText());
        setFileVal(i, "nrSeqs", m.getNrSeqs());
        setFileVal(i, "nrDifSeqs", m.getNrDifSeqs());
        setFileVal(i, "seqLen", m.getSeqLength());
        setFileVal(i, "intPos", m.getNrInterestingPositions());
        setFileVal(i, "ffrs", m.getNrFFRs());
        setProgress(++stepsDone, stepsToDO);
        setFileVal(i, "endMJ", Date.now());
        // end of mj - now draw
// TODO
        setFileVal(i, "endDraw", Date.now());
        // end of drawing - end of this file
        setFileVal(i, "status", "okstatus.label");
    } catch(e) {
        setFileVal(i, "status", "failed.label");
        setFileVal(i, "statusDescription", e.message);
        stepsDone = (i+1) * 3;
        setProgress(stepsDone, stepsToDO);
    }
}

self.addEventListener('message', function(e) {
    var project = e.data;
    // for processbar
    stepsToDO = project["faFiles"].length * 3 + 1; // for each file - parsing, create haploweb, assing svg drawing positions & run coma
    stepsDone = 0;
    // do every file
    for(var i = 0; i < project["faFiles"].length; i++) {
        stepsDone = calculateFaFile(project, i);
    }
    // do coma
// TODO
    // safe end time
    self.postMessage([{ "key" : ["calculationEndDate"], "val" : Date.now() }]);
    setProgress(100, 100); // in any case - here is the end
}, false);

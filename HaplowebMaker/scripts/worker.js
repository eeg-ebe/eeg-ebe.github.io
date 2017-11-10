self.importScripts("FastaParsing.js", "MJAlgo.js", "Drawing.js", "coma.js", "LstExtractor.js");

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
    var progress = Math.floor(stepsDone / stepsToDo * 100);
    progress = Math.min(99, progress);
    self.postMessage([
        {
            "key" : ["progress"],
            "val" : progress
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
        if(typeof project["delimiter"] !== "undefined") {
            mj_Seq.delimiter = project["delimiter"];
        }
        if(typeof project["areaShouldBePropToNrInd"] !== "undefined") {
            draw_NodePos.areaShouldBePropToNrInd = !!project["areaShouldBePropToNrInd"];
        }
        var m = new mj_MJAlgo();
        var current = fc.h;
        while(current != null && current != undefined) {
            var seqName = current.item.first, seq = current.item.second;
            // check whether to add warning
            if(seq.charAt(0) == "-" || seq.charAt(seq.length - 1) == "-") {
                if(!self.addedIndelIs5thStateWarning) {
                    project["notifications"].push({ "ui" : "highlight", "icon" : "info", "text" : "indelIs5State.text" });
                    self.postMessage([{ "key" : ["notifications"], "val" : project["notifications"] }]);
                }
                self.addedIndelIs5thStateWarning = true;
            }
            // check sequence
            for(var chIndex = 0; chIndex < seq.length; chIndex++) {
                var c = seq.charAt(chIndex).toUpperCase();
                if(!(c == 'A' || c == 'T' || c == 'G' || c == 'C' || c == '-')) {
                    if (c == 'R' || c == 'Y' || c == 'K' || c == 'M' || c == 'S' || c == 'W' || c == 'B' || c == 'D' || c == 'H' || c == 'V' || c == 'N') {
                        throw new js__$Boot_HaxeError("Your input FASTA file contains one or several ambiguities (" + c + "). Please make sure that all your sequences are properly phased and do not contain any ambiguities before running HaplowebMaker.");
                    }
                    throw new js__$Boot_HaxeError("Your input FASTA file contains one or several unauthorized characters (" + c + ")!");
                }
            }
            // go on
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
        var netTxt = p.toText();
        project["faFiles"][i]["mj"] = p.toText();
        setFileVal(i, "mj", project["faFiles"][i]["mj"]);
        setFileVal(i, "nrSeqs", m.getNrSeqs());
        setFileVal(i, "nrDifSeqs", m.getNrDifSeqs());
        setFileVal(i, "seqLen", m.getSeqLength());
        setFileVal(i, "intPos", m.getNrInterestingPositions());
        setFileVal(i, "ffrs", m.getNrFFRs());
        setFileVal(i, "inds", m.countIndiv());
        setProgress(++stepsDone, stepsToDO);
        setFileVal(i, "endMJ", Date.now());
        // end of mj - now draw
        var g = new draw_Graph(parsing_MJNetParser.parseNet(netTxt));
        g.forceDirectedMethod(true, 0.6, 0.5, 500.0, 0.1, 0.1, 10000);
        g.centerPos();
//        g.stretch(0.1);
        g.assignLinkPos();
        // assign pie charts if needed
        if(typeof project["pieChart"] !== "undefined") {
            g.assingPiesByTxt(project["pieChart"], project["upperLowerCase"], project["pieByIndNameOnly"]);
        } else if(typeof project["assignRandomColoresToFFRs"] !== "undefined") {
            g.colorNetwork();
        }
        // return result
        setFileVal(i, "graphstyle", g.saveStyle());
        setFileVal(i, "svg", g.getSvgCode());
        setFileVal(i, "endDraw", Date.now());
        // end of drawing - end of this file
        setFileVal(i, "status", "okstatus.label");
    } catch(e) {
console.log("XXX " + e);
        setFileVal(i, "status", "failed.label");
        setFileVal(i, "statusDescription", e.message);
        stepsDone = (i+1) * 3;
        setProgress(stepsDone, stepsToDO);
    }
}

self.addEventListener('message', function(e) {
    var project = e.data;
    self.addedIndelIs5thStateWarning = false;
    // for processbar
    stepsToDO = project["faFiles"].length * 3 + 1; // for each file - parsing, create haploweb, assing svg drawing positions & run coma
    stepsDone = 0;
    // do every file
    for(var i = 0; i < project["faFiles"].length; i++) {
        calculateFaFile(project, i);
    }
    // do coma
//    try {
        var a = new Array(project["faFiles"]);
        for(var i = 0; i < project["faFiles"].length; i++) {
            var p = new Printer();
            LstExtractor.extract(p, project["faFiles"][i]["mj"], true, false, false, false, project["delimiter"]);
            a[i] = p.toText();
        }
        var p = new Printer();
        CoMa.runComaJS(a, p);
        var comaTxt = p.toText();
        self.postMessage([
            {
                "key" : ["coma"],
                "val" : comaTxt
            }
        ]);
/*
    } catch(e) {
console.log("XXX " + e);
    }
*/
    // safe end time
    self.postMessage([{ "key" : ["calculationEndDate"], "val" : Date.now() }]);
    self.postMessage([
        {
            "key" : ["progress"],
            "val" : 100
        }
    ]);
}, false);

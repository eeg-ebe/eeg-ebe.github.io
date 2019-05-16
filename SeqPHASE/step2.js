window.onerror = function(msg, url, line, col, error) {
    alert("Error " + msg + ", line " + line);
}

function resetConstFileUpload() {
    document.getElementById("passedSpan").style.display = "none";
    var cell = document.getElementById("passedConstFileContent");
    cell.textContent = "";
    var changeLink = document.getElementById("changePassedConstFile");
    changeLink.onclick = resetConstFileUpload;
    document.getElementById("passedDescription").style.display = "none";
    var constFile = document.getElementById("constFile");
    constFile.style.display = "block";
    document.getElementById("completePassedConstFileContent").value = "";
}

function setConstFileContent(str) {
    var displayStr = str;
    if(str.length > 15) {
        displayStr = str.substr(0, 12) + "...";
    }
    document.getElementById("passedSpan").style.display = "block";
    var cell = document.getElementById("passedConstFileContent");
    cell.textContent = displayStr;
    var changeLink = document.getElementById("changePassedConstFile");
    changeLink.onclick = resetConstFileUpload;
    document.getElementById("passedDescription").style.display = "block";
    var constFile = document.getElementById("constFile");
    constFile.style.display = "none";
    document.getElementById("completePassedConstFileContent").value = str;
}

function clearURI() {
    window.history.replaceState({}, document.title, window.location.pathname);
}

var uri = window.location.search;
if(uri != null && uri != "") {
    if(uri.startsWith("?")) {
        uri = uri.substr(1);
    }
    var parts = uri.split("&");
    for(var i = 0; i < parts.length; i++) {
        if(parts[i].startsWith("constFileContent=")) {
            var constFileContent = parts[i].substr(17).trim().toUpperCase();
            if(constFileContent != null && constFileContent != "") {
                setConstFileContent(constFileContent);
                clearURI();
            }
        }
    }
}

function resetForm() {
    document.getElementById("phaseOutFile").value = "";
    resetConstFileUpload();
    document.getElementById("constFile").value = "";
    document.getElementById("sortSequences").checked = "checked";
    document.getElementById("reduceSequences").checked = "checked";
}
document.getElementById("resetJob2Button").onclick = resetForm;

function handleResults(result) {
    document.getElementById("resultArea").style.display = "block";
    var b64 = window.btoa(result);
    document.getElementById("downloadLink").href = 'data:text/plain;base64,\n'+b64;
}

function run(sort, reduce, outFile, constFile) {
    var result = SeqPhase2.parse(outFile, constFile).getFasta(reduce, sort);
    window.setTimeout(function() {
        handleResults(result)
    }, 0);
}

function runReadConstFile(sort, reduce, outFileContent) {
    var constFile = document.getElementById("constFile");
    if(document.getElementById("completePassedConstFileContent").value != "") {
        var contFileContent = document.getElementById("completePassedConstFileContent").value;
        window.setTimeout(function() {
            run(sort, reduce, outFileContent, constFileContent);
        }, 0);
    } else if(constFile.files.length == 0) {
        window.setTimeout(function() {
            run(sort, reduce, outFileContent, "");
        }, 0);
    } else if(constFile.files.length == 1) {
        var reader = new FileReader();
        reader.onload = function(data) {
            var constFileContent = data.target.result;
            window.setTimeout(function() {
                run(sort, reduce, outFileContent, constFileContent);
            }, 0);
        }
        reader.readAsText(constFile.files[0]);
    }
}

function runReadOutFile(sort, reduce) {
    var outFileInput = document.getElementById("phaseOutFile");
    if(outFileInput.files.length == 1) {
        var reader = new FileReader();
        reader.onload = function(data) {
            var outFileContent = data.target.result;
            window.setTimeout(function() {
                runReadConstFile(sort, reduce, outFileContent);
            }, 0);
        }
        reader.readAsText(outFileInput.files[0]);
    } else {
        alert("Missing .out / .out_pairs file");
    }
}

function runJob() {
    var sort = document.getElementById("sortSequences").checked;
    var reduce = document.getElementById("reduceSequences").checked;
    runReadOutFile(sort, reduce);
}
document.getElementById("runJob2Button").onclick = runJob;

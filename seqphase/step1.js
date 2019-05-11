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

function resetForm() {
    document.getElementById("alig1").value = "";
    document.getElementById("alig2").value = "";
    document.getElementById("alig3").value = "";
}
document.getElementById("resetJob1Button").onclick = resetForm;

function copySuggestedCommand() {
    var copyText = document.getElementById('suggestedCommandField');
    copyText.select();
    document.execCommand("copy");
}
document.getElementById("copySuggestedCommand").onclick = copySuggestedCommand;

function resetResultArea() {
    for(var i = 1; i <= 3; i++) {
        document.getElementById("align" + i + "FileErrorsArea").style.display = "none";
        document.getElementById("align" + i + "FileErrorsList").innerHTML = "";
        document.getElementById("align" + i + "FileWarningsArea").style.display = "none";
        document.getElementById("align" + i + "FileWarningsList").innerHTML = "";
    }
    document.getElementById("generalErrorsArea").style.display = "none";
    document.getElementById("generalErrorsList").innerHTML = "";
    document.getElementById("generalWarningsArea").style.display = "none";
    document.getElementById("generalWarningsList").innerHTML = "";
    document.getElementById("notesArea").innerHTML = "";
    document.getElementById("outFileResult").style.display = "none";
    document.getElementById("knownFileResult").style.display = "none";
    document.getElementById("constFileResult").style.display = "none";
    document.getElementById("suggestedCommandArea").style.display = "none";
    document.getElementById("proceedArea").style.display = "none";
}

function handleResults(result) {
    resetResultArea();
    for(var k = 1; k <= 3; k++) {
        if(result["hasAlign" + k + "Errors"]()) {
            document.getElementById("align" + k + "FileErrorsArea").style.display = "block";
            var errors = result["getAlign" + k + "Errors"]();
            for(var i = 0; i < errors.length; i++) {
                var ele = document.createElement("li");
                ele.innerText = errors[i];
                document.getElementById("align" + k + "FileErrorsList").append(ele);
            }
        }
        if(result["hasAlign" + k + "Warn"]()) {
            document.getElementById("align" + k + "FileWarningsArea").style.display = "block";
            var warnings = result["getAlign" + k + "Warn"]();
            for(var i = 0; i < warnings.length; i++) {
                var ele = document.createElement("li");
                ele.innerText = warnings[i];
                document.getElementById("align" + k + "FileWarningsList").append(ele);
            }
        }
    }
    if(result.hasGeneralErrors()) {
        document.getElementById("generalErrorsArea").style.display = "block";
        var errors = result.getGeneralErrors();
        for(var i = 0; i < errors.length; i++) {
            var ele = document.createElement("li");
            ele.innerText = errors[i];
            document.getElementById("generalErrorsList").append(ele);
        }
    }
    if(result.hasGeneralWarn()) {
        document.getElementById("generalWarningsArea").style.display = "block";
        var warnings = result.getGeneralWarn();
        for(var i = 0; i < warnings.length; i++) {
            var ele = document.createElement("li");
            ele.innerText = warnings[i];
            document.getElementById("generalWarningsList").append(ele);
        }
    }
    if(result.hasNotes()) {
        document.getElementById("notesArea").style.display = "block";
        var notes = result.getNotes();
        for(var i = 0; i < notes.length; i++) {
            var ele = document.createElement("br");
            document.getElementById("notesArea").append(ele);
            var ele = document.createElement("span");
            ele.innerText = notes[i];
            document.getElementById("notesArea").append(ele);
        }
    }
    if(result.hasSuggestedCommand()) {
        document.getElementById("suggestedCommandArea").style.display = "block";
        document.getElementById("suggestedCommandField").value = result.getSuggestedPhaseCommand();
    }
    if(result.hasInpFile()) {
        document.getElementById("outFileResult").style.display = "block";
        var link = document.getElementById("downloadInpFileLink");
        var b64 = window.btoa(result.getInpFile());
        link.href = 'data:text/plain;base64,\n'+b64;
    }
    if(result.hasKnownFile()) {
        document.getElementById("knownFileResult").style.display = "block";
        var link = document.getElementById("downloadKnownFileLink");
        var b64 = window.btoa(result.getKnownFile());
        link.href = 'data:text/plain;base64,\n'+b64;
    }
    if(result.hasConstFile()) {
        document.getElementById("constFileResult").style.display = "block";
        var link = document.getElementById("downloadConstFileLink");
        var b64 = window.btoa(result.getConstFile());
        link.href = 'data:text/plain;base64,\n'+b64;
    }
    if(result.hasInpFile()) {
        document.getElementById("proceedArea").style.display = "block";
        if(result.hasConstFile()) {
            document.getElementById("finalLink").href = "step2.html?constFileContent=" + result.getConstFile();
        } else {
            document.getElementById("finalLink").href = "step2.html";
        }
    }
}

function run(align1Content, align2Content, align3Content) {
    var result = SeqPhase1.doIt(align1Content, align2Content, align3Content);
    window.setTimeout(function() {
        handleResults(result)
    }, 0);
}

function runReadAlign3(align1Content, align2Content) {
    var fObj = document.getElementById("alig3");
    if(fObj.files.length == 1) {
        var reader = new FileReader();
        reader.onload = function(data) {
            var fileContent = data.target.result;
            window.setTimeout(function() {
                run(align1Content, align2Content, fileContent);
            }, 0);
        }
        reader.readAsText(fObj.files[0]);
    } else {
        window.setTimeout(function() {
            run(align1Content, align2Content, null);
        }, 0);
    }    
}

function runReadAlign2(align1Content) {
    var fObj = document.getElementById("alig2");
    if(fObj.files.length == 1) {
        var reader = new FileReader();
        reader.onload = function(data) {
            var fileContent = data.target.result;
            window.setTimeout(function() {
                runReadAlign3(align1Content, fileContent);
            }, 0);
        }
        reader.readAsText(fObj.files[0]);
    } else {
        if(align1Content == null) {
            alert("Missing input data! Either an alignment of sequences from homozygous individuals and from heterozygotes to be phased or an alignment of fake haplotype pairs from heterozygotes to be phased has to be provided. You can also provide both files!");
        } else {
            window.setTimeout(function() {
                runReadAlign3(align1Content, null);
            }, 0);
        }      
    }    
}

function runReadAlign1() {
    var fObj = document.getElementById("alig1");
    if(fObj.files.length == 1) {
        var reader = new FileReader();
        reader.onload = function(data) {
            var fileContent = data.target.result;
            window.setTimeout(function() {
                runReadAlign2(fileContent);
            }, 0);
        }
        reader.readAsText(fObj.files[0]);
    } else {
        window.setTimeout(function() {
            runReadAlign2(null);
        }, 0);        
    }    
}
document.getElementById("submitJob1Button").onclick = runReadAlign1;

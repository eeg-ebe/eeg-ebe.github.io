/**
 * Utility functions!
 */

function parseUrl() {
    // get the query string (without the "?")
    var query = location.search.substr(1);
    var result = {};
    query.split("&").forEach(function(part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
    });
    return result;
}

String.prototype.format = function(args) {
    var pattern = /\{\d+\}/g;
    var result = [];
    var p = 0;
    while (match = pattern.exec(this)) {
        // copy before
        result.push(this.substring(p, match.index));
        // add replacement
        result.push(args[parseInt(this.substring(match.index+1, pattern.lastIndex-1))]);
        // set last position
        p = pattern.lastIndex;
    }
    // add rest
    result.push(this.substr(p));
    return result.join("");
}

function loadLanguage(name, uri) {
    $.getJSON("languages/" + uri, function(data) {
        languageDicts[name] = data;
    });
}
function loadLanguages() {
    $.ajaxSetup({
        async: false
    });
    languageDicts = {}; // create the global language dictionary
    $.getJSON("languages/langs.json", function(data) {
        Object.keys(data).forEach(function(key) {
            value = data[key];
            loadLanguage(key, value);
        });
    });
    $.ajaxSetup({
        async: true
    });
}

function setLanguage(lang) {
    // check if this is a supported language
    language = lang; // change the language
    $(".label").each(function(){
        setTxt(this);
    });
}

function setTxt(obj) {
    // set the text of an object
    // the object should be of class "label" and have lid and possible la0,..laN attributes
    var obj = $(obj);
    if(obj.hasClass('label')) {
        // get the lid of the object
        var lid = obj.attr("lid");
        if (typeof lid === typeof undefined || lid === false) {
            console.log("WARNING: obj: " + obj + " is of type label but does not contain an attribute 'lid'!");
        } else {
            // get all la0,...,laN attributes
            var i = 0, args = [];
            while(true) {
                var arg = obj.attr("la" + i);
                if (typeof arg === typeof undefined || arg === false) {
                    break;
                }
                args.push(arg);
            }
            var txt = languageDicts[language]['dict'][lid].format(args);
            obj.text(txt);
        }
    } else {
        console.log("WARNING: obj: " + obj + " does not have class label!");
    }
}

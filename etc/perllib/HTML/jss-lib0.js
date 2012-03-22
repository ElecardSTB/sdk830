// Bootstrap for JavaScript search engine. Loads jss-lib1.js
var jss_index_loaded = 0;
var jss_str;
var jss_result_elem; // Usually a <div> element.
var jss_timer;
// Invoked from a search form.
function jss_search1(str, jss_iframe, result_elem) {
    if (str.search(/\S/) == -1) return;
    if (jss_index_loaded) {
        jss_start_search(str, result_elem);
    } else {
        jss_str = str;
        jss_result_elem = result_elem;
        jss_timer = window.setTimeout("jss_error();", 5000);
        jss_iframe.src = "jss-index.htm";
    }
}

// Invoked by jss-lib1.js, loaded by jss-index.htm
function jss_search2() {
    window.clearTimeout(jss_timer);
    jss_start_search(jss_str, jss_result_elem);
}

function jss_error() {
    alert("Timeout error during loading of file jss-index.htm!");
}

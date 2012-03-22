// JavaScript search engine. Loaded by jss-lib0.js
// Original by Yann LeCun & Florin Nicsa, 2003.
// Modifications by Wouter Batelaan @ NXP.

var jss_all_docs = new Array(doc_url.length);
var jss_help_link = "<a target='_new' href='jss-help.html'>[Help on search]</a>";

function jss_start_search(searchval, result_elem) {

var jss_result_elem;
var op_str="";
var result_stacks = [new Array(), new Array()];
var polisharr;
var is_first=0;
var match_wholewords = 0;
var match_subwords = 1;

// decode a string into a list of document IDs
function jss_strtoids(str) {
    return str.split(",");
}

function jss_replace(S,s_match,s_replace) {
  var s_start=0;
  while((s_start = S.indexOf(s_match,s_start)) > -1) {
    S = S.substr(0,s_start)+s_replace+S.substr(s_start+s_match.length);
    s_start = s_start+s_match;
  }
  return S;
}

function is_stop_word(s) {
    var i;
    for (i = stop_word_list.length - 1; i >= 0; i--) {
        if (stop_word_list[i] == s) return 1;
    }
    return 0;
}

function jss_word_cleanup(s) {
    var a = "";
    if (s.charAt(0)=="-") {
        a="-";
        s=s.substr(1);
    }
    if (s.length <= 2) {
        append_msg("<font color='red'>Cannot search for words 2 characters or less: \"" + s + "\"</font><br>\n");
        return -1;
    }
    s = s.toLowerCase();
    if (s.match(/[^a-z0-9_]/)) {
        append_msg("<font color='red'>Cannot search for word containing non [a-zA-Z0-9_] characters: \"" + s + "\"</font><br>\n");
        return -1;
    }
    if (is_stop_word(s)) {
        append_msg("<font color='red'>Cannot search for word \"" + s + "\" because it was excluded during indexing.</font><br>\n");
        append_msg("The following words were excluded during indexing:<br><ul><li>"
                   + stop_word_list.join("<li>")
                   + "</ul>\n");
        return -1;
    }
    return a + s;
}

function docsids(match_mode, searchval) {
    var result = [];
    var i;
    if (match_mode == match_wholewords) {
        for(i=0; (i < wordlist.length) && (wordlist[i]!=searchval);i++);
        if (i < wordlist.length) {
            result = jss_strtoids(doclist[i]);
        }
        //dbg("docsids('" + searchval + "') => array of " + result.length + " elements: " + result);
    } else {
        // subword matching
        for (i=0; i < wordlist.length; i++) {
            if (wordlist[i] != null && wordlist[i].indexOf(searchval) != -1) {
                result = OR_results(result, jss_strtoids(doclist[i]));
            }
        }
    }
    return result;
}

function clear_results() {
    jss_result_elem.innerHTML = "";
}

function append_msg(str) {
    jss_result_elem.innerHTML = jss_result_elem.innerHTML + str;
}

function dbg(str) {
    append_msg("DBG: " + str + "</br>\n");
}

function write_results_mode(mode, title) {
    var result_stack = result_stacks[mode];
    var doc_string = "<h3>" + title + ": " ;
    var docids = result_stack[0];
    //dbg("write_results: result_stack[mode] = " + docids);
    if (docids.length == 0) {
        doc_string += "NONE</h3>\n";
    } else {
        var urls = new Array(docids.length);
        doc_string += docids.length + "</h3><ul>\n";
        var i;
        for (i=0; i < docids.length; i++) {
            if ((base_url == "") || (base_url == ".")) {
                //dbg("write_results: docids[i] = " + docids[i]);
                urls[i] = result_link(i, doc_url[docids[i]]);
            } else {
                urls[i] = result_link(i, base_url + "/" + doc_url[docids[i]]);
            }
        }
        doc_string += urls.join("\n") + "</ul>\n";
    }
    append_msg(doc_string);
}

function write_results() {
    write_results_mode(match_wholewords, "Whole word matches");
    write_results_mode(match_subwords, "Additional sub-word matches");
}

function result_link(i, s_url) {
    return "<li><a target=\"_parent\" href=\""+s_url+"\">"+s_url+"</a>\n";
}

function pop(a) {
    var b = a[a.length-1];
    a.length--;
    return b;
}

function object_get_sorted_keys(obj) {
    var res = new Array();
    var key;
    for (key in obj) {
        if (obj[key]) {
            res.push(key);
        }
    }
    res.sort();
    return res;
}

function AND_results(a,b) { 
  if (a.length == 0) return [];
  if (b.length == 0) return [];
  var res = new Object();
  var aobj = new Object();
  var i;
  for (i = 0; i < a.length; i++) {
      aobj[a[i]] = 1;
  }
  for (i = 0; i < b.length; i++) {
      if (aobj[b[i]]) {
          res[b[i]] = 1;
      }
  }
  res = object_get_sorted_keys(res);
  //dbg("AND_results: => " + res);
  return res;
}

function OR_results(a,b) {
  if (a.length == 0) return b;
  if (b.length == 0) return a;
  var res = new Object();
  var i;
  for (i = 0; i < a.length; i++) {
      res[a[i]] = 1;
  }
  for (i = 0; i < b.length; i++) {
      res[b[i]] = 1;
  }
  res = object_get_sorted_keys(res);
  //dbg("OR_results: => " + res);
  return res;
}

function NOT_results(a,b) {
  //not b in a, i.e. a - b
  if ((a.length == 0) || (b.length == 0)) return a;
  var res = new Object();
  for (i = 0; i < a.length; i++) {
      res[a[i]] = 1;
  }
  for (i = 0; i < b.length; i++) {
      res[b[i]] = 0;
  }
  res = object_get_sorted_keys(res);
  //dbg("NOT_results: => " + res);
  return res;
}

function evaluate_stack(mode, result_temp) {
    //dbg("evaluate_stack(mode, " + result_temp + ")...");
    //dbg("  result_stacks[mode] = " + result_stacks[mode]);
    if (result_stacks[mode].length > 0) {
        //dbg("  stack is not empty");
        if (op_str.length) {
            op_str=op_str.substr(1);
            //dbg("  op_str is " + op_str + "; doing OR_results...");
            result_temp = OR_results(result_temp,pop(result_stacks[mode]));
        } else {
            //dbg("  op_str is empty" + op_str + "; doing AND_results...");
            result_temp = AND_results(result_temp,pop(result_stacks[mode]));
        }
        result_temp = evaluate_stack(mode, result_temp);
        //dbg("evaluate_stack => result_stacks[mode] is now " + result_stacks[mode]);
    } else {
        //dbg("  result_stacks[mode] is empty");
    }
    //dbg("evaluate_stack => " + result_temp);
    return result_temp;
}

function search_word_using_mode(mode, a, searchval) {
    var result_temp = docsids(mode, searchval);
    if (a=="-") { result_temp = NOT_results(jss_all_docs, result_temp); }
    if (!is_first) {
        //dbg("search_word: !is_first");
        result_temp = evaluate_stack(mode, result_temp);
    }
    result_stacks[mode] = result_stacks[mode].concat([result_temp]);
}

/* Searches for searchval.
   If more values on polisharr recurse via search_top_of_polisharr_item.
   Otherwise call write_results;
 */
function search_word(searchval) {
  //dbg("search_word: " + searchval);
  var a = "";
  if (searchval.charAt(0)=="-") {
    a="-";
    searchval=searchval.substr(1);
  }
  //dbg("search_word: negation=" + a);
  search_word_using_mode(match_wholewords, a, searchval);
  search_word_using_mode(match_subwords, a, searchval);
  result_stacks[match_subwords][0] = NOT_results(result_stacks[match_subwords][0], result_stacks[match_wholewords][0]);
}

function search_top_of_polisharr_item() {
  var searchval = pop(polisharr);
  //dbg("search_top_of_polisharr_item: popped off: " + searchval);
  is_first = 0;
  if (searchval == "+") {
      op_str += "+";
      searchval = pop(polisharr);
      is_first = 1;
  }
  var a = "";
  if (searchval.charAt(0) == "-") {
    a = "-";
    searchval=searchval.substr(1);
  }
  search_word(a + searchval);
  if (polisharr.length != 0) {
      search_top_of_polisharr_item();
  }
}

// Parse search string, creating a polish array.
// Polish array means arguments first, then operator.
// So [a OR b] becomes [a b OR].
// Return -1 if any of the search words is too short or contains illegal characters.
// Return cleaned up search string otherwise.
function setup_polisharr(searchval) {
  searchval = searchval.replace(/\s+$/g,"");
  searchval = searchval.replace(/^\s+/g,"");
  searchval = searchval.replace(/\s+/g," ");
  var searchval1;
  for (;;) {
      searchval1 = searchval.replace(/^OR(\s+|$)/,"");
      if (searchval != searchval1) {
          append_msg("<font color='red'>Removing leading \"OR\"</font><br>\n");
          searchval = searchval1;
      } else break;
  }
  for (;;) {
      searchval1 = searchval.replace(/(^|\s+)OR$/,"");
      if (searchval != searchval1) {
          append_msg("<font color='red'>Removing trailing \"OR\"</font><br>\n");
          searchval = searchval1;
      } else break;
  }

  polisharr = searchval.split(" ");
  var i;
  for(i = 0; i <= polisharr.length-1; i++) {
      var word = polisharr[i];
      if (word == "OR") {
          polisharr[i] = polisharr[i-1];
          polisharr[i-1] = "+";
      } else {
          var word1 = jss_word_cleanup(word);
          if (word1 == -1) {
              return -1;
          }
          polisharr[i] = word1;
      }
  }
  polisharr.reverse();
  //dbg("setup_polisharr: polisharr = " + polisharr);
  return searchval;
}

  // body of: function start_search(searchval, result_elem)
  if (!result_elem) return;
  jss_result_elem = result_elem;
  //alert("jss_result_elem = " + jss_result_elem);
  clear_results();
  append_msg("<small>" + jss_help_link + "</small><br>\n");

  searchval = setup_polisharr(searchval);
  if (searchval == -1) {
    return;
  }
  if (polisharr.length > 0) {
      append_msg("Searching for: <strong>" + searchval + "</strong>\n");
      search_top_of_polisharr_item();
      write_results();
      append_msg("<small>" + jss_help_link + "</small>\n");
  }
}

for(i = 0;i < doc_url.length;i++) jss_all_docs[i]=i;
parent.jss_start_search = jss_start_search;
parent.jss_index_loaded = 1;
parent.jss_search2();

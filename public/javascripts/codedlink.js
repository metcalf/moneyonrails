/**
 * @author anmetcal
 */

var linkhash = "3b19ecd69b492a40e3061f17786b33c28f504239";

function linkprompt(text){
	var code = prompt(text, "");
	if(hex_sha1(code) == linkhash){
		window.location = "http://" + code + ".throughawall.com";
	} else {
		alert("Sorry, '" + code + "' is not the correct code");
	}
}
#!/bin/bash
##
# Script to scan beautified javascript for various sources and sinks,
# functions, and other useful strings. Also searches for a few common
# template engines that can sometimes be discretely hidden.
#
# To use:
#
# In Burp, save output from 'copy all URLS in this host' to urls.txt
# and run this script, which will download all the things, beautify
# and scan for any goodies.
##

export files="urls.txt"
export jsdir="./js"
export jsout="./scan_loose"
export cute=$(which js-beautify 2>/dev/null)

if [ -z urls.txt ] ; then
        echo "Sorry, urls.txt is missing, export it from Burp and rerun."
        exit 1
fi

if [ -z $cute ] ; then
		echo "Sorry, js-beautify is required, install and rerun."
		exit 1;
fi

frameworksearchlist=(
        "Node", "Angular", "React", "jQuery", "Ember"
)

templatesearchlist=(
        "ect", "dust", "dot", "phalcon", "tornado", "ejs", "groovy", "underscore", "template7", "pug",
        "jtemplates", "freemarker", "mako", "moustache", "velocity", "twig", "ember", "blade", "jinja",
        "larvel", "liquid", "smarty", "handlebars", "nunjucks", "volt"
)

jssearchlist=(
        "asp"
        "Access-Control"
        "add"
        "addEventListener"
        "admin"
        "ajax"
        "api"
        "appendChild"
        "apply"
        "async"
        "attachEvent"
        "auth"
        "Authorization"
        "bean"
        "Backbone"
        "backgroundImage"
        "Basic"
        "Bearer"
        "Buffer"
        "call"
        "child_process"
        "class"
        "console"
        "constructor"
        "craft"
        "createClass"
        "createElement"
        "createFactory"
        "createServer"
        "createTextNode"
        "crypt"
        "csrf"
        "dangerouslySetInnerHTML"
        "DataView"
        "debug"
        "decodeURI"
        "decodeURIComponent"
        "delete"
        "DELETE"
        "detachEvent"
        "deserialize"
        "disabled"
        "dispatchEvent"
        "display"
        "document.baseURI"
        "document.cookie"
        "document.documentURI"
        "document.referrer"
        "document.URL"
        "document.URLUnencoded"
        "download"
        "element.inner.html"
        "encodeForHTML"
        "encodeForHTMLAttr"
        "encodeForJS"
        "encodeURI"
        "encodeURIComponent"
        "encrypt"
        "escape"
        "eval"
        "EventTarget"
        "exec"
        "execFile"
        "export"
        "exports"
        "Express"
        "extend"
        "extends"
        "Factory"
        "fireEvent"
        "fs"
        "Function"
        "Generator"
        "GeneratorFunction"
        "GET"
        "getElementById"
        "getPrototypeOf"
        "global"
        "HEAD"
        "hidden"
        "hide"
        "import"
        "include"
        "innerHTML"
        "insertAdjacentHTML"
        "instanceof"
        "jQuery"
        "JSON"
        "jsp"
        "key"
        "localStorage"
        "location.assign"
        "location.hash"
        "location.href"
        "location.pathname"
        "location.replace"
        "location.search"
        "module"
        "new"
        "NTLM"
        "object"
        "open"
        "OPTIONS"
        "outerHTML"
        "password"
        "PATCH"
        "path"
        "php"
        "POST"
        "process"
        "prototype"
        "provider"
        "Proxy"
        "PUT"
        "querySelector"
        "rand"
        "read"
        "Reflect"
        "regex"
        "require"
        "role"
        "roles"
        "root"
        "run"
        "saml"
        "sandbox"
        "secret"
        "secure"
        "service"
        "serialize"
        "setAttribute"
        "setPrototypeOf"
        "setTimeout"
        "spawn"
        "SSO"
        "stats"
        "strict"
        "subprocess"
        "super"
        "symbol"
        "template"
        "token"
        "trigger"
        "typeof"
        "unescape"
        "uneval"
        "upload"
        "url"
        "validate"
        "var"
        "WebAssembly"
        "window.name"
        "write"
        "writeIn"
        "xsl"
        "xml"
        "XMLHttpRequest"
        "xss"
)

allthethings=(
        ${jssearchlist[@]}
        ${frameworksearchlist[@]}
        ${templatesearchlist[@]}
)

mkdir $jsdir $jsout

printf "\nDownloading and havesting, wait."

for i in $(cat $files| grep '\.js' | sed 's/\.js.*/\.js/g' | sort -u)
do
    jsfile=$(echo $i | sed 's/\// /g' | awk '{print $NF}')
    curl -s -o $jsdir/$jsfile $i

    for j in $(ls -a $jsdir/$jsfile)
    do
        $cute -r $j 2>&1 > /dev/null

        for k in "${allthethings[@]}"
        do
            echo -ne "."
            egrep -Hni $k $j >> $jsout/$k.txt
        done
    done
done

printf "\nHarvest finished.\n\n"

# End


var iframes = document.getElementsByTagName('iframe');
for(var i = 0 ; i < iframes.length ; i ++ )
{
    var d = iframes[i];
    d.style.width = "100%";
    d.style.height = "auto";
}

var images = new Array;
var exclude = [
               'https://www.zhihu.com/equation',
               'http://www.zhihu.com/equation'
               ];

function endWith(str,endStr){
    var d=str.length-endStr.length;
    return (d>=0&&str.lastIndexOf(endStr)==d);
}

var links = document.getElementsByTagName('a');
for(var i = 0 ; i < links.length ; i ++ )
{
    var link = links[i];
    var noProxy = link.href.indexOf("file://");
    if(noProxy == 0)
    {
        link.href = "http:" + link.href.toString().substr(7);
    }
    if (link.parentNode.nodeName == "U")
    {
        link.parentNode.classList.add("noUnderLine");
    }
}

var underLines = document.getElementsByTagName('u');
for(var i = 0 ; i < underLines.length ; i ++ )
{
    var under = underLines[i];
    if (under.parentNode.nodeName == "A")
    {
        under.classList.add("noUnderLine");
    }
}


var clickIndex = 0;
var imgs = document.getElementsByTagName('img');
for(var i = 0 ; i < imgs.length ; i ++ )
{
    var img = imgs[i];
    if (img.src.length == 0) {
        if (img.dataset.original.length != 0) {
            img.src = img.dataset.original;
        }
    }
    
    var noHost = img.src.indexOf("file://");
    if(noHost == 0)
    {
        img.src = host + img.src.toString().substr(7);
    }
    
    if (img.parentNode.nodeName == "A")
    {
        img.parentNode.classList.add("aimg");
    }
    
    images.push(img.getAttribute("src"));
    (function (){
         var p = i;
         clickIndex = i;
         if(img.parentNode.nodeName != "A")
         {
             img.onclick = function(){
                 alert("openimage:"+ p);
             };
         }
     })();
    
    var fdStart = img.src.indexOf("http");
    
    if(fdStart == 0) {
        var change = true;
        for(var j in exclude)
        {
            console.log(img.src.indexOf(exclude[j]),img.src);
            change = change && img.src.indexOf(exclude[j]) != 0;
        }
        if(endWith(img.src,"gif"))
        {
            change = false;
        }
        if(change){
            img.src = "inner" + img.src;
        }
    }
    else {
        
    }
}

function removeInlineCss(name)
{
    var spans = document.getElementsByTagName(name);
    for(var i in spans)
    {
        if (typeof spans[i].style != "undefined") {
            spans[i].style.cssText = "";
        }
    }
}
removeInlineCss("span");
removeInlineCss("p");
removeInlineCss("div");
removeInlineCss("a");
removeInlineCss("img");

function setFont(e)
{
    document.getElementsByTagName('body')[0].style.setProperty('font-family',e+',sans-serif','important');
    document.getElementsByTagName('html')[0].style.setProperty('font-family',e+',sans-serif','important');
}

function setFontSize(e)
{
    document.getElementsByTagName('body')[0].style.setProperty('font-size',e+"px","important");
    document.getElementsByTagName('html')[0].style.setProperty('font-size',e+"px","important");
}

function setLineHeight(e)
{
    document.getElementsByTagName('body')[0].style.setProperty('line-height',e+"rem","important");
    document.getElementsByTagName('html')[0].style.setProperty('line-height',e+"rem","important");
}

function setAlign(e)
{
    document.getElementsByTagName('body')[0].style.setProperty('text-align',e,"important");
    document.getElementsByTagName('html')[0].style.setProperty('text-align',e,"important");
}

var fontSize = window.prompt('getFontSize','20');
setFontSize(fontSize);

var lineHeight = window.prompt('getLineHeight','1.6');
setLineHeight(lineHeight);

var align = window.prompt('getAlign','justify');
setAlign(align);

var font = window.prompt('getFont','PingFangSC-Light');
setFont(font);

// <script type="text/javascript" src="https://www.google.com/jsapi"></script>
google.load("feeds", "1");
function pad(n){
  return n < 10 ? '0'+n : n
}  
function newsfeed_initialize() {
  var feed = new google.feeds.Feed("http://masao.jpn.org/d/cat_website.rdf");
  feed.setNumEntries( 6 );
  feed.load(function(result) {
    if (!result.error) {
      var container = document.getElementById("newsfeed");
      var list = document.createElement("dl");
      container.appendChild(list); 
      for (var i = 0; i < result.feed.entries.length; i++) {
        var entry = result.feed.entries[i];
	var date = new Date(entry.publishedDate);
        var dt = document.createElement("dt");
	var date_str = date.getUTCFullYear() + "-" + pad(date.getUTCMonth()+1) + '-' + pad(date.getUTCDate());
        dt.appendChild(document.createTextNode(date_str));
        list.appendChild(dt);

        var dd = document.createElement("dd");
//            dd.appendChild(document.createTextNode(entry.title);
        var content = entry.content;
        content = content.substr( 0, content.indexOf( "。" ) );
        content = content.replace( /<.*?>|[\r\n]+/g, " " ).trim();
        dd.setAttribute( "title", content );

        var link = document.createElement("a");
        link.href = entry.link;
        link.appendChild(document.createTextNode(entry.title));
        dd.appendChild(link);
 
       list.appendChild(dd);
      }
    }
    var div = document.createElement("div");
    div.setAttribute( "style", "text-align:right;font-size:medium;" );
    div.innerHTML = '<a href="http://masao.jpn.org/d/cat_website.html">More...</a>';
    container.appendChild(div);
  });
}
google.setOnLoadCallback(newsfeed_initialize);

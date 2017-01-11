// <script type="text/javascript" src="https://www.google.com/jsapi"></script>
//google.load("feeds", "1");
function pad(n){
  return n < 10 ? '0'+n : n
}  
$().ready(function(){
  $.ajax({
    url: "./d/cat_website.rdf",
    type: "GET",
    success: function(xml, status){
      var container = document.getElementById("newsfeed");
      var list = document.createElement("dl");
      container.appendChild(list); 
      var i = 0;
      $(xml).find("item").each(function(){
        var entry = {};
        $(this).children().each(function(){
          var node_name = $(this)[0].nodeName;
          entry[node_name] = $(this).text();
        });
	var date = new Date(entry["dc:date"]);
        var dt = document.createElement("dt");
	var date_str = date.getUTCFullYear() + "-" + pad(date.getUTCMonth()+1) + '-' + pad(date.getUTCDate());
        dt.appendChild(document.createTextNode(date_str));
        list.appendChild(dt);

        var dd = document.createElement("dd");
        var content = entry["content:encoded"];
        content = content.substr( 0, content.indexOf( "。" ) );
        content = content.replace( /<.*?>|[\r\n]+/g, " " ).trim();
        dd.setAttribute( "title", content );

        var link = document.createElement("a");
        link.href = entry.link;
        $(link).html(entry.title);
        dd.appendChild(link);
        list.appendChild(dd);
        i++;
        if (i > 5) {
          return false;
        }
      });
      var div = document.createElement("div");
      div.setAttribute( "style", "text-align:right;font-size:medium;" );
      div.innerHTML = '<a href="http://masao.jpn.org/d/cat_website.html">More...</a>';
      container.appendChild(div);
    }
  });
});

function delicious_totalposts(data) {
    var urlinfo = data[0];
    if (!urlinfo.total_posts) return;
    document.getElementById(urlinfo.hash +"_totalposts").innerHTML = urlinfo.total_posts + " others";
}

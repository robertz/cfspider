<cfscript>
	javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
	jsoup = javaloader.create('org.jsoup.Jsoup');

	// use the domain if it is passed in
	domain = url.keyExists("domain") ? url.domain : "";
	allLinks = [];

	function getLinks(requiree string page){
		cfhttp(url = page, resolveURL = true, redirect = false);
		jsDoc = jsoup.parse(cfhttp.fileContent);
		els = jsDoc.select("a[href]");
		out = [];
		els.each((item) => {
			if(
				item.attr("href").len() &&
				item.attr("href").findNoCase( 'https://' & domain ) == 1
			){
				out.append(item.attr("href"));
			}
		});
		return out;
	}

	allLinks.append(getLinks(page = "https://" & domain), true);

	writeDump(var = allLinks);
</cfscript>
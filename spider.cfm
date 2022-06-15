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
				item.attr( "abs:href" ).len() &&
				item.attr( "abs:href" ).find( 'https://' & domain ) == 1 &&
				!item.attr ("abs:href" ).contains( "langCode" )
			){
				out.append(item.attr("abs:href"));
			}
		});
		return out;
	}
	allLinks.append(getLinks(page = "https://" & domain), true);
	allLinks.each((lnk) => {
		try{
			queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
				'link': { value: lnk, cfsqltype: "cf_sql_varchar" }
			}, { datasource: "ufapp" });
		}
		catch(any e){} // insert failed (dupe)
	})
</cfscript>
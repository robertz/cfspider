<cfscript>
	// spider.cfm
	javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
	jsoup = javaloader.create('org.jsoup.Jsoup');
	// use the domain if it is passed in
	domain = url.keyExists("domain") ? url.domain : "";
	allLinks = [];
	function getLinks(required string page){
		cfhttp(url = page, resolveURL = true, redirect = false);
		jsDoc = jsoup.parse(cfhttp.fileContent);
		els = jsDoc.select("a[href]");
		out = [];
		els.each((item) => {
			if(
				item.attr( "href" ).len() &&
				item.attr( "href" ).findNoCase( 'https://' & domain ) == 1
			){
				out.append(item.attr("href"));
			}
		});
		return out;
	}
	// https://www.bennadel.com/blog/4285-adding-jreextract-to-pluck-captured-groups-using-regular-expressions-in-coldfusion.htm
	function extractGroups( required string targetText ) {
		var jre = new JRegEx();
		var pattern = "(?x)^
			## Protocol extraction.
			( https?:// | // )?
			## Hostname extraction.
			( [^./][^/\##?]+ )?
			## Pathname extraction (must start with `./` or `/`).
			( \./[^?\##]* | /[^?\##]* )?
			## Query-string extraction (`?` is not captured).
			(?: \? ( [^\##]* ) )?
			## Fragment extraction (`##` is not captured).
			(?: \## ( .* ) )?
		";
		var extraction = jre.jreExtract( targetText, pattern );
		return [
			match: extraction[ 0 ],
			protocol: extraction[ 1 ],
			hostname: extraction[ 2 ],
			pathname: extraction[ 3 ],
			queryString: extraction[ 4 ],
			fragment: extraction[ 5 ]
		]

	}
	allLinks.append(getLinks(page = "https://" & domain), true);
	allLinks.each((lnk) => {
		try{
			var extracted = extractGroups(lnk);
			var cleaned = extracted.protocol & extracted.hostname & extracted.pathname;
			cleaned &= extracted.queryString.len() ? ("?" & cleaned.queryString) : "";
			queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
				'link': { value: cleaned, cfsqltype: "cf_sql_varchar" }
			});
		}
		catch(any e){} // insert failed (dupe)
	})
</cfscript>
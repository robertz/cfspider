<cfscript>
	// task.cfm
	javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
	jsoup = javaloader.create('org.jsoup.Jsoup');

	checklist = queryExecute("
		SELECT  id, url, (SELECT SUBSTRING_INDEX(REPLACE(REPLACE(url, 'http://', ''), 'https://', ''), '/', 1)) AS domain
		FROM sitemap s
		WHERE s.crawled = 0
		ORDER BY s.id
		LIMIT 60
	");

	checklist.each((row) => {
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
		cfhttp(url = row.url, resolveURL = true, redirect = false);
		queryExecute("UPDATE sitemap SET statuscode = :statuscode, crawled = 1 WHERE id = :id", {
			'statuscode': { value: cfhttp.statuscode, cfsqltype: "cf_sql_varchar" },
			'id': { value: row.id, cfsqltype: "cf_sql_numeric" }
		});
		jsDoc = jsoup.parse(cfhttp.fileContent);
		els = jsDoc.select("a[href]");
		out = [];
		els.each((item) => {
			if(
				item.attr( "href" ).len() &&
				item.attr( "href" ).findNoCase( 'https://' & row.domain ) == 1
			){
				out.append( item.attr( "href" ) );
			}
		});
		out.each((o) => {
			try{
				var extracted = extractGroups(o);
				var cleaned = extracted.protocol & extracted.hostname & extracted.pathname;
				cleaned &= extracted.queryString.len() ? ("?" & cleaned.queryString) : "";

				// writeDump(var = cleaned, abort = 1);
				queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
					'link': { value: cleaned, cfsqltype: "cf_sql_varchar" }
				});
			}
			catch(any e){} // insert failed (duplicate)
		});
	});
</cfscript>
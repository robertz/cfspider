<cfscript>
	javaloader = application.javaLoaderFactory.getJavaLoader([expandPath('/lib/jsoup-1.12.1.jar')]);
	jsoup = javaloader.create('org.jsoup.Jsoup');
	checklist = queryExecute("
		SELECT  id, url, (SELECT SUBSTRING_INDEX(REPLACE(REPLACE(url, 'http://', ''), 'https://', ''), '/', 1)) AS domain
		FROM sitemap s
		WHERE s.crawled = 0
		ORDER BY s.id
		LIMIT 25
	", [], { datasource: 'ufapp' });
	checklist.each((row) => {
		cfhttp(url = row.url, resolveURL = true, redirect = false);
		queryExecute("UPDATE sitemap SET statuscode = :statuscode, crawled = 1 WHERE id = :id", {
			'statuscode': { value: cfhttp.statuscode, cfsqltype: "cf_sql_varchar" },
			'id': { value: row.id, cfsqltype: "cf_sql_numeric" }
		}, { datasource: "ufapp" });
		jsDoc = jsoup.parse(cfhttp.fileContent);
		els = jsDoc.select("a[href]");
		out = [];
		els.each((item) => {
			if(
				item.attr( "abs:href" ).len() &&
				item.attr( "abs:href" ).find( 'https://' & row.domain ) == 1 &&
				!item.attr( "abs:href" ).contains( "langCode" )
			){
				out.append( item.attr( "abs:href" ) );
			}
		});
		for(var o in out){
			try{
				queryExecute("INSERT INTO sitemap (url) VALUES (:link)", {
					'link': { value: o, cfsqltype: "cf_sql_varchar" }
				}, { datasource: "ufapp" });
			}
			catch(any e){} // insert failed (duplicate)
		}
	})
</cfscript>
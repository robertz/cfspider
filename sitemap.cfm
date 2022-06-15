<cfsetting enablecfoutputonly="true" />
<cfscript>
	domain = url.keyExists("domain") ? url.domain : "";
	locs = queryExecute("
		SELECT DISTINCT s.url
		FROM sitemap s
		WHERE s.url LIKE :domain AND s.statuscode = '200 OK'
		ORDER by s.url", {
			'domain': { value: "%" & domain & "/%", cfsqltype: "cf_sql_varchar" }
		}, { datasource: "ufapp" });
	lastmod = dateFormat(now(), "yyyy-mm-dd");
	out = '<?xml version="1.0" encoding="UTF-8"?> <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"> ';
savecontent variable = "xmlBody" {
for(u in locs){writeOutput('
<url>
	<loc>#u.url#</loc>
	<lastmod>#lastmod#</lastmod>
</url>');}
};
	out &= xmlBody;
	out &= "</urlset>";
	fileWrite(expandPath(".") & "/sitemap-" & domain.replace(".", "_", "all") & ".xml", out);
</cfscript>
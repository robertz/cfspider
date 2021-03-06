### Notes

Getting it running:
* `box server start`
* Add ufapp datasource to CF administrator
* Create the table using the table DDL
* Call `spider.cfm?domain=kisdigital.com` to start the spider process.
* Add scheduled task to call task.cfm every 60 seconds (or whatever interval you prefer). This will grab the next chunk of URLs to be crawled.

### DDL
``` sql
-- ufapp.sitemap definition

CREATE TABLE `sitemap` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `url` varchar(1000) NOT NULL UNIQUE,
  `crawled` bit(1) NOT NULL DEFAULT b'0',
  `statuscode` varchar(100) NOT NULL DEFAULT '200',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
```

Example query to pull data by domain
``` sql
SELECT  id, url, verified, (SELECT SUBSTRING_INDEX(REPLACE(REPLACE(url, "http://", ""), "https://", ""), '/', 1)) AS domain
FROM sitemap s 
WHERE url LIKE '%kisdigital.com/%'
ORDER BY s.id
```
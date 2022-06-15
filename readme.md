### Notes

Getting it running:
* `box server start`
* Add ufapp datasource to CF administrator
* Create the table using the table DDL
* Call `prime.cfm?domain=www.motivescosmetics.com` to start the spider process.
* Add scheduled task to call task.cfm every 60 seconds (or whatever interval you prefer). This will grab the next 25 URLs to be spidered.

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
WHERE url LIKE '%www.tlsslim.com/%'
ORDER BY s.id
```
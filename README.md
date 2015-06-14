borderbot-core
===

[@mlborder](https://twitter.com/mlborder)'s main batch source.

![borderbot-core](https://cloud.githubusercontent.com/assets/1079365/8148607/067d0c46-12e0-11e5-8263-4ce24760e4df.png)

## Overview

The _borderbot-core_ includes...

- Crawler **(closed source)**
  - Crawl latest border info and write into intermediate file.
- Parser & Datastore
  - Parse from intermediate file to ruby friendly hash.
  - Event rank border series datastore(powered by [influxdb](http://influxdb.com/))
- Twitter client
  - Wrapper of twitter client.

You can use these classes for each scripts to get information you want(hourly report, velocity, and so on).

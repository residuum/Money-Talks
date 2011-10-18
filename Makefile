COUCHDB_HOST = http://localhost:5984
DATABASE = indices

import:
	./importcsv.py csv/dax.csv $(COUCHDB_HOST) $(DATABASE)
	./importcsv.py csv/dowjones.csv $(COUCHDB_HOST) $(DATABASE)
	./importcsv.py csv/eurostoxx.csv $(COUCHDB_HOST) $(DATABASE)
	./importcsv.py csv/nikkei.csv $(COUCHDB_HOST) $(DATABASE)
	./importcsv.py csv/shanghai-comp.csv $(COUCHDB_HOST) $(DATABASE)

download:
	curl -o csv/dax.csv http://ichart.finance.yahoo.com/table.csv?s=%5EGDAXI&a=00&b=01&c=1900&d=08&e=21&f=9999&g=d&ignore=.csv 
	curl -o csv/dowjones.csv http://ichart.finance.yahoo.com/table.csv?s=%5EDJI&d=8&e=21&f=9999&g=d&a=9&b=1&c=1928&ignore=.csv 
	curl -o csv/eurostoxx.csv http://ichart.finance.yahoo.com/table.csv?s=%5ESTOXX50E&d=8&e=21&f=9999&g=d&a=5&b=6&c=2002&ignore=.csv 
	curl -o csv/nikkei.csv http://ichart.finance.yahoo.com/table.csv?s=%5EN225&d=8&e=21&f=9999&g=d&a=0&b=4&c=1984&ignore=.csv 
	curl -o csv/shanghai-comp.csv http://ichart.finance.yahoo.com/table.csv?s=000001.SS&d=8&e=21&f=9999&g=d&a=0&b=4&c=2000&ignore=.csv 

init:
	curl -X DELETE $(COUCHDB_HOST)/$(DATABASE)
	curl -X PUT $(COUCHDB_HOST)/$(DATABASE)
	curl -X PUT -d {\"_id\":\"_design/sorted\",\"language\":\"javascript\",\"views\":{\"bydate\":{\"map\":\"\(function\(doc\)\ {\\n\\tif\ \(doc.Year\ \&\&\ doc.DayOfYear\ \&\&\ doc.index\)\ {\\n\\t\\temit\([doc.index,\ doc.Year,\ doc.DayOfYear],\ doc\)\\n\\t}\\n}\)\"},\"minmax\":{\"map\":\"\(function\(doc\)\ {\\n\\tif\ \(doc.index\ \&\&\ doc.Close\)\ {\\n\\t\\temit\ \(doc.index,\ doc.Close\)\;\\n\\t}\\n}\)\",\"reduce\":\"\(function\(keys,\ values,\ rereduce\)\ {\\n\\tvar\ min\ =\ Number.MAX_VALUE,\\n\\t\ \ \ \ max\ =\ Number.MIN_VALUE,\\n\\t\ \ \ \ i\;\\n\\n\\tif\ \(\!rereduce\)\ {\\n\\t\\tfor\ \(i\ in\ values\)\ {\\n\\t\\t\\tmin\ =\ Math.min\(values[i],\ min\)\;\\n\\t\\t\\tmax\ =\ Math.max\(values[i],\ max\)\;\\n\\t\\t}\\n\\t}\ else\ {\\t\\t\\n\\t\\tmin\ =\ values[0].min\;\\n\\t\\tmax\ =\ values[0].max\;\\n\\t\\tfor\(i\ in\ values\)\ {\\n\\t\\t\\tmin\ =\ Math.min\(values[i].min,\ min\)\;\\n\\t\\t\\tmax\ =\ Math.max\(values[i].max,\ max\)\;\\n\\t\\t}\\n\\t}\\n\\n\\treturn\ {\'min\':\ min,\ \'max\':\ max}\;\\n}\)\"}}} $(COUCHDB_HOST)/$(DATABASE)/_design/sorted


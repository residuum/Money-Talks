#!/usr/bin/env python

from couchdbkit import Server, Database
from couchdbkit.loaders import FileSystemDocsLoader
from csv import DictReader
import sys, subprocess, math, os

def parseDoc(doc):
    for k,v in doc.items():
        if k=='Date':
            splitDate=v.split('-')
            doc['year'] = splitDate[0];
            doc['month'] = splitDate[1];
            doc['day'] = splitDate[2];
        if (isinstance(v,str)):
            #print k, v, v.isdigit()
            # #see if this string is really an int or a float
            if v.isdigit()==True: #int
                doc[k] = int(v)
            else: #try a float
                try:
                    if math.isnan(float(v))==False:
                        doc[k] = float(v) 
                except:
                    pass            
    return doc


def upload(db, docs):
    db.bulk_save(docs)
    del docs
    return list()


def uploadFile(fname, uri, dbname):
  print 'Upload contents of %s to %s/%s' % (fname, uri, dbname)
  # #connect to the db
  theServer = Server(uri)
  db = theServer.get_or_create_db(dbname)
  #loop on file for upload
  reader = DictReader(open(fname, 'rU'), dialect = 'excel')  #see the python csv module 
         #for other options, such as using the tab delimeter. The first line in your csv 
         #file should contain all of the "key" and all subsequent lines hold the values 
         #for those keys.

  indexName = fname.split('/')[1].split('.')[0]
  #used for bulk uploading
  docs = list()
  checkpoint = 100

  for doc in reader:
    newdoc = parseDoc(doc) #this just converts strings that are really numbers into ints and floats
    newdoc['index'] = indexName

    docs.append(newdoc)

    if len(docs)%checkpoint==0:
      docs = upload(db,docs)

  #don't forget the last batch        
  docs = upload(db,docs)



if __name__=='__main__':
  filename = sys.argv[1]
  uri = sys.argv[2]
  dbname = sys.argv[3]

  uploadFile(filename, uri, dbname)

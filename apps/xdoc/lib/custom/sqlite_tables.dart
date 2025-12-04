// lib/database/create_tables.dart
const String tblchannels = '''
  CREATE TABLE IF NOT EXISTS tblchannels(
    channelid INT PRIMARY KEY,
    channelname VARCHAR(63) NOT NULL,
    channeldescription VARCHAR(63) NOT NULL,
    entityroles VARCHAR(63) NOT NULL DEFAULT 'all',
    actorsequence BIGINT NOT NULL,
    initialactorid BIGINT, 
    otheractorid BIGINT,
    contexttemplate TEXT,
    istagrequired BOOLEAN NOT NULL DEFAULT FALSE
  );
''';
const String tblchanneltags = '''
  CREATE TABLE IF NOT EXISTS tblchanneltags(
    channeltagid BIGSERIAL PRIMARY KEY,
    channelid BIGINT NOT NULL REFERENCES tblchannels(channelid),
    tag VARCHAR(63) NOT NULL,
    tagdescription VARCHAR(255),
    expireat TIMESTAMP NULL, 
    UNIQUE(channelid, tag)
  );
''';

const String tblxdocactors = '''
   CREATE TABLE IF NOT EXISTS tblxdocactors(
    xdocactorid BIGSERIAL PRIMARY KEY,
    xdocid BIGINT NOT NULL,
    actorid BIGINT NOT NULL,
    channelid BIGINT NOT NULL REFERENCES tblchannels(channelid),
    encryptedsymmetrickey BLOB  NULL, -- Encrypted symmetric key for the document
    interconnectid BIGINT,
    docname VARCHAR(63) NOT NULL,
    contextdata JSONB NOT NULL,
    starttime TIMESTAMP NOT NULL,
    completiontime TIMESTAMP,
    UNIQUE(xdocid, actorid)
  );
''';

const String tblxdocevents = '''
  CREATE TABLE IF NOT EXISTS tblxdocevents(
    xdoc_eventid BIGSERIAL PRIMARY KEY,
    xdoc_actorid BIGINT NOT NULL REFERENCES tblxdocactors(xdoc_actorid),
    xdocid BIGINT REFERENCES tblxdocs(xdocid), -- Denormalized
    actorid BIGINT, -- Denormalized
    eventpayload TEXT NOT NULL,
    contextdata TEXT NOT NULL DEFAULT '{}', -- Context data for the event
    entityroles VARCHAR(63) NOT NULL
  );
''';
const String tblxdocstatetransitions = '''
  CREATE TABLE IF NOT EXISTS tblxdocstatetransitions(
    xdoc_statetransitionid BIGSERIAL PRIMARY KEY,
    channelstatename VARCHAR(63) NOT NULL,
    xdoc_actorid BIGINT NOT NULL REFERENCES tblxdocactors(xdoc_actorid),
    channelstateid BIGINT REFERENCES tblchannelstates(channelstateid),
    entrytime TIMESTAMP NOT NULL,
    exittime TIMESTAMP
  );
''';
const String tblxdocs = '''
  CREATE TABLE IF NOT EXISTS tblxdocs(
    xdocid INTEGER PRIMARY KEY,
    interconnectid INTEGER,
    docname VARCHAR(63),
    contextdata TEXT,
    starttime TEXT,
    completiontime TEXT,
    inserttime INTEGER,
    deletedtime INTEGER,
    isnotdeleted INTEGER DEFAULT 1
  );
''';
// Optionally: List of all table creations
const List<String> createTableQueries = [
  tblchannels,
  tblchanneltags,
  tblxdocactors,
  tblxdocevents,
  tblxdocstatetransitions,
  tblxdocs,
];

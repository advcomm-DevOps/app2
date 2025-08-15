// lib/database/create_tables.dart
const String tblchannels = '''
  CREATE TABLE IF NOT EXISTS tblchannels(
    ChannelID INT PRIMARY KEY,
    ChannelName VARCHAR(63) NOT NULL,
    ChannelDescription VARCHAR(63) NOT NULL,
    EntityRoles VARCHAR(63) NOT NULL DEFAULT 'all',
    ActorSequence BIGINT NOT NULL,
    InitialActorID BIGINT,
    OtherActorID BIGINT,
    ContextTemplate TEXT,
    IsTagRequired BOOLEAN NOT NULL DEFAULT FALSE
);
''';
const String tblchanneltags = '''
  CREATE TABLE IF NOT EXISTS tblchanneltags(
    ChannelTagID BIGSERIAL PRIMARY KEY,
    ChannelID BIGINT NOT NULL REFERENCES tblchannels(ChannelID),
    Tag VARCHAR(63) NOT NULL,
    TagDescription VARCHAR(255),
    ExpireAt TIMESTAMP NULL,
    UNIQUE(ChannelID, Tag)
);
''';
const String tblchanneltagMapping = '''
  CREATE TABLE IF NOT EXISTS tblchanneltagMapping(
    MappingID INTEGER PRIMARY KEY,
    TagId INTEGER,
    OldChannelEntityId VARCHAR(63),
    OldChannelName VARCHAR(63),
    NewChannelName VARCHAR(63)
);
''';
const String tblxdocs = '''
  CREATE TABLE IF NOT EXISTS tblxdocs(
    XDocID BIGSERIAL PRIMARY KEY,
    InterconnectID BIGINT,
    DocName VARCHAR(63) NOT NULL,
    ContextData JSONB NOT NULL,
    StartTime TIMESTAMP NOT NULL DEFAULT (now()),
    CompletionTime TIMESTAMP
);
''';
const String tblxdocactors = '''
  CREATE TABLE IF NOT EXISTS tblxdocactors(
    XDocActorID BIGSERIAL PRIMARY KEY,
    ActorID BIGINT NOT NULL,
    ChannelID BIGINT NOT NULL REFERENCES tblchannels(ChannelID),
    EncryptedSymmetricKey BLOB  NULL, -- Encrypted symmetric key for the document
    XDocID BIGSERIAL PRIMARY KEY,
    InterconnectID BIGINT,
    DocName VARCHAR(63) NOT NULL,
    ContextData JSONB NOT NULL,
    StartTime TIMESTAMP NOT NULL DEFAULT (now()),
    CompletionTime TIMESTAMP
);
 
''';
const String tblxdocevents = '''
  CREATE TABLE IF NOT EXISTS tblxdocevents(
    XDocEventID BIGSERIAL PRIMARY KEY,
    XDocActorID BIGINT NOT NULL REFERENCES tblxdocactors(XDocActorID),
    XDocID BIGINT REFERENCES tblxdocs(XDocID), -- Denormalized
    ActorID BIGINT, -- Denormalized
    EventPayload TEXT NOT NULL,
    ContextData TEXT NOT NULL DEFAULT '{}' -- Context data for the event
);
''';
// Optionally: List of all table creations
const List<String> createTableQueries = [
  tblchannels,
  tblchanneltags,
  tblchanneltagMapping,
  tblxdocs,
  tblxdocactors,
  tblxdocevents
];

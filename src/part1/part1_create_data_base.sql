create table Peers (
    Nickname varchar UNIQUE primary key,
    Birthday date not null,
    UNIQUE(Nickname)
);

create table Tasks (
    Title varchar primary key UNIQUE DEFAULT NULL,
    ParentTask varchar DEFAULT NULL, foreign key (ParentTask) references Tasks(Title),
    MaxXP integer not null CHECK (MaxXP > 0)
);

CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

create table Checks (
    ID serial primary key,
    Peer varchar, foreign key (Peer) references Peers(Nickname),
    Task varchar, foreign key (Task) references Tasks(Title),
    "Date" date
);

create table P2P (
    ID serial primary key,
    "Check" bigint, foreign key ("Check") references Checks(ID),
    CheckingPeer varchar, foreign key (CheckingPeer) references Peers(Nickname),
    State check_status,
    "Time" TIME without time zone
);

create table Verter (
    ID serial primary key,
    "Check" bigint, foreign key ("Check") references Checks(ID),
    State check_status,
    "Time" TIME without time zone
);

create table TransferredPoints (
    ID serial primary key,
    CheckingPeer varchar, foreign key (CheckingPeer) references Peers(Nickname),
    CheckedPeer varchar CHECK ( CheckedPeer != CheckingPeer ), foreign key (CheckedPeer) references Peers(Nickname),
    PointsAmount integer,
    CHECK (PointsAmount = 1)
);

create table Friends (
    ID serial primary key,
    Peer1 varchar not null, foreign key (Peer1) references Peers(Nickname),
    Peer2 varchar not null, foreign key (Peer2) references Peers(Nickname)
);

create table Recommendations (
    ID serial primary key,
    Peer varchar, foreign key (Peer) references Peers(Nickname),
    RecommendedPeer varchar, foreign key (RecommendedPeer) references Peers(Nickname)
);

create table XP (
    ID serial primary key,
    "Check" bigint, foreign key ("Check") references Checks(ID),
    XPAmount integer,
    CHECK  (XPAmount > 0)
);

CREATE TYPE time_status AS ENUM ('1', '2');

create table TimeTracking (
    ID serial primary key,
    Peer varchar, foreign key (Peer) references Peers(Nickname),
    "Date" date,
    "Time" TIME without time zone,
    State int check (State in (1,2))
);

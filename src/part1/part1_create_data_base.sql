create table Peers (
    Nickname varchar UNIQUE primary key,
    Birthday date not null
);

create table Tasks (
    Title varchar primary key UNIQUE DEFAULT NULL,
    ParentTask varchar DEFAULT NULL, constraint fk_Tasks_Checks foreign key (ParentTask) references Tasks(Title),
    MaxXP integer not null
);

CREATE TYPE check_status AS ENUM ('Start', 'Success', 'Failure');

create table Checks (
    ID serial primary key,
    Peer varchar, constraint fk_Checks_PeersNickname foreign key (Peer) references Peers(Nickname),
    Task varchar, constraint fk_Checks_Peer_title foreign key (Task) references Tasks(Title),
    "Date" date
);

create table P2P (
    ID serial primary key,
    "Check" bigint, constraint fk_P2P_Сheck foreign key ("Check") references Checks(ID),
    CheckingPeer varchar, constraint fk_P2P_checkingPeer foreign key (CheckingPeer) references Peers(Nickname),
    State check_status,
    "Time" TIME without time zone
);

create table Verter (
    ID serial primary key,
    "Check" bigint, constraint fk_Verter_check foreign key ("Check") references Checks(ID),
    State check_status,
    "Time" TIME without time zone
);

create table TransferredPoints (
    ID serial primary key,
    CheckingPeer varchar, constraint fk_TransferredPoints_checkingPeer foreign key (CheckingPeer) references Peers(Nickname),
    CheckedPeer varchar, constraint fk_TransferredPoints_checkedPeer foreign key (CheckedPeer) references Peers(Nickname),
    PointsAmount integer
);

create table Friends (
    ID serial primary key,
    Peer1 varchar not null, constraint fk_Friends_Peer1 foreign key (Peer1) references Peers(Nickname),
    Peer2 varchar not null, constraint fk_Friends_Peer2 foreign key (Peer2) references Peers(Nickname)
);

create table Recommendations (
    ID serial primary key,
    Peer varchar, constraint fk_Recommendations_Peer foreign key (Peer) references Peers(Nickname),
    RecommendedPeer varchar, constraint fk_Recommendations_RecommendedPeer foreign key (RecommendedPeer) references Peers(Nickname)
);

create table XP (
    ID serial primary key,
    "Check" bigint, constraint fk_XP_check foreign key ("Check") references Checks(ID),
    XPAmount integer
);

CREATE TYPE time_status AS ENUM ('1', '2');

create table TimeTracking (
    ID serial primary key,
    Peer varchar, constraint fk_TimeTracking_Peer foreign key (Peer) references Peers(Nickname),
    "Date" date,
    "Time" TIME without time zone,
    State int check (State in (1,2))
);

INSERT INTO Peers (Nickname, Birthday)
VALUES ('Diluc', '1986-04-30'),
       ('Bennett', '2000-02-29'),
       ('Dori', '1999-12-21'),
       ('Keqing', '1995-10-20'),
       ('Zhongli', '1940-12-31'),
       ('Qiqi', '1996-03-03'),
       ('Raiden', '1960-06-26'),
       ('Klee', '2015-07-27');


INSERT INTO Tasks (Title, ParentTask, MaxXP)
VALUES ('C2_SimpleBashUtils', NULL, 250),
       ('C3_s21_string+', 'C2_SimpleBashUtils', 500),
       ('C5_s21_decimal', 'C3_s21_string+', 350),
       ('C6_s21_matrix', 'C5_s21_decimal', 200),
       ('C7_SmartCalc_v1.0', 'C6_s21_matrix', 500),
       ('C8_3DViewer_v1.0', 'C7_SmartCalc_v1.0', 750),
       ('CPP1_s21_matrix+', 'C8_3DViewer_v1.0', 300),
       ('CPP2_s21_containers', 'CPP1_s21_matrix+', 350),
       ('D01_Linux', 'C2_SimpleBashUtils', 300),
       ('DO2_Linux_Network', 'D01_Linux', 250),
       ('DO3_Linux_Monitoring', 'DO2_Linux_Network', 350),
       ('DO5_SimpleDocker', 'DO3_Linux_Monitoring', 300),
       ('DO6_CI/CD', 'DO5_SimpleDocker', 300);



INSERT INTO Checks (ID, Peer, Task, "Date")
VALUES (0, 'Diluc', 'C2_SimpleBashUtils', '2022-08-30'),
       (1, 'Bennett', 'C2_SimpleBashUtils', '2022-09-01'),
       (2, 'Dori', 'C2_SimpleBashUtils', '2022-9-03'),
       (3, 'Keqing', 'C2_SimpleBashUtils', '2022-09-04'),
       (4, 'Zhongli', 'C2_SimpleBashUtils', '2022-09-05'),
       (5, 'Diluc', 'C3_s21_string+', '2022-09-15'),
       (6, 'Bennett', 'C3_s21_string+', '2022-09-15'),
       (7, 'Klee', 'C2_SimpleBashUtils', '2022-09-15'),
       (8, 'Diluc', 'C5_s21_decimal', '2022-09-25'),
       (9, 'Diluc', 'C6_s21_matrix', '2022-09-26'),
       (10, 'Diluc', 'C7_SmartCalc_v1.0', '2022-10-01'),
       (11, 'Diluc', 'C8_3DViewer_v1.0', '2022-10-10'),
       (12, 'Keqing', 'C2_SimpleBashUtils', '2022-10-20');



INSERT INTO P2P ("Check", CheckingPeer, State, "Time")
VALUES (0, 'Bennett', 'Start', '13:00'),
       (0, 'Bennett', 'Success', '13:30'),
       (1, 'Dori', 'Start', '15:00'),
       (1, 'Dori', 'Success', '15:30'),
       (2, 'Keqing', 'Start', '19:00'),
       (2, 'Keqing', 'Success', '19:30'),
       (3, 'Diluc', 'Start', '11:00'),
       (3, 'Diluc', 'Failure', '11:30'),
       (4, 'Klee', 'Start', '10:00'),
       (4, 'Klee', 'Success', '11:00'),
       (5, 'Raiden', 'Start', '20:25'),
       (5, 'Raiden', 'Success', '21:00'),
       (6, 'Diluc', 'Start', '10:10'),
       (6, 'Diluc', 'Success', '10:40'),
       (7, 'Zhongli', 'Start', '12:15'),
       (7, 'Zhongli', 'Success', '12:30'),
       (8, 'Raiden', 'Start', '2:00'),
       (8, 'Raiden', 'Success', '2:30'),
       (9, 'Bennett', 'Start', '15:00'),
       (9, 'Bennett', 'Success', '15:30'),
       (10, 'Keqing', 'Start', '16:00'),
       (10, 'Keqing', 'Success', '16:50'),
       (11, 'Klee', 'Start', '10:00'),
       (11, 'Klee', 'Success', '11:00'),
       (12, 'Raiden', 'Start', '14:00'),
       (12, 'Raiden', 'Success', '14:30');


INSERT INTO Verter ("Check", State, "Time")
VALUES (0, 'Start', '12:31'),
       (0, 'Success', '12:35'),

       (1, 'Start', '15:31'),
       (1, 'Success', '15:35'),

       (2, 'Start', '19:31'),
       (2, 'Failure', '19:33'),

       (4, 'Start', '11:32'),
       (4, 'Success', '11:40'),

       (5, 'Start', '21:02'),
       (5, 'Success', '21:10'),

       (6, 'Start', '10:41'),
       (6, 'Success', '10:45'),

       (7, 'Start', '12:31'),
       (7, 'Success', '12:33'),

       (8, 'Start', '18:31'),
       (8, 'Success', '18:33'),

       (9, 'Start', '15:31'),
       (9, 'Success', '15:33'),

       (12, 'Start', '14:30'),
       (12, 'Failure', '14:33');


INSERT INTO TransferredPoints (CheckingPeer, CheckedPeer, PointsAmount)
VALUES ('Bennett', 'Diluc', 1),
       ('Diluc', 'Bennett', 1),
       ('Dori', 'Bennett', 1),
       ('Keqing', 'Dori', 1),
       ('Diluc', 'Keqing', 1),
       ('Klee', 'Zhongli', 1),
       ('Raiden', 'Diluc', 1),
       ('Diluc', 'Klee', 1),
       ('Klee', 'Diluc', 1),
       ('Zhongli', 'Klee', 1),
       ('Bennett', 'Dori', 1),
       ('Dori', 'Keqing', 1),
       ('Diluc', 'Raiden', 1),
       ('Keqing', 'Raiden', 1);


INSERT INTO Friends (Peer1, Peer2)
VALUES ('Diluc', 'Bennett'),
       ('Diluc', 'Zhongli'),
       ('Raiden', 'Zhongli'),
       ('Qiqi', 'Bennett'),
       ('Klee', 'Qiqi');

INSERT INTO Recommendations (Peer, RecommendedPeer)
VALUES ('Diluc', 'Bennett'),
       ('Bennett', 'Diluc'),
       ('Bennett', 'Dori'),
       ('Dori', 'Keqing'),
       ('Keqing', 'Diluc'),
       ('Zhongli', 'Klee'),
       ('Diluc', 'Raiden'),
       ('Klee', 'Diluc'),
       ('Diluc', 'Klee'),
       ('Klee', 'Zhongli'),
       ('Dori', 'Bennett'),
       ('Keqing', 'Dori'),
       ('Raiden', 'Diluc');

INSERT INTO XP ("Check", XPAmount)
VALUES (0, 250),
       (1, 250),
       (4, 250),
       (5, 500),
       (6, 500),
       (7, 250),
       (8, 350),
       (9, 200),
       (10, 500),
       (11, 750);



INSERT INTO TimeTracking (Peer, "Date", "Time", State)
VALUES ('Dori', '2022-10-09', '18:32', 1),
       ('Dori', '2022-10-09', '19:32', 2),
       ('Dori', '2022-10-09', '20:32', 1),
       ('Dori', '2022-10-09', '22:32', 2),
       ('Keqing', '2022-10-09', '10:32', 1),
       ('Keqing', '2022-10-09', '12:32', 2),
       ('Keqing', '2022-10-09', '13:02', 1),
       ('Keqing', '2022-10-09', '21:32', 2),
       ('Zhongli', '2022-05-09', '10:32', 1),
       ('Zhongli', '2022-05-09', '12:32', 2),
       ('Qiqi', '2022-06-09', '11:02', 1),
       ('Qiqi', '2022-06-09', '21:32', 2),
       ('Diluc', '2022-09-21', '15:00', 1),
       ('Diluc', '2022-09-21', '22:00', 2),
       ('Bennett', '2022-09-21', '08:00', 1),
       ('Bennett', '2022-09-21', '20:00', 2),
       ('Keqing', '2022-09-21', '12:00', 1),
       ('Keqing', '2022-09-21', '19:00', 2);

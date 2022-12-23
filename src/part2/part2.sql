--Написать процедуру добавления P2P проверки
-- Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время.
-- Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю).
-- Добавить запись в таблицу P2P.
-- Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать проверку с незавершенным P2P этапом.

TRUNCATE TABLE p2p CASCADE;
TRUNCATE TABLE checks CASCADE;
TRUNCATE TABLE transferredpoints CASCADE;
TRUNCATE TABLE verter CASCADE;


CREATE or replace PROCEDURE P2P_check (checked varchar,
checking varchar,
taskName varchar,
state check_status,
P2Ptime time)
LANGUAGE plpgsql AS $$
    DECLARE
        id_check integer;
    BEGIN
        IF state = 'Start'
            THEN
                id_check = (SELECT max(id) from checks) + 1;
            INSERT INTO checks (id, peer, task, "Date")
            VALUES (id_check, checked, taskName,(SELECT CURRENT_DATE));
            ELSE
                id_check = (SELECT Checks.id
                            FROM p2p
                                INNER JOIN checks
                                    ON checks.id = p2p."Check"
                            WHERE checkingpeer = checking
                              AND peer = checked
                              AND task = taskName);
    END IF;

    INSERT INTO p2p ("Check", checkingpeer, state, "Time" )
    VALUES (id_check, checking, state, P2Ptime);
    END;
    $$;

-- Tests starts.
CALL P2P_check (
    'Diluc',
    'Bennett',
    'C5_s21_decimal',
    'Start',
    '09:00:00'
);

CALL P2P_check (
    'Diluc',
    'Bennett',
    'C5_s21_decimal',
    'Success',
    '09:20:00'
);
-- Tests end.
-- Для удобства
-- TRUNCATE TABLE p2p CASCADE;
-- TRUNCATE TABLE checks CASCADE;
-- TRUNCATE TABLE transferredpoints CASCADE;
-- TRUNCATE TABLE verter CASCADE;


-- 1)Написать процедуру добавления P2P проверки
-- Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время.
-- Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю).
-- Добавить запись в таблицу P2P.
-- Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать проверку с незавершенным P2P этапом.


CREATE or replace PROCEDURE pr_p2p_check (checked varchar,
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
CALL pr_p2p_check (
    'Diluc',
    'Bennett',
    'C5_s21_decimal',
    'Start',
    '09:00:00'
);

CALL pr_p2p_check (
    'Diluc',
    'Bennett',
    'C5_s21_decimal',
    'Success',
    '09:20:00'
);
-- Tests end.


-- 2) Написать процедуру добавления проверки Verter'ом
-- Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время.
-- Добавить запись в таблицу Verter (в качестве проверки указать проверку соответствующего задания с самым поздним (по времени) успешным P2P этапом)

CREATE or replace PROCEDURE pr_verter_check(nickname varchar,
taskName varchar,
verterState check_status,
checkTime time)
LANGUAGE plpgsql AS $$
    DECLARE
        id_check integer;
BEGIN
        id_check = (SELECT checks.id
        FROM p2p
        INNER JOIN checks
            ON checks.id = p2p."Check" AND p2p.state = 'Success'
        AND checks.task = taskName
        AND checks.peer = nickname
        ORDER BY p2p."Time"
        LIMIT 1);

        INSERT INTO verter ("Check", state, "Time")
        VALUES (id_check, verterState,checkTime);
    END
$$;

-- Tests start.
CALL pr_verter_check (
    'Diluc',
    'C5_s21_decimal',
    'Start',
    '09:21:00'
);

CALL pr_verter_check (
    'Diluc',
    'C5_s21_decimal',
    'Success',
    '09:22:00'
);
-- Tests end.
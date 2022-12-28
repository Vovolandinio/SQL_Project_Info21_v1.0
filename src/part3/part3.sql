-- 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
-- Ник пира 1, ник пира 2, количество переданных пир поинтов.
-- Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.

-- Удаление функции.
DROP FUNCTION IF EXISTS fnc_transferred_points();
-- Создание функции.
CREATE OR REPLACE FUNCTION fnc_transferred_points()
RETURNS TABLE ("Peer1" varchar, "Peer2" varchar, "PointsAmount" integer) AS $$
    WITH tmp AS (
        SELECT
            tp.checkingPeer,
            tp.checkedPeer,
            tp.pointsamount
        FROM
            TransferredPoints tp
        INNER JOIN TransferredPoints t2 ON t2.checkingPeer = tp.checkedPeer
        AND t2.checkedPeer = tp.checkingPeer AND tp.id < t2.id)
    (SELECT checkingPeer,
            checkedPeer,
            sum(result.pointsamount) FROM
    (SELECT tp.checkingPeer, tp.checkedPeer, tp.pointsamount FROM TransferredPoints tp
                                                          UNION
                                                          SELECT t.checkedPeer, t.checkingPeer, -t.pointsamount FROM tmp t
    ) AS result
    GROUP BY 1, 2)
    EXCEPT
    SELECT
        tmp.checkingPeer,
        tmp.checkedPeer,
        tmp.pointsamount
    FROM tmp;
$$ LANGUAGE sql;

-- Тестовый запрос.
SELECT * FROM fnc_transferred_points();

-- 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного задания, кол-во полученного XP
-- В таблицу включать только задания, успешно прошедшие проверку (определять по таблице Checks).
-- Одна задача может быть успешно выполнена несколько раз. В таком случае в таблицу включать все успешные проверки.

------------------------------------------------------------------------------------------------------------

-- 3) Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
-- Параметры функции: день, например 12.05.2022.
-- Функция возвращает только список пиров.

-- Удаление функции.
DROP FUNCTION IF EXISTS fnc_check_date(peer_date date);
-- Создание функции.
CREATE OR REPLACE FUNCTION fnc_check_date(peer_date date)
    RETURNS TABLE (peer varchar) AS $$
    SELECT peer
    FROM timetracking
    WHERE "Date" = peer_date AND state = '1'
    GROUP BY peer
    HAVING SUM(state) = 1
    $$ LANGUAGE sql;

-- Тестовый запрос.
SELECT * FROM fnc_check_date('2022-06-09');

-- 4) Найти процент успешных и неуспешных проверок за всё время
-- Формат вывода: процент успешных, процент неуспешных

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_success_percent(result_data refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_success_percent(result_data refcursor)
AS $$
    BEGIN
        OPEN result_data FOR with tmp as (
SELECT
    id,
    "Check",
    state,
    "Time"
FROM p2p
WHERE NOT (state = 'Start')
UNION ALL
SELECT
    id,
    "Check",
    state,
    "Time"
FROM verter
WHERE NOT (state = 'Start'))
SELECT
    (cast(cast((SELECT count(*)
FROM p2p
WHERE NOT (state = 'Start')) - count(*) AS numeric) /  (SELECT count(*)
FROM p2p
WHERE NOT (state = 'Start')) * 100 AS int)) AS SuccessfulChecks,
cast(cast(count(*) AS numeric) / (SELECT count(*)
FROM p2p
WHERE NOT (state = 'Start')) * 100 AS int) AS UnsuccessfulChecks
FROM tmp
WHERE (state = 'Failure');
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_success_percent('cursor_name');
FETCH ALL IN "cursor_name";
COMMIT;

-- 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_points_change(result_data refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_points_change(result_data refcursor)
AS $$ BEGIN
    OPEN result_data FOR
SELECT
    checkingpeer AS Peer,
    SUM(pointsamount) AS PointsChange
FROM
(SELECT
    checkingpeer,
    SUM(pointsamount) AS pointsamount
FROM TransferredPoints
GROUP BY checkingpeer
UNION ALL
SELECT
    checkedpeer,
    SUM(-pointsamount) AS pointsamount
FROM TransferredPoints
GROUP BY checkedpeer) AS change
GROUP BY checkingpeer
ORDER BY PointsChange DESC;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_points_change('cursor_name');
FETCH ALL IN "cursor_name";
COMMIT;


-- 6) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

-- Удаление процедуры.
DROP procedure IF EXISTS pr_transferred_points(result_data refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_transferred_points(result_data refcursor)
AS $$
    BEGIN
        OPEN result_data FOR
SELECT "Peer1" as Peer,
       sum(pointsamount) AS PointsChange
FROM
(SELECT "Peer1",
        SUM("PointsAmount") AS pointsamount
FROM fnc_transferred_points()
GROUP BY "Peer1"
UNION ALL
SELECT "Peer2",
       SUM(-"PointsAmount") AS pointsamount
FROM fnc_transferred_points()
GROUP BY "Peer2") AS change
GROUP BY Peer
ORDER BY pointschange DESC;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_transferred_points('cursor_name');
FETCH ALL IN "cursor_name";
COMMIT;

-- 7) Определить самое часто проверяемое задание за каждый день
-- При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
-- Формат вывода: день, название задания

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_max_task_check(result_data refcursor);
-- Создание процедуры.
create or replace procedure pr_max_task_check(result_data refcursor)
AS $$
    BEGIN
        OPEN result_data FOR
  WITH t1 AS (
    SELECT
        "Date" AS d,
        checks.task,
        COUNT(task) AS tc
    FROM checks
    GROUP BY checks.task, d
)
SELECT t2.d AS day, t2.task
FROM (SELECT
          t1.task,
          t1.d,
          rank() OVER (PARTITION BY t1.d ORDER BY tc DESC) AS rank
    FROM t1) AS t2
WHERE rank = 1
ORDER BY day;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_max_task_check('cursor_name');
FETCH ALL IN "cursor_name";
COMMIT;

-- 8) Определить длительность последней P2P проверки
-- Под длительностью подразумевается разница между временем, указанным в записи со статусом "начало", и временем, указанным в записи со статусом "успех" или "неуспех".
-- Формат вывода: длительность проверки

DROP PROCEDURE IF EXISTS pr_check_duration;

CREATE OR REPLACE PROCEDURE pr_check_duration(IN ref refcursor)
AS $$
    DECLARE
        starts_check time := (SELECT
                                   "Time"
                               FROM p2p
                               WHERE state != 'Start'
                               AND "Check" = (SELECT max("Check")  FROM p2p)
                               LIMIT 1);
        end_check time := (SELECT
                                   "Time"
                               FROM p2p
                               WHERE state = 'Start'
                               AND "Check" = (SELECT max("Check")  FROM p2p)
                               LIMIT 1);
    BEGIN
        OPEN ref FOR
        SELECT starts_check - end_check AS Duration;
END;
$$ LANGUAGE plpgsql;

BEGIN;
    CALL pr_check_duration('cursor_name');
    FETCH ALL IN "cursor_name";
COMMIT;


-- 9) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
-- Параметры процедуры: название блока, например "CPP".
-- Результат вывести отсортированным по дате завершения.
-- Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока)
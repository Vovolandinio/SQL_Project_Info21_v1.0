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
        INNER JOIN TransferredPoints ON tp.checkingPeer = tp.checkedPeer
        AND tp.checkedPeer = tp.checkingPeer)
    (SELECT checkingPeer,
            checkedPeer,
            sum(result.pointsamount) FROM
    (SELECT tp.checkingPeer, tp.checkedPeer, tp.pointsamount FROM TransferredPoints tp
                                                          UNION
                                                          SELECT t.checkedPeer, t.checkingPeer, -t.pointsamount FROM tmp t) AS result
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
DROP PROCEDURE IF EXISTS pr_success_percent(IN ref refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_success_percent(IN ref refcursor)
AS $$
    BEGIN
        OPEN ref FOR
            WITH tmp AS (
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
                (cast
                    (cast((SELECT count(*)
                            FROM p2p
                            WHERE NOT (state = 'Start')) - count(*) AS numeric) /  (SELECT count(*)
                                                                                    FROM p2p
                                                                                    WHERE NOT (state = 'Start')) * 100 AS int)) AS SuccessfulChecks,
                cast
                    (cast(count(*) AS numeric) / (SELECT count(*)
                                                  FROM p2p
                                                  WHERE NOT (state = 'Start')) * 100 AS int) AS UnsuccessfulChecks
            FROM tmp
            WHERE (state = 'Failure');
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_success_percent('ref');
FETCH ALL IN "ref";
END;

-- 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_points_change(IN ref refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_points_change(IN ref refcursor)
AS $$ BEGIN
    OPEN ref FOR
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
CALL pr_points_change('ref');
FETCH ALL IN "ref";
END;

-- 6) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
-- Результат вывести отсортированным по изменению числа поинтов.
-- Формат вывода: ник пира, изменение в количество пир поинтов

-- Удаление процедуры.
DROP procedure IF EXISTS pr_transferred_points(IN ref refcursor);
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_transferred_points(IN ref  refcursor)
AS $$
    BEGIN
        OPEN ref  FOR
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
CALL pr_transferred_points('ref');
FETCH ALL IN "ref";
END;

-- 7) Определить самое часто проверяемое задание за каждый день
-- При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все.
-- Формат вывода: день, название задания

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_max_task_check(IN ref refcursor);
-- Создание процедуры.
create or replace procedure pr_max_task_check(IN ref  refcursor)
AS $$
    BEGIN
        OPEN ref FOR
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
CALL pr_max_task_check('ref');
FETCH ALL IN "ref";
END;

-- 8) Определить длительность последней P2P проверки
-- Под длительностью подразумевается разница между временем, указанным в записи со статусом "начало", и временем, указанным в записи со статусом "успех" или "неуспех".
-- Формат вывода: длительность проверки

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_check_duration;
-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_check_duration(IN ref refcursor)
AS $$
    DECLARE
        id_check_start int := (SELECT
                             "Check"
                         FROM p2p
                         WHERE state != 'Start'
                           AND "Check" = (SELECT max("Check")  FROM p2p)
                         LIMIT 1
            );
        id_check_end int := (SELECT
                                 "Check"
                             FROM p2p
                             WHERE state = 'Start'
                               AND "Check" = (SELECT max("Check") FROM p2p)
                             LIMIT 1
                             );
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
        IF id_check_end = id_check_start
        THEN
        OPEN ref FOR
        SELECT starts_check - end_check AS "Duration";
        ELSE
            RAISE NOTICE ' P2P check is not completed ';
            END IF;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_check_duration('ref');
FETCH ALL IN "ref";
END;


-- 9) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
-- Параметры процедуры: название блока, например "CPP".
-- Результат вывести отсортированным по дате завершения.
-- Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока)



-- 10) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
-- Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, проверяться у которого рекомендует наибольшее число друзей.
-- Формат вывода: ник пира, ник найденного проверяющего


DROP PROCEDURE IF EXISTS pr_recommendation_peer;

CREATE OR REPLACE PROCEDURE pr_recommendation_peer(IN ref refcursor)
AS $$
BEGIN
    WITH w_tmp1 AS
        (SELECT
             peers.nickname as peer,
             friends.peer2 as friend,
             r.recommendedpeer as recommendedpeer
    FROM peers
    INNER JOIN friends ON peers.nickname = friends.peer1
    INNER JOIN recommendations r ON friends.peer2 = r.peer AND peers.nickname != r.recommendedpeer
    ORDER BY 1,2),
    w_tmp2 AS (
    SELECT peer,
           recommendedpeer,
           count(recommendedpeer) AS count_of_recommends
    FROM w_tmp1
    GROUP BY 1,2
    ORDER BY 1,2),
    w_tmp3 AS (
    SELECT peer,
           recommendedpeer,
           count_of_recommends,
           ROW_NUMBER() OVER (PARTITION BY peer ORDER BY count_of_recommends DESC) AS num_of_row_for_each_peer
    FROM w_tmp2)

    SELECT peer,
           recommendedpeer
    FROM w_tmp3
    WHERE num_of_row_for_each_peer = 1;
END;
$$ LANGUAGE plpgsql;

BEGIN;
CALL pr_recommendation_peer('ref');
FETCH ALL FROM "ref";
END;


-- 11) Определить процент пиров, которые:
--
-- Приступили только к блоку 1
-- Приступили только к блоку 2
-- Приступили к обоим
-- Не приступили ни к одному
--
-- Пир считается приступившим к блоку, если он проходил хоть одну проверку любого задания из этого блока (по таблице Checks)
-- Параметры процедуры: название блока 1, например SQL, название блока 2, например A.
-- Формат вывода: процент приступивших только к первом









-- 12) Определить N пиров с наибольшим числом друзей
-- Параметры процедуры: количество пиров N.
-- Результат вывести отсортированным по кол-ву друзей.
-- Формат вывода: ник пира, количество друзей

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_count_friends;

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_count_friends(IN ref refcursor,IN limits int)
AS $$
    BEGIN
        OPEN ref FOR
SELECT
    peer1 AS peer,
    count(peer2) AS "FriendsCount"
FROM friends
GROUP BY peer
ORDER BY "FriendsCount" DESC
LIMIT limits;
    END;
    $$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_count_friends('ref',3);
FETCH ALL FROM "ref";
END;


-- 13) Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
-- Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения.
-- Формат вывода: процент успехов в день рождения, процент неуспехов в день рождения




-- 14) Определить кол-во XP, полученное в сумме каждым пиром
-- Если одна задача выполнена несколько раз, полученное за нее кол-во XP равно максимальному за эту задачу.
-- Результат вывести отсортированным по кол-ву XP.
-- Формат вывода: ник пира, количество XP

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_peer_xp_sum(ref refcursor);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_peer_xp_sum(IN ref refcursor)
AS $$
    BEGIN
    OPEN ref FOR
        SELECT peer,
               SUM(xpamount) AS "XP" FROM (
            SELECT peer, task, MAX(xpamount) AS xpamount
        FROM xp
        INNER JOIN checks c on c.id = xp."Check"
        GROUP BY peer, task) AS "XP"
        GROUP BY peer
            ORDER BY "XP" DESC;
    END
    $$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_peer_xp_sum('ref');
FETCH ALL FROM "ref";
END;

-- 15) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
-- Параметры процедуры: названия заданий 1, 2 и 3.
-- Формат вывода: список пиров


-- 16) Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
-- То есть сколько задач нужно выполнить, исходя из условий входа, чтобы получить доступ к текущей.
-- Формат вывода: название задачи, количество предшествующих


-- 17) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
-- Параметры процедуры: количество идущих подряд успешных проверок N.
-- Временем проверки считать время начала P2P этапа.
-- Под идущими подряд успешными проверками подразумеваются успешные проверки, между которыми нет неуспешных.
-- При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального.
-- Формат вывода: список дней

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_lucky_day(ref refcursor);

CREATE OR REPLACE PROCEDURE pr_lucky_day(IN ref refcursor, N int) AS
    $$ BEGIN
        OPEN ref FOR
            WITH t1 AS (
            SELECT c.id,
                   "Date",
                   peer,
                   v."Check" AS id_check,
                   t.maxxp AS max_xp,
                   x.xpamount AS peer_get_xp,
                   v.state
            FROM checks c
                INNER JOIN p2p on c.id = p2p."Check" AND (p2p.state = 'Success')
                INNER JOIN verter v on c.id = v."Check" AND (v.state = 'Success')
                INNER JOIN tasks t on t.title = c.task
                INNER JOIN xp x on c.id = x."Check"
            ORDER BY "Date")
            SELECT "Date"
            FROM t1
            WHERE t1.peer_get_xp > t1.max_xp * 0.8
            GROUP BY "Date"
            HAVING count("Date") >= N;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_lucky_day('ref', 3);
FETCH ALL FROM "ref";
END;


-- 18) Определить пира с наибольшим числом выполненных заданий
-- Формат вывода: ник пира, число выполненных заданий

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_max_done_task(ref refcursor);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_max_done_task(IN ref refcursor) AS
    $$
BEGIN
OPEN ref FOR
    SELECT peer, count(xpamount) xp from xp
    JOIN checks c on c.id = xp."Check"
    GROUP BY peer
    ORDER BY xp DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_max_done_task('ref');
FETCH ALL FROM "ref";
END;


-- 19) Определить пира с наибольшим количеством XP
-- Формат вывода: ник пира, количество XP

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_max_peer_xp(ref refcursor);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_max_peer_xp(IN ref refcursor) AS
    $$
    BEGIN
        OPEN ref FOR
        SELECT
            nickname AS "Peer",
            sum(xpamount) AS "XP"
        FROM peers
        INNER JOIN checks c on peers.nickname = c.peer
        INNER JOIN xp x on c.id = x."Check"
        GROUP BY nickname
        ORDER BY "XP" DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_max_peer_xp('ref');
FETCH ALL FROM "ref";
END;

-- 20) Определить пира, который провел сегодня в кампусе больше всего времени
-- Формат вывода: ник пира



-- 21) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
-- Параметры процедуры: время, количество раз N.
-- Формат вывода: список пиров

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_time_spent(IN ref refcursor, checkTime time, N int);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_time_spent(IN ref refcursor, checkTime time, N int)
AS $$
    BEGIN
        OPEN ref FOR
        SELECT peer
        FROM timetracking t
        WHERE state = 1
        AND t."Time" < checkTime
        GROUP BY peer
        HAVING count(peer) > N;
        END;
    $$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_time_spent('ref', '22:00:00', 2);
FETCH ALL IN "ref";
END;

-- 22) Определить пиров, выходивших за последние N дней из кампуса больше M раз
-- Параметры процедуры: количество дней N, количество раз M.
-- Формат вывода: список пиров

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_count_out_of_campus(IN ref refcursor, N int, M int);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_count_out_of_campus(IN ref refcursor, N int, M int)
AS $$
    BEGIN
OPEN ref FOR
  SELECT peer FROM (
      SELECT peer,
             "Date",
             count(*) AS counts
            FROM timetracking
            WHERE state = 2 AND "Date" > (current_date - N)
            GROUP BY peer, "Date"
            ORDER BY "Date") AS res
        GROUP BY peer
        HAVING SUM(counts) > M;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_count_out_of_campus('ref', 140, 0);
FETCH ALL IN "ref";
END;

-- 23) Определить пира, который пришел сегодня последним
-- Формат вывода: ник пира

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_last_current_online(IN ref refcursor);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_last_current_online(IN ref refcursor)
AS $$
    BEGIN
OPEN ref FOR
 SELECT peer
        FROM timetracking
        WHERE "Date" = current_date
        AND state = 1
        ORDER BY "Time" DESC
        LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_last_current_online('ref');
FETCH ALL IN "ref";
END;
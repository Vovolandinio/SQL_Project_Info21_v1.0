-- part3.2

-- DROP TABLE
CREATE TABLE returns_table_successful_checks (peer varchar, task varchar, xpamount integer);
drop  FUNCTION fnc_successful_checks;
CREATE or replace FUNCTION fnc_successful_checks()
RETURNS SETOF returns_table_successful_checks AS $tab$
    BEGIN
        return query
            WITH one AS (SELECT checks.id
            FROM checks
            INNER JOIN p2p ON checks.id = p2p."Check"
            INNER JOIN Verter ON checks.id = Verter."Check"
            WHERE p2p.state = 'Success' AND Verter.state = 'Success'
            GROUP BY checks.id)

            SELECT checks.peer,
                   checks.task,
                   xp.xpamount
            FROM one
            INNER JOIN checks ON one.id = checks.id
            INNER JOIN XP ON one.id = XP."Check"
            GROUP BY checks.peer, checks.task, xp.xpamount;
    END
$tab$ LANGUAGE plpgsql;
SELECT * FROM fnc_successful_checks();

-- part3.9
SELECT * FROM fnc_successful_checks_last_task('C');

CREATE TABLE returns_table_successful_checks_last_task (peer varchar, "date" date);
drop  FUNCTION fnc_successful_checks_last_task;
CREATE or replace FUNCTION fnc_successful_checks_last_task(mytask varchar)
RETURNS SETOF returns_table_successful_checks_last_task AS $tab$
    BEGIN
        return query
            WITH one AS (SELECT *
                        FROM tasks
                        WHERE title LIKE concat(mytask, '%')),
                              -- concat('C', '%') AND title NOT LIKE concat('CPP', '%')),
            last_task AS (SELECT MAX(title) AS title
                        FROM one),
            date_of_successful_check AS (SELECT peer,
                                                checks.task,
                                                checks."Date"
                        FROM checks
                        INNER JOIN p2p ON checks.id = p2p."Check"
                        INNER JOIN Verter ON checks.id = Verter."Check"
                        WHERE p2p.state = 'Success' AND Verter.state = 'Success'
                        GROUP BY checks.id)

            SELECT peer AS Peer,
                   date_of_successful_check."Date" AS Date
            FROM date_of_successful_check INNER JOIN last_task ON date_of_successful_check.task = last_task.title;
    END
$tab$ LANGUAGE plpgsql;

--3.11

SELECT * FROM fnc_successful_checks_blocks('C', 'C');

DROP TABLE returns_table_successful_checks_blocks CASCADE;
CREATE TABLE returns_table_successful_checks_blocks (Started_block1 BIGINT, Started_block2 BIGINT, Started_both BIGINT, Started_no_one BIGINT);

CREATE FUNCTION fnc_successful_checks_blocks(block1 varchar, block2 varchar)
RETURNS SETOF returns_table_successful_checks_blocks AS $$
    BEGIN
        RETURN QUERY
        WITH startedblock1 AS (SELECT DISTINCT peer
            FROM Checks
            WHERE Checks.task LIKE concat('C', '%')),
            startedblock2 AS (SELECT DISTINCT peer
            FROM Checks
            WHERE task LIKE concat(block2, '%')),
            startedboth AS (SELECT DISTINCT peer
            FROM Checks
            WHERE task LIKE concat(block2, '%') AND task LIKE concat(block1, '%'))

        SELECT Started_block1,
               Started_block2,
               Started_both,
               Started_no_one
        FROM (values((SELECT COUNT(*) * 100/8
        FROM startedblock1),
                      (SELECT COUNT(*)*100/8
        FROM startedblock2),
                     (SELECT COUNT(*)*100/8
        FROM startedboth),
                     (SELECT (8-COUNT(*))*100/8
        FROM startedboth)))
                s(Started_block1,Started_block2,Started_both, Started_no_one);
    END
$$
LANGUAGE plpgsql;

--3.13

SELECT * FROM fnc_successful_checks_birthday();

DROP TABLE returns_table_successful_checks_birthday CASCADE;
CREATE TABLE returns_table_successful_checks_birthday (SuccessfulChecks BIGINT, UnsuccessfulChecks BIGINT);
DROP FUNCTION fnc_successful_checks_birthday();

CREATE FUNCTION fnc_successful_checks_birthday()
RETURNS SETOF returns_table_successful_checks_birthday AS $$
DECLARE
    checks_count BIGINT;
BEGIN
    SELECT MAX(Checks.id) INTO checks_count
    FROM Checks;
    RETURN QUERY

    WITH suckchecks AS (SELECT *
    FROM Peers INNER JOIN Checks ON Peers.birthday = Checks."Date"
    WHERE Peers.Nickname = Checks.Peer)

    SELECT SuccessfulChecks,
           UnsuccessfulChecks
    FROM (values((SELECT COUNT(*)/checks_count * 100
                  FROM suckchecks
                  GROUP BY checks_count),
                  (SELECT (checks_count - COUNT(*))/checks_count * 100
                  FROM suckchecks
                  GROUP BY checks_count)))
    s(SuccessfulChecks, UnsuccessfulChecks);
END
$$
LANGUAGE plpgsql;

--3.14 idk why i did that part lol
CREATE FUNCTION fnc_checks_max_xp(block1 varchar)
RETURNS TABLE(Peer varchar, XP integer)
AS $$
BEGIN
        WITH one AS (SELECT checks.id
            FROM checks
            INNER JOIN p2p ON checks.id = p2p."Check"
            INNER JOIN Verter ON checks.id = Verter."Check"
            WHERE p2p.state = 'Success' AND Verter.state = 'Success'
            GROUP BY checks.id)

            SELECT checks.peer,
                   SUM(xp.xpamount)
            FROM one
            INNER JOIN checks ON one.id = checks.id
            INNER JOIN XP ON one.id = XP."Check"
            GROUP BY checks.peer;
    END
$$
LANGUAGE plpgsql;

--3.15
SELECT * FROM fnc_successful_tasks_1_2('C2_SimpleBashUtils', 'C6_s21_matrix', 'C8_3DViewer_v1');

CREATE FUNCTION fnc_successful_tasks_1_2(task1 varchar, task2 varchar, task3 varchar)
RETURNS TABLE(Peer varchar)
AS $$
        SELECT peer
        FROM fnc_successful_checks() AS successful_checks
        WHERE (successful_checks.task = task1 OR successful_checks.task = task2) AND successful_checks.task <> task3;
$$
LANGUAGE sql;

--3.16

WITH RECURSIVE r AS (
   SELECT
          CASE WHEN (tasks.parenttask IS NULL) THEN 0
          ELSE 1
          END AS counter,
	      tasks.title,
	      tasks.parenttask AS current_tasks,
	      tasks.parenttask
   FROM tasks

   UNION ALL

   SELECT
		  counter + 1 AS counter,
		  child.title AS title,
		  child.parenttask AS current_tasks,
	      child.parenttask
    FROM tasks AS child
    CROSS JOIN r AS parrent
	WHERE parrent.parenttask IS NOT NULL
)

SELECT  *
FROM r;


--task20

SELECT * FROM fnc_the_longest_interval();

DROP TABLE returns_table_the_longest_interval CASCADE;
CREATE TABLE returns_table_the_longest_interval(SuccessfulChecks BIGINT, UnsuccessfulChecks BIGINT);
DROP FUNCTION fnc_the_longest_interval();

CREATE FUNCTION fnc_the_longest_interval()
RETURNS SETOF returns_table_the_longest_interval
AS $$
    BEGIN
            WITH go_in AS (SELECT *
            FROM timetracking
            WHERE timetracking.state = 1),
                 go_out AS (SELECT *
            FROM timetracking
            WHERE timetracking.state = 2),
            intervals AS (SELECT go_in.peer,
                   MAX(go_out."Time" - go_in."Time") AS interval_in_school
            FROM go_in INNER JOIN go_out ON go_in."Date" = go_out."Date"
            GROUP BY go_in.peer
            ORDER BY interval_in_school DESC)

            SELECT peer
            FROM intervals
            LIMIT 1;
    END
$$
LANGUAGE sql;


--task24
CREATE OR REPLACE FUNCTION to_minutes(t time)
  RETURNS integer AS
$BODY$
DECLARE
    hs INTEGER;
    ms INTEGER;
BEGIN
    SELECT (EXTRACT( HOUR FROM  t::time) * 60*60) INTO hs;
    SELECT (EXTRACT (MINUTES FROM t::time)) INTO ms;
    SELECT (hs + ms) INTO ms;
    RETURN ms;
END;
$BODY$
  LANGUAGE 'plpgsql';

CREATE TABLE returns_table_interval(peer varchar, time_interval time);

drop  FUNCTION fnc_interval;
CREATE or replace FUNCTION fnc_interval(N int)
RETURNS SETOF returns_table_interval AS $tab$
    BEGIN
        return query

            WITH go_in AS (SELECT *
            FROM timetracking
            WHERE timetracking.state = 1),
                 go_out AS (SELECT *
            FROM timetracking
            WHERE timetracking.state = 2)

            SELECT go_in.peer,
                   go_out."Time" - go_in."Time"
            FROM go_in INNER JOIN go_out ON go_in."Date" = go_out."Date"
            WHERE (SELECT to_minutes(go_out."Time" - go_in."Time")) > N;
    END
$tab$ LANGUAGE plpgsql;
SELECT * FROM fnc_interval(12);

--task25




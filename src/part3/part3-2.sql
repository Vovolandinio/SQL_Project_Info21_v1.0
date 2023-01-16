-- part3.2

CREATE TABLE returns_table (peer varchar, task varchar, xpamount integer);

CREATE or replace FUNCTION fnc_successful_checks()
RETURNS SETOF returns_table AS $tab$
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

drop  FUNCTION fnc_successful_checks;

-- part3.9
CREATE or replace FUNCTION fnc_successful_checks(task varchar)
RETURNS SETOF returns_table AS $tab$
    BEGIN
        return query
            WITH one AS (SELECT *
                        FROM tasks
                        WHERE title LIKE concat('C', '%')),
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
            FROM date_of_successful_check INNER JOIN last_task ON date_of_successful_check.task = last_task.title
    END
$tab$ LANGUAGE plpgsql;

drop  FUNCTION fnc_successful_checks;

CREATE FUNCTION fnc_successful_checks_blocks(block1 varchar, block2 varchar)
RETURNS TABLE(Started_block1 int, Started_block2 int, Started_both int, Started_not_both int)
AS $$
    BEGIN
        WITH Started_block1 AS (SELECT peer
        FROM Checks
        WHERE task = concat(block1, '%')),
        Started_block2 AS (SELECT peer
        FROM Checks
        WHERE task = concat(block2, '%')),
        Started_both AS (SELECT peer
        FROM Checks
        WHERE task = concat(block2, '%') AND task = concat(block1, '%'))

        SELECT
        (SELECT COUNT(*)/9
        FROM Started_block1) AS Started_block1,

        (SELECT COUNT(*)/9
        FROM Started_block2) AS Started_block2,

        (SELECT COUNT(*)/9
        FROM Started_both) AS Started_both,

        (SELECT (9-COUNT(*))/9
        FROM Started_both) AS Started_not_both;
    END
$$
LANGUAGE plpgsql;

CREATE FUNCTION fnc_successful_checks_birthday(block1 varchar)
RETURNS TABLE(SuccessfulChecks integer, UnsuccessfulChecks integer)
AS $$
DECLARE
    checks_count integer;
BEGIN
        SELECT MAX(Checks.id) INTO STRICT checks_count
        FROM Checks;
        SELECT (SELECT COUNT(*)/checks_count
        FROM Peers INNER JOIN Checks ON Peers.birthday = Checks."Date"
        WHERE Peers.Nickname = Checks.Peer) AS SuccessfulChecks,
                (SELECT (checks_count - COUNT(*))/checks_count
        FROM Peers INNER JOIN Checks ON Peers.birthday = Checks."Date"
        WHERE Peers.Nickname = Checks.Peer) AS UnsuccessfulChecks;
    END
$$
LANGUAGE plpgsql;




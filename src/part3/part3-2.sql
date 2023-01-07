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
$tab$ LANGUAGE plpgsql

drop  FUNCTION fnc_successful_checks

-- part3.9
CREATE or replace FUNCTION fnc_successful_checks(task varchar)
AS $tab$
    BEGIN
        return query
            WITH one AS (SELECT *
                        FROM tasks
                        WHERE title LIKE concat('C', '%')),
                              -- concat('C', '%') AND title NOT LIKE concat('CPP', '%')),
            last_task AS (SELECT MIN(title) AS title
                        FROM one),
            date_of_successful_check AS (SELECT *
                                         )
            SELECT *
            FROM fnc_successful_checks() AS successful_checks INNER JOIN last_task ON successful_checks.task = last_task.title
    END
$tab$ LANGUAGE plpgsql





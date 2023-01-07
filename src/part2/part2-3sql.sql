CREATE or replace FUNCTION fnc_transferredpoints()
RETURNS TRIGGER AS $tab$
    BEGIN
        IF NEW.state = 'Start' THEN
			WITH one AS (SELECT DISTINCT
		  		NEW.checkingpeer,
		  		checks.peer as checkedpeer
			   FROM p2p
			   INNER JOIN checks ON checks.id = NEW."Check"
			   GROUP BY p2p.checkingpeer, checkedpeer)

            UPDATE transferredpoints
                SET pointsamount = transferredpoints.pointsamount + 1
                FROM one
                WHERE transferredpoints.checkingpeer = one.checkingpeer
                AND transferredpoints.checkedpeer = one.checkedpeer;
			RETURN NEW;
    END IF;
END;
$tab$ LANGUAGE plpgsql

CREATE OR REPLACE TRIGGER trg_transferredpoints
AFTER INSERT ON p2p
FOR EACH ROW
EXECUTE PROCEDURE fnc_transferredpoints();

SELECT *
FROM transferredpoints;

drop FUNCTION fnc_transferredpoints() CASCADE

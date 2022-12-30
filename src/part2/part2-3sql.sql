CREATE or replace FUNCTION fnc_transferredpoints()
RETURNS TRIGGER AS $tab$
    BEGIN
        IF NEW.state = 'Start'
            THEN
			WITH one AS (SELECT 
		  		MAX(transferredpoints.id) + 1 AS id,
		  		p2p.checkingpeer,
		  		checked,
		  		xp.xpamount AS pointsamount
			   FROM p2p
			   INNER JOIN checks ON checks.id = p2p."Check"
			   INNER JOIN xp ON xp.id = p2p."Check"
			   WHERE checkingpeer = checking
				  AND peer = checked
				  AND task = taskName)

		   INSERT INTO transferredpoints
		   ( id,
			 checkingpeer,
			 checkedpeer,
			 pointsamount )
		   VALUES
		   ( one.id,
			 one.checkingpeer,
			 one.checkedpeer,
			 one.pointsamount );
                
    END IF;
END;
$tab$ LANGUAGE plpgsql

CREATE OR REPLACE TRIGGER trg_transferredpoints
AFTER INSERT ON p2p
FOR EACH ROW
EXECUTE PROCEDURE fnc_transferredpoints();

SELECT *
FROM transferredpoints;

INSERT INTO p2p (checkingpeer, state)
VALUES ('Dori', 'Start');

drop FUNCTION fnc_transferredpoints() CASCADE

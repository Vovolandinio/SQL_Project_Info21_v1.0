CREATE OR REPLACE FUNCTION fnc_xp()
RETURNS TRIGGER AS $trg_xp$
	DECLARE
		status varchar(20);
		max_xp integer;
	BEGIN
		SELECT tasks.maxxp INTO max_xp
		   FROM checks
		   INNER JOIN tasks ON tasks.title = checks.task;
		SELECT p2p.state INTO status
		   FROM checks
		   INNER JOIN p2p ON checks.id = p2p."Check";
		   
	   IF new.xpamount > max_xp THEN
		  RAISE EXCEPTION 'xp amount is more than max xp for this task';
	   ELSEIF status = 'Failure' THEN
	   	   RAISE EXCEPTION 'check is failure';
 	   ELSE
		  RETURN NEW;
	   END IF;
END;
$trg_xp$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_xp
BEFORE INSERT ON xp
FOR EACH ROW
EXECUTE PROCEDURE fnc_xp();

INSERT INTO xp(check, xpamount)
VALUES(12, 750);

select *
FROM xp

DROP FUNCTION fnc_xp()
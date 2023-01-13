DROP PROCEDURE IF EXISTS pr_export_to_csv_from_table(table text, path text, delimetr text);

CREATE or replace PROCEDURE pr_export_to_csv_from_table(IN "table" text,IN path text,IN delimetr text)
AS $$
BEGIN
    EXECUTE format('COPY %s TO %L DELIMITER ''%s'' CSV HEADER;', $1, $2, $3);

END;
$$ LANGUAGE plpgsql;


-- export data from tables to csv files
CALL pr_export_to_csv_from_table('transferredpoints','/home/vladimir/Рабочий стол/SQL_Project_Info21_v1.0/src/part1/export/transferredpoints.csv',',');
CALL pr_export_to_csv_from_table('p2p','/home/vladimir/Рабочий стол/SQL_Project_Info21_v1.0/src/part1/export/p2p.csv',',');
CALL pr_export_to_csv_from_table('checks','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/checks.csv',',');
CALL pr_export_to_csv_from_table('verter','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/verter.csv',',');
CALL pr_export_to_csv_from_table('xp','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/xp.csv',',');
CALL pr_export_to_csv_from_table('friends','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/friends.csv',',');
CALL pr_export_to_csv_from_table('peers','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/peers.csv',',');
CALL pr_export_to_csv_from_table('recommendations','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/recommendations.csv',',');
CALL pr_export_to_csv_from_table('tasks','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/tasks.csv',',');
CALL pr_export_to_csv_from_table('timetracking','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/export/timetracking.csv',',');
-- Удаление данных из таблицы для последующего импорта.
TRUNCATE tasks CASCADE;
TRUNCATE peers CASCADE;


CREATE or replace PROCEDURE pr_import_from_csv_to_table(IN "table" text,IN path text,IN delimetr text)
AS $$
BEGIN
    EXECUTE format('COPY %s FROM %L WITH CSV DELIMITER %L HEADER;', $1, $2, $3);
END;
$$ LANGUAGE plpgsql;

-- insert the absolute path to the project!!!
SET path_to_project.const TO '/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0';

CALL pr_import_from_csv_to_table('peers',current_setting('path_to_project.const')||'/src/part1/import/peers'||'.csv',',');
CALL pr_import_from_csv_to_table('tasks',current_setting('path_to_project.const')||'/src/part1/import/tasks'||'.csv',',');
CALL pr_import_from_csv_to_table('checks',current_setting('path_to_project.const')||'/src/part1/import/checks'||'.csv',',');
CALL pr_import_from_csv_to_table('friends',current_setting('path_to_project.const')||'/src/part1/import/friends'||'.csv',',');
CALL pr_import_from_csv_to_table('p2p',current_setting('path_to_project.const')||'/src/part1/import/p2p'||'.csv',',');
CALL pr_import_from_csv_to_table('recommendations',current_setting('path_to_project.const')||'/src/part1/import/recommendations'||'.csv',',');
CALL pr_import_from_csv_to_table('timetracking',current_setting('path_to_project.const')||'/src/part1/import/timetracking'||'.csv',',');
CALL pr_import_from_csv_to_table('transferredpoints',current_setting('path_to_project.const')||'/src/part1/import/transferredpoints'||'.csv',',');
CALL pr_import_from_csv_to_table('verter',current_setting('path_to_project.const')||'/src/part1/import/verter'||'.csv',',');
CALL pr_import_from_csv_to_table('xp',current_setting('path_to_project.const')||'/src/part1/import/xp'||'.csv',',');
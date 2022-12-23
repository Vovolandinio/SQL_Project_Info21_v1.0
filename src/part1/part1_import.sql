-- Удаление данных из таблицы для последующего импорта.
TRUNCATE tasks CASCADE;
TRUNCATE peers CASCADE;


CREATE or replace PROCEDURE pr_import_from_csv_to_table(IN "table" text,IN path text,IN delimetr text)
LANGUAGE plpgsql as $$
BEGIN
    EXECUTE format('COPY %s FROM %L WITH CSV DELIMITER %L HEADER;', $1, $2, $3);
END; $$;


call pr_import('tasks','/Users/warbirdo/Desktop/SQL_Project_Info21_v1.0/src/part1/import/tasks.csv',',');
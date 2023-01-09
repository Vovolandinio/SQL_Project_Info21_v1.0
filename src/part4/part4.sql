-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных, уничтожает все те таблицы текущей базы данных, имена которых начинаются с фразы 'TableName'.


-- Создание таблицы для теста.
CREATE TABLE returns_table (peer varchar, task varchar, xpamount integer);

-- Удаление процедуры.
DROP PROCEDURE IF EXISTS pr_remove_table(TableName varchar);

-- Создание процедуры.
CREATE OR REPLACE PROCEDURE pr_remove_table(IN TableName text)
AS $$
BEGIN
FOR TableName  IN
    SELECT  quote_ident(table_name)
    FROM   information_schema.tables
    WHERE  table_name LIKE TableName || '%'
    AND    table_schema LIKE 'public'
LOOP
EXECUTE 'DROP TABLE ' || TableName;
END LOOP;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_remove_table('returns');
END;
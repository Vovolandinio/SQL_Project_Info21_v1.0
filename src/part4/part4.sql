-- 1) Создать хранимую процедуру, которая, не уничтожая базу данных,
-- уничтожает все те таблицы текущей базы данных, имена которых начинаются с фразы 'TableName'.

-- Создание таблицы для теста.
CREATE TABLE returns_table
(
    peer     varchar,
    task     varchar,
    xpamount integer
);

DROP PROCEDURE IF EXISTS pr_remove_table(TableName varchar);

CREATE OR REPLACE PROCEDURE pr_remove_table(IN TableName text)
AS
$$
BEGIN
    FOR TableName IN
        SELECT quote_ident(table_name)
        FROM information_schema.tables
        WHERE table_name LIKE TableName || '%'
          AND table_schema LIKE 'public'
        LOOP
            EXECUTE 'DROP TABLE ' || TableName;
        END LOOP;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_remove_table('returns');
END;

-- 2) Создать хранимую процедуру с выходным параметром, которая выводит список имен и параметров всех скалярных SQL функций
-- пользователя в текущей базе данных. Имена функций без параметров не выводить. Имена и список параметров должны выводиться в одну строку.
-- Выходной параметр возвращает количество найденных функций.

DROP PROCEDURE IF EXISTS pr_count_table(OUT n int);

CREATE OR REPLACE PROCEDURE pr_count_table(OUT n int)
AS
$$
BEGIN
    n = (SELECT count(*)
         FROM (SELECT routines.routine_name, parameters.data_type
               FROM information_schema.routines
                        LEFT JOIN information_schema.parameters ON routines.specific_name = parameters.specific_name
               WHERE routines.specific_schema = 'public'
                 AND parameters.data_type IS NOT NULL
               ORDER BY routines.routine_name, parameters.ordinal_position) as foo);
END
$$ LANGUAGE plpgsql;

DO
$$
    DECLARE
        res integer;
    BEGIN
        CALL pr_count_table(res);
        RAISE NOTICE 'Num %', res;
    END
$$;

-- 3) Создать хранимую процедуру с выходным параметром, которая уничтожает все SQL DML триггеры в текущей базе данных.
-- Выходной параметр возвращает количество уничтоженных триггеров.

DROP PROCEDURE IF EXISTS pr_delete_dml_triggers (IN ref refcursor, INOUT result int);

CREATE OR REPLACE PROCEDURE pr_delete_dml_triggers(IN ref refcursor, INOUT result int)
AS
$$
BEGIN
    FOR ref IN
        SELECT trigger_name || ' ON ' || event_object_table
        FROM information_schema.triggers
        WHERE trigger_schema = 'public'
        LOOP
            EXECUTE 'DROP TRIGGER ' || ref;
            result := result + 1;
        END LOOP;
END
$$ LANGUAGE plpgsql;

-- Тестовая транзакция.
BEGIN;
CALL pr_delete_dml_triggers('cursor_name', 0);
END;

-- Проверка.
SELECT trigger_name
FROM information_schema.triggers;



--4) Создать хранимую процедуру с входным параметром, которая выводит имена и описания типа объектов (только
-- хранимых процедур и скалярных функций), в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.

DROP PROCEDURE IF EXISTS pr_show_info (IN ref refcursor, IN name text);

CREATE OR REPLACE PROCEDURE pr_show_info(IN ref refcursor, IN name text)
AS
$$
BEGIN
    OPEN ref FOR
        SELECT routine_name,
               routine_type,
               routine_definition
        FROM information_schema.routines
        WHERE specific_schema = 'public'
          AND routine_definition LIKE '%' || name || '%';
END
$$ LANGUAGE plpgsql;


-- Тестовая транзакция.
BEGIN;
CALL pr_show_info('cursor_name', 'date');
FETCH ALL IN "cursor_name";
END;
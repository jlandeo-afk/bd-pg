-- Trigger Function: audit.on_function_event()

--

CREATE FUNCTION audit.on_function_event() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        INSERT INTO audit.function_log (datetime, schema_name, function_name, tag, function_body)
        SELECT
            NOW(),
            nspname,
            proname,
            command_tag,
            pg_get_functiondef(p.oid)
        FROM pg_event_trigger_ddl_commands() e
        JOIN pg_proc p      ON p.oid = e.objid
        JOIN pg_namespace n ON n.oid = p.pronamespace
        WHERE nspname = 'odiseo';
    END;
    $$;


ALTER FUNCTION audit.on_function_event() OWNER TO postgres;

--

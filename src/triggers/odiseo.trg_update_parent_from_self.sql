-- Trigger Function: odiseo.trg_update_parent_from_self()

--

CREATE FUNCTION odiseo.trg_update_parent_from_self() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            PERFORM fn_rebuild_parent_search_text(NEW.id);
            RETURN NULL;
        END;
        $$;


ALTER FUNCTION odiseo.trg_update_parent_from_self() OWNER TO postgres;

--

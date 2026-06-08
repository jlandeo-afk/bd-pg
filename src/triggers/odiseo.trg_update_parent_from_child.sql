-- Trigger Function: odiseo.trg_update_parent_from_child()

--

CREATE FUNCTION odiseo.trg_update_parent_from_child() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'odiseo', 'public'
    AS $$
            DECLARE
                v_parent_id BIGINT;
            BEGIN
                IF (TG_OP = 'DELETE') THEN
                    v_parent_id := OLD.parent_id;
                ELSE
                    v_parent_id := NEW.parent_id;
                END IF;

                IF v_parent_id IS NOT NULL THEN
                    PERFORM fn_rebuild_parent_search_text(v_parent_id);
                END IF;

                IF (TG_OP = 'UPDATE' AND OLD.parent_id IS NOT NULL AND OLD.parent_id <> NEW.parent_id) THEN
                    PERFORM fn_rebuild_parent_search_text(OLD.parent_id);
                END IF;
                
                RETURN NULL;
            END;
            $$;


ALTER FUNCTION odiseo.trg_update_parent_from_child() OWNER TO postgres;

--

-- Trigger Function: odiseo.trg_question_self_text()

--

CREATE FUNCTION odiseo.trg_question_self_text() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
            BEGIN
                NEW.search_text = COALESCE(NEW.code, '') || ' ' || 
                                COALESCE(NEW.number_question, '') || ' ' || 
                                COALESCE(NEW.short_description, '');
                RETURN NEW;
            END;
            $$;


ALTER FUNCTION odiseo.trg_question_self_text() OWNER TO postgres;

--

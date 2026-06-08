-- Trigger Function: odiseo.trg_update_question_status_date()

--

CREATE FUNCTION odiseo.trg_update_question_status_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    IF NEW.fl_active = true THEN
                        UPDATE question
                        SET
                            status_changed_at = NEW.created_at,
                            status = NEW.status
                        WHERE
                            id = NEW.question_id;
                    END IF;

                    RETURN NEW;
                END;
                $$;


ALTER FUNCTION odiseo.trg_update_question_status_date() OWNER TO postgres;

--

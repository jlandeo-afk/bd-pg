-- Function: odiseo.fn_change_subtopic_frequent_status(integer, integer, integer, boolean, character varying)

--

CREATE FUNCTION odiseo.fn_change_subtopic_frequent_status(p_university_id integer, p_subtopic_id integer, p_updated_by integer, p_is_frequent boolean, p_method character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
                        BEGIN
                            INSERT INTO frequent_university_subtopic ( university_id, subtopic_id, method, created_at, updated_by )
                            VALUES (p_university_id, p_subtopic_id, p_method, NOW(), p_updated_by)
                            ON CONFLICT (university_id, subtopic_id)
                            DO UPDATE SET
                                    is_frequent = p_is_frequent,
                                    fl_status = p_is_frequent,
                                    updated_at = NOW(),
                                    updated_by = p_updated_by;
                        END;
                        $$;


ALTER FUNCTION odiseo.fn_change_subtopic_frequent_status(p_university_id integer, p_subtopic_id integer, p_updated_by integer, p_is_frequent boolean, p_method character varying) OWNER TO postgres;

--

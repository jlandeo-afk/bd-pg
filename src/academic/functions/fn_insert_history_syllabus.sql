-- Function: academic.fn_insert_history_syllabus(bigint, bigint, bigint, text, timestamp without time zone, timestamp without time zone, character varying, json, bigint)

--

CREATE FUNCTION academic.fn_insert_history_syllabus(p_syllabus_id bigint, p_user_id bigint, p_role_id bigint, p_description text, p_created_at timestamp without time zone, p_updated_at timestamp without time zone, p_token character varying, p_weeks json, p_company_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$

    DECLARE
    p_id_history_syllabus BIGINT;

    BEGIN

    IF(p_token IS NULL) THEN
        INSERT INTO history_syllabus (syllabus_id,user_id,role_id,correlative,description,created_at,updated_at, company_id) 
        VALUES (p_syllabus_id,p_user_id,p_role_id,
        (SELECT (COALESCE(MAX(correlative),0) + 1) FROM history_syllabus WHERE syllabus_id = p_syllabus_id LIMIT 1),
        p_description,p_created_at,p_updated_at, p_company_id)
        RETURNING id INTO p_id_history_syllabus;
        RETURN p_id_history_syllabus;
    END IF;

    p_id_history_syllabus:= NULL;

    IF(p_token IS NOT NULL) THEN
        SELECT id INTO p_id_history_syllabus FROM history_syllabus WHERE token = p_token LIMIT 1;
    END IF;

    IF(p_id_history_syllabus IS NULL) THEN
        INSERT INTO history_syllabus (syllabus_id,user_id,role_id,correlative,description,created_at,updated_at,token,weeks, company_id) 
        VALUES (p_syllabus_id,p_user_id,p_role_id,
        (SELECT (COALESCE(MAX(correlative),0) + 1) FROM history_syllabus WHERE syllabus_id = p_syllabus_id LIMIT 1),
        p_description,p_created_at,p_updated_at,p_token,p_weeks, p_company_id)
        RETURNING id INTO p_id_history_syllabus;
    ELSE
        UPDATE history_syllabus
        SET weeks = merge_json_array_except(weeks, p_weeks)
        WHERE id = p_id_history_syllabus AND company_id = p_company_id;
    END IF;

    RETURN p_id_history_syllabus;

    END;            
    $$;


ALTER FUNCTION academic.fn_insert_history_syllabus(p_syllabus_id bigint, p_user_id bigint, p_role_id bigint, p_description text, p_created_at timestamp without time zone, p_updated_at timestamp without time zone, p_token character varying, p_weeks json, p_company_id bigint) OWNER TO postgres;

--

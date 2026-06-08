-- Function: odiseo.fn_verified_question(boolean)

--

CREATE FUNCTION odiseo.fn_verified_question(p_parent_val boolean) RETURNS TABLE(id bigint, code character varying, description text, short_description text, course_id smallint, parent_id bigint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    q.id,
                    q.code,
                    q.description,
                    q.short_description,
                    q.course_id,
                    q.parent_id
                FROM odiseo.question q
                WHERE q.fl_status = true
                AND q.short_description IS NOT NULL
                AND q.status NOT IN ('DUPL', 'ARCH')
                AND (
                    p_parent_val IS TRUE AND q.parent_id IS NULL
                    OR p_parent_val IS NOT TRUE AND q.parent_id IS NOT NULL
                )
				ORDER BY q.id ASC;
            END;
            $$;


ALTER FUNCTION odiseo.fn_verified_question(p_parent_val boolean) OWNER TO postgres;

--

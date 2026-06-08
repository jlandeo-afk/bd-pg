-- Function: odiseo.fn_create_level(character varying, character varying, jsonb, integer)

--

CREATE FUNCTION odiseo.fn_create_level(p_name character varying, p_description character varying, p_courses jsonb, p_created_by integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            WITH insert_level AS (
                INSERT INTO level (name, description, created_by, created_at)
                VALUES (p_name, p_description, p_created_by, NOW())
                RETURNING id
            ), courses AS (
                SELECT
                    (jsonb_array_elements_text(p_courses))::SMALLINT AS course_id
            ), course_codes AS (
                SELECT
                    c.course_id,
                    CONCAT(
                        co.code,
                        '-',
                        LPAD((COUNT(cl.id) + 1)::TEXT, 3, '0')
                    ) AS code
                FROM courses c
                JOIN course co ON co.id = c.course_id
                LEFT JOIN course_level cl ON cl.course_id = c.course_id
                GROUP BY c.course_id, co.code
            )
            INSERT INTO course_level (code, level_id, course_id, created_by, created_at)
            SELECT
                cc.code,
                il.id,
                cc.course_id,
                p_created_by,
                now()
            FROM course_codes cc
            CROSS JOIN insert_level il;
        END;
        $$;


ALTER FUNCTION odiseo.fn_create_level(p_name character varying, p_description character varying, p_courses jsonb, p_created_by integer) OWNER TO postgres;

--

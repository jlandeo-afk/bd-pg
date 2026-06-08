-- Function: odiseo.fn_delete_course(smallint, bigint)

--

CREATE FUNCTION odiseo.fn_delete_course(p_course_id smallint, p_deleted_by bigint) RETURNS TABLE(r_course_id smallint)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_count_questions BIGINT;
        BEGIN
            SELECT
                count(q.id) INTO v_count_questions
            FROM odiseo.question q
            WHERE q.course_id = p_course_id;

            IF v_count_questions = 0 THEN
                UPDATE odiseo.course SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                WHERE id = p_course_id;

                -- Eliminacion del curso en el template syllabus
                UPDATE odiseo.syllabus_template SET fl_status = false, deleted_by =  p_deleted_by, deleted_at  = now() WHERE  course_id =  p_course_id;

                RETURN QUERY SELECT p_course_id;
            ELSE
                RETURN QUERY SELECT NULL::SMALLINT;
            END IF;
        END;
        $$;


ALTER FUNCTION odiseo.fn_delete_course(p_course_id smallint, p_deleted_by bigint) OWNER TO postgres;

--

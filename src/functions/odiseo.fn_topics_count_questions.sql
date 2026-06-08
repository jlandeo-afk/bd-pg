-- Function: odiseo.fn_topics_count_questions(smallint)

--

CREATE FUNCTION odiseo.fn_topics_count_questions(f_course_id smallint) RETURNS TABLE(id smallint, code character varying, name character varying, course_id smallint, count_questions bigint)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                    v_course_id SMALLINT;
                    v_fl_pseudo_course BOOLEAN;
                        v_courses_pseudo SMALLINT[];
                        v_order_pseudo SMALLINT[];
                    BEGIN
                        -- Validar si es pseudocurso o no
                        SELECT co.id, co.fl_pseudo_course INTO v_course_id, v_fl_pseudo_course
                        FROM course co
                        WHERE co.id = f_course_id
                        AND co.fl_status = true;

                        -- Si es pseudocurso, no se cuenta las preguntas verificadas
                        IF v_fl_pseudo_course IS TRUE THEN
                            SELECT ARRAY(
                                SELECT pc.course_id
                                FROM course_pseudo_courses pc
                                WHERE pc.pseudo_course_id = f_course_id
                                AND pc.fl_status = true
                                ORDER BY pc.order ASC
                            ) INTO v_courses_pseudo;
                        ELSE
                            SELECT ARRAY[f_course_id] INTO v_courses_pseudo;
                        END IF;

                        RETURN QUERY
                        WITH tbl_question_veri AS (
                            SELECT
                                q.topic_id,
                                count(q.id) AS count_questions
                            FROM question q
                            WHERE q.status IN ('VERI', 'APRB')
                            GROUP BY q.topic_id
                        ), tbl_topic AS (
                            SELECT
                                t.id, t.code, t.name, t.course_id, COALESCE(qv.count_questions, 0) AS count_questions
                            FROM topic t
                            LEFT JOIN tbl_question_veri qv ON t.id = qv.topic_id
                            WHERE t.fl_status = true
                        )
                        SELECT tt.* FROM tbl_topic tt
                        WHERE tt.course_id = ANY(v_courses_pseudo)
                        ORDER BY array_position(v_courses_pseudo, tt.course_id) ASC, tt.code ASC;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_topics_count_questions(f_course_id smallint) OWNER TO postgres;

--

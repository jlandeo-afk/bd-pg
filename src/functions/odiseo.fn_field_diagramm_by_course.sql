-- Function: odiseo.fn_field_diagramm_by_course(smallint, bigint)

--

CREATE FUNCTION odiseo.fn_field_diagramm_by_course(p_course_id smallint, p_question_id bigint) RETURNS TABLE(id bigint, name character varying, fl_optional boolean)
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        RETURN QUERY
                        WITH tbl_parent_question AS (
                            SELECT
                                pq.type_text_id
                            FROM question q
                            LEFT JOIN parent_question pq ON q.parent_id = pq.id
                            WHERE q.id = p_question_id
                        ), tbl_diagrammed_course AS (
                            SELECT
                                sdc.id,
                                fd.name,
                                sdc.fl_optional 
                            FROM setting_diagrammed_courses sdc
                            JOIN field_diagrammed fd ON sdc.field_diagram_id = fd.id
                            WHERE sdc.course_id = p_course_id
                                AND sdc.category_text_id = (SELECT tpq.type_text_id FROM tbl_parent_question tpq)
                                AND sdc.fl_status = true
                            ORDER BY sdc.position ASC
                        ), tbl_diagrammed_null AS (
                            SELECT
                                sdc.id,
                                fd.name,
                                sdc.fl_optional 
                            FROM setting_diagrammed_courses sdc
                            JOIN field_diagrammed fd ON sdc.field_diagram_id = fd.id
                            WHERE sdc.course_id = p_course_id
                                AND sdc.category_text_id IS NULL
                                AND sdc.fl_status = true
                            ORDER BY sdc.position ASC
                        ), tbl_diagrammed_all AS (
                            SELECT * FROM tbl_diagrammed_course
                            UNION ALL
                            SELECT * FROM tbl_diagrammed_null
                            WHERE NOT EXISTS (SELECT * FROM tbl_diagrammed_course)
                        )
                        SELECT * FROM tbl_diagrammed_all;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_field_diagramm_by_course(p_course_id smallint, p_question_id bigint) OWNER TO postgres;

--

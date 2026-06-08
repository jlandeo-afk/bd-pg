-- Function: odiseo.get_detail_question_digitalized_v2(integer)

--

CREATE FUNCTION odiseo.get_detail_question_digitalized_v2(p_question_id integer) RETURNS TABLE(question_id bigint, diagram_fields jsonb, field_images jsonb)
    LANGUAGE plpgsql
    AS $$
                                    BEGIN
                                        RETURN QUERY
                                            WITH active_employee_didi_question  AS (
                                                SELECT
                                                    edq.id AS id,
                                                    edq.question_id AS question_id,
                                                    q.course_id,
                                                    pq.type_text_id category_id
                                                FROM employee_didi_question edq
                                                JOIN question q ON q.id = edq.question_id
                                                LEFT JOIN parent_question pq ON pq.id = q.parent_id 
                                                WHERE 1 = 1
                                                AND edq.question_id = p_question_id
                                                AND edq.fl_status IS TRUE
                                            ), didi_question_diagram_fields AS (
                                                SELECT
                                                    COALESCE(
                                                        JSONB_AGG(
                                                            JSONB_BUILD_OBJECT(
                                                                'id', edqf.id,
                                                                'value', edqf.value,
                                                                'created_at', edqf.created_at,
                                                                'field', fd.name,
                                                                'position', sdc.position,
                                                                'fl_optional', sdc.fl_optional,
                                                                'setting_diagrammed_course_id', sdc.id
                                                            ) ORDER BY sdc.position
                                                        ), '[]'::JSONB
                                                    ) AS diagram_fields
                                                FROM setting_diagrammed_courses sdc
                                                CROSS JOIN active_employee_didi_question aceq
                                                JOIN field_diagrammed fd ON sdc.field_diagram_id = fd.id
                                                LEFT JOIN employee_didi_question_field edqf
                                                    ON sdc.id = edqf.setting_diagrammed_course_id
                                                    AND edqf.employee_didi_question_id = aceq.id
                                                    AND edqf.fl_status IS TRUE
                                                WHERE
                                                    CASE 
                                                        WHEN aceq.category_id IS NULL THEN sdc.course_id = aceq.course_id AND sdc.category_text_id IS NULL
                                                        ELSE sdc.category_text_id = aceq.category_id AND sdc.course_id = aceq.course_id
                                                    END
                                                    AND fd.name IS NOT NULL
                                                    AND (sdc.fl_status = TRUE OR edqf.id IS NOT NULL)
                                                    AND sdc.fl_status = TRUE
                                            ), didi_question_field_images AS (
                                                SELECT
                                                    COALESCE(
                                                        JSONB_AGG(
                                                            JSONB_BUILD_OBJECT(
                                                                'id', edqfi.id,
                                                                'code', edqfi.code,
                                                                'image', edqfi.image
                                                            )
                                                        ), '[]'::JSONB
                                                    ) AS field_images
                                                FROM employee_didi_question_field_image edqfi
                                                JOIN active_employee_didi_question aceq
                                                ON aceq.id = edqfi.employee_didi_question_id
                                                AND edqfi.fl_status IS TRUE
                                                WHERE 1 = 1
                                                AND edqfi.id IS NOT NULL
                                            ) SELECT
                                                aedq.question_id,
                                                dqdf.diagram_fields,
                                                dfi.field_images
                                            FROM active_employee_didi_question aedq
                                            LEFT JOIN didi_question_diagram_fields dqdf ON 1 = 1
                                            LEFT JOIN didi_question_field_images dfi ON 1 = 1;
                                        END;
                                    $$;


ALTER FUNCTION odiseo.get_detail_question_digitalized_v2(p_question_id integer) OWNER TO postgres;

--

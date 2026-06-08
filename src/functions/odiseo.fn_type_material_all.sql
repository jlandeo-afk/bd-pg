-- Function: odiseo.fn_type_material_all(bigint, boolean, bigint, bigint, boolean)

--

CREATE FUNCTION odiseo.fn_type_material_all(p_cycle_id bigint DEFAULT NULL::bigint, p_fl_exam boolean DEFAULT NULL::boolean, p_course_id bigint DEFAULT NULL::bigint, p_week bigint DEFAULT NULL::bigint, p_all_weeks boolean DEFAULT NULL::boolean) RETURNS TABLE(id smallint, code character varying, description text, is_generic boolean, is_generic_text boolean, amount_question integer, course_amount_question integer, course_amount_text integer, course_amount_subquestion integer, subquestions_detail jsonb, thread smallint, percentage numeric, course_id smallint, material_name character varying, week_number integer)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_type_material_id SMALLINT;
                v_type_materials   SMALLINT[] := ARRAY[]::SMALLINT[];
                v_total_weeks      INTEGER := 0;
                v_current_week     INTEGER;
            BEGIN
                -- Recopilar type_materials excluidos cuando p_fl_exam no es null
                IF p_fl_exam IS NOT NULL THEN
                    FOR v_type_material_id IN
                        SELECT DISTINCT tm.id
                        FROM type_material tm
                        INNER JOIN type_material_bound tmb
                            ON tm.type_material_template_id = tmb.type_material_template_id
                            AND tmb.fl_status = true
                        WHERE tm.fl_status = true
                    LOOP
                        v_type_materials := array_append(v_type_materials, v_type_material_id);
                    END LOOP;
                END IF;

                -- Obtener total de semanas si p_all_weeks es true
                IF p_all_weeks IS TRUE AND p_cycle_id IS NOT NULL THEN
                    SELECT c.weeks INTO v_total_weeks
                    FROM cycle c
                    WHERE c.id = p_cycle_id
                    LIMIT 1;
                END IF;

                -- ---------------------------------------------------------------
                -- Modo p_all_weeks = true: iterar por cada semana
                -- ---------------------------------------------------------------
                IF p_all_weeks IS TRUE AND v_total_weeks > 0 THEN
                    FOR v_current_week IN 1..v_total_weeks LOOP
                        RETURN QUERY
                        WITH tbl_type_material_course AS (
                            SELECT
                                tm.id,
                                tm.code,
                                CONCAT(tm.description, ', ', c.description) AS description,

                                COALESCE(details.is_generic, tmc.is_generic)           AS is_generic,
                                COALESCE(details.is_generic_text, tmc.is_generic_text) AS is_generic_text,

                                tm.amount_question,

                                COALESCE(details.amount_question, tmc.amount_question) AS course_amount_question,
                                COALESCE(details.amount_text, tmc.amount_text)         AS course_amount_text,

                                COALESCE(
                                    (SELECT SUM((elem->>'subquestion_amount')::int)
                                     FROM jsonb_array_elements(COALESCE(details.subquestions, '[]'::jsonb)) elem),
                                    0
                                )::integer AS course_amount_subquestion,

                                COALESCE(details.subquestions, '[]'::jsonb) AS subquestions_detail,

                                tm.thread,
                                tm.percentage,
                                tmc.course_id,
                                tm.description AS material_name,
                                v_current_week::integer AS week_number

                            FROM type_material tm
                            LEFT JOIN type_material_course tmc ON tmc.type_material_id = tm.id
                            LEFT JOIN cycle c ON c.id = tm.cycle_id

                            LEFT JOIN fn_get_course_material_details(
                                p_course_id::SMALLINT,
                                v_current_week::INTEGER,
                                p_cycle_id::INTEGER
                            ) details ON details.type_material_id = tm.id

                            WHERE 1 = 1
                            AND (p_cycle_id IS NULL OR tm.cycle_id = p_cycle_id)
                            AND (p_fl_exam IS NULL OR tm.fl_exam = p_fl_exam)
                            AND (p_course_id IS NULL OR tmc.course_id = p_course_id)
                            AND (v_type_materials IS NULL OR v_type_materials = '{}' OR tm.id <> ANY(v_type_materials))
                            AND tm.fl_status IS TRUE
                            AND tmc.fl_status IS TRUE
                        )
                        SELECT
                            tbl.id,
                            tbl.code,
                            tbl.description,
                            tbl.is_generic,
                            tbl.is_generic_text,
                            tbl.amount_question,
                            tbl.course_amount_question,
                            tbl.course_amount_text,
                            tbl.course_amount_subquestion,
                            tbl.subquestions_detail,
                            tbl.thread,
                            tbl.percentage,
                            tbl.course_id,
                            tbl.material_name,
                            tbl.week_number
                        FROM tbl_type_material_course tbl
                        ORDER BY tbl.week_number,
                            CASE
                                WHEN tbl.description = 'ECO' THEN 1
                                WHEN tbl.description = 'Guía de clases' THEN 2
                                WHEN tbl.description = 'Homework' THEN 3
                                ELSE 4
                            END,
                            tbl.description,
                            tbl.code;
                    END LOOP;

                -- ---------------------------------------------------------------
                -- Modo normal (p_all_weeks = false / null): comportamiento original
                -- ---------------------------------------------------------------
                ELSE
                    RETURN QUERY
                    WITH tbl_type_material_course AS (
                        SELECT
                            tm.id,
                            tm.code,
                            CONCAT(tm.description, ', ', c.description) AS description,

                            COALESCE(details.is_generic, tmc.is_generic)           AS is_generic,
                            COALESCE(details.is_generic_text, tmc.is_generic_text) AS is_generic_text,

                            tm.amount_question,

                            COALESCE(details.amount_question, tmc.amount_question) AS course_amount_question,
                            COALESCE(details.amount_text, tmc.amount_text)         AS course_amount_text,

                            COALESCE(
                                (SELECT SUM((elem->>'subquestion_amount')::int)
                                 FROM jsonb_array_elements(COALESCE(details.subquestions, '[]'::jsonb)) elem),
                                0
                            )::integer AS course_amount_subquestion,

                            COALESCE(details.subquestions, '[]'::jsonb) AS subquestions_detail,

                            tm.thread,
                            tm.percentage,
                            tmc.course_id,
                            tm.description AS material_name,
                            NULL::integer AS week_number

                        FROM type_material tm
                        JOIN cycle c ON c.id = tm.cycle_id
                        LEFT JOIN type_material_course tmc ON tmc.type_material_id = tm.id

                        LEFT JOIN fn_get_course_material_details(
                            p_course_id::SMALLINT,
                            p_week::INTEGER,
                            p_cycle_id::INTEGER
                        ) details ON details.type_material_id = tm.id

                        WHERE 1 = 1
                        AND (p_cycle_id IS NULL OR tm.cycle_id = p_cycle_id)
                        AND (p_fl_exam IS NULL OR tm.fl_exam = p_fl_exam)
                        AND (p_course_id IS NULL OR tmc.course_id = p_course_id)
                        AND (v_type_materials IS NULL OR v_type_materials = '{}' OR tm.id <> ANY(v_type_materials))
                        AND tm.fl_status IS TRUE
                        AND tmc.fl_status IS TRUE
                        ORDER BY tm.code ASC
                    )
                    SELECT
                        tbl.id,
                        tbl.code,
                        tbl.description,
                        tbl.is_generic,
                        tbl.is_generic_text,
                        tbl.amount_question,
                        tbl.course_amount_question,
                        tbl.course_amount_text,
                        tbl.course_amount_subquestion,
                        tbl.subquestions_detail,
                        tbl.thread,
                        tbl.percentage,
                        tbl.course_id,
                        tbl.material_name,
                        tbl.week_number
                    FROM tbl_type_material_course tbl
                    ORDER BY CASE
                        WHEN tbl.description = 'ECO' THEN 1
                        WHEN tbl.description = 'Guía de clases' THEN 2
                        WHEN tbl.description = 'Homework' THEN 3
                        ELSE 4
                    END,
                    tbl.description,
                    tbl.code;
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_type_material_all(p_cycle_id bigint, p_fl_exam boolean, p_course_id bigint, p_week bigint, p_all_weeks boolean) OWNER TO postgres;

--

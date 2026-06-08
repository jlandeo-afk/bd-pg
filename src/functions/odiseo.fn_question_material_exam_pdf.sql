-- Function: odiseo.fn_question_material_exam_pdf(jsonb, smallint)

--

CREATE FUNCTION odiseo.fn_question_material_exam_pdf(p_week_exam_areas jsonb, p_course_id smallint) RETURNS TABLE(id bigint, type_material_id smallint, type_material character varying, order_course smallint, parent_type_material_id smallint, area_id bigint, area character varying, course_id smallint, course character varying, course_code character varying, topic_id smallint, topic_code character varying, topic character varying, subtopic_id smallint, subtopic_code character varying, subtopic character varying, level_id bigint, level character varying, type_question text, question_id bigint, code character varying, description_question text, description_parent_question text, answer_id bigint, parent_id bigint, config_alternative_id bigint, columns smallint, column_question smallint, column_count_topic bigint, column_width_topic numeric, column_spacing_topic numeric, layout_format_topic character varying, number_format_topic character varying, fl_image_conf_alter boolean, diagrammed json, diagrammed_images json, images json, alternatives json, question_maths json, alternative_maths json, didi_maths json, area_exam_id smallint, exam_area character varying, "position" smallint, status character varying, text_origin text, fl_is_manual boolean, category character varying, description_b text, text_traduction text, subquestion jsonb, parent_img jsonb, fl_show_in_material_with_solution boolean, fl_show_in_material_without_solution boolean)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_type_materials JSONB;
        v_university_id SMALLINT;
    BEGIN
        SELECT
            CASE
                WHEN m.university_id = 16 THEN m.university_id
                ELSE NULL::SMALLINT
            END
        INTO v_university_id
        FROM material_exam_area_week meaw
        JOIN detail_week_type_mat dwtm ON meaw.week_type_material_id = dwtm.id
        JOIN material m ON dwtm.material_id = m.id
        WHERE meaw.id IN (SELECT jsonb_array_elements_text(p_week_exam_areas)::BIGINT)
        LIMIT 1;

        RETURN QUERY
        WITH tlb_versions AS (
            SELECT
                ou.id AS university_id,
                (v.value->>'order')::INT AS "order",
                (v->>'version')::SMALLINT AS version
            FROM origin_university ou,
                LATERAL jsonb_array_elements(ou.versions::jsonb) AS v(value)
            WHERE ou.versions IS NOT NULL
            AND ou.versions <> '[]'
        ), area_ids AS ( -- Filtro de areas
            SELECT jsonb_array_elements_text(p_week_exam_areas)::BIGINT AS exam_area_id
        ), parents_questions_and_subquestions_to_extract AS ( -- <-- Version 1.1
            SELECT
                mepq.material_exam_area_week_id AS material_exam_area_week_id,
                mepq.id AS material_exam_parent_question_id,
                mepq.parent_question_id AS parent_question_id,
                mepq.position AS text_position,
                mepq.course_id AS course_id,
                JSONB_ARRAY_ELEMENTS(mepq.subquestion) AS subquestion
            FROM material_exam_parent_question mepq
            WHERE 1 = 1
            AND mepq.deleted_at IS NULL
            AND mepq.parent_question_id IS NOT NULL
            AND mepq.material_exam_area_week_id IN ( SELECT xd.exam_area_id FROM area_ids xd )
        ), subquestions_extracted AS ( -- <-- Version 1.1
            SELECT 
                pet.material_exam_area_week_id,
                pet.material_exam_parent_question_id,
                pet.parent_question_id,
                pet.text_position,
                pet.course_id,
                (pet.subquestion->>'question_id')::INTEGER AS question_id,
                (pet.subquestion->>'topic_id')::INTEGER AS topic_id,
                (pet.subquestion->>'subtopic_id')::INTEGER AS subtopic_id
            FROM parents_questions_and_subquestions_to_extract pet
            WHERE 1 = 1
            AND (pet.subquestion->>'question_id')::INTEGER IS NOT NULL
        ), tbl_question_exam_initial AS (
            SELECT meq.question_id
            FROM detail_week_type_mat dwt
            INNER JOIN material_exam_area_week meaw ON dwt.id = meaw.week_type_material_id AND meaw.fl_status = true
            INNER JOIN material_exam_question meq ON meaw.id = meq.material_exam_area_week_id AND meq.fl_status = true
            WHERE dwt.fl_status = true
            AND meaw.id IN (SELECT exam_area_id FROM area_ids)

            UNION

            SELECT
                sbs.question_id
            FROM subquestions_extracted sbs -- <-- Version 1.1
        ), tbl_diagrammed AS (
            SELECT
                ed.question_id,
                json_agg(json_build_object(
                    'id', edf.id,
                    'question_id', ed.question_id,
                    'setting_diagrammed_course_id', edf.setting_diagrammed_course_id,
                    'value', edf.value,
                    'position', sd.position,
                    'field_diagram', fd.name
                ))::TEXT AS diagrammed
            FROM employee_didi_question ed
            INNER JOIN question q ON ed.question_id = q.id
            INNER JOIN employee_didi_question_field edf ON ed.id = edf.employee_didi_question_id AND edf.fl_status = true
            INNER JOIN setting_diagrammed_courses sd ON edf.setting_diagrammed_course_id = sd.id
            INNER JOIN field_diagrammed fd ON sd.field_diagram_id = fd.id
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            WHERE ed.fl_status = true
            AND q.fl_status = true
            GROUP BY ed.question_id
        ), tbl_diagrammed_image AS (
            SELECT
                ed.question_id,
                json_agg(json_build_object(
                    'id', edfi.id,
                    'question_id', ed.question_id,
                    'code', edfi.code,
                    'image', edfi.image,
                    'extension', edfi.extension
                ))::TEXT AS diagrammed_images
            FROM employee_didi_question ed
            INNER JOIN question q ON ed.question_id = q.id
            INNER JOIN employee_didi_question_field_image edfi ON ed.id = edfi.employee_didi_question_id AND edfi.fl_status = true
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            WHERE ed.fl_status = true
            AND q.fl_status = true
            GROUP BY ed.question_id
        ), tbl_question_math AS (
            SELECT
                qm.question_id,
                jsonb_agg(json_build_object(
                    'id', qm.id,
                    'code', qm.code,
                    'path', qm.path,
                    'properties', qm.properties
                ))::TEXT AS question_maths
            FROM question_maths qm
            JOIN question q ON q.id = qm.question_id
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            WHERE q.fl_status = TRUE
            AND qm.fl_status = TRUE
            GROUP BY qm.question_id
        ), tbl_alternative_maths AS (
            SELECT
                a.question_id,
                jsonb_agg(json_build_object(
                    'id', am.id,
                    'code', am.code,
                    'path', am.path,
                    'properties', am.properties
                ))::TEXT AS alternative_maths
            FROM alternative_maths am
            JOIN alternative a on a.id = am.alternative_id
            JOIN question q on q.id = a.question_id
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            GROUP BY a.question_id
        ), tbl_didi_maths AS (
            SELECT
                edq.question_id,
                jsonb_agg(json_build_object(
                    'id', dm.id,
                    'code', dm.code,
                    'path', dm.path,
                    'properties', dm.properties
                ))::TEXT AS didi_maths
            FROM didi_maths dm
            LEFT JOIN employee_didi_question_field edqf on edqf.id = dm.didi_question_id
            LEFT JOIN employee_didi_question edq on edq.id = edqf.employee_didi_question_id
            LEFT JOIN question q on q.id = edq.question_id
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            GROUP BY edq.question_id
        ), tbl_question_image AS (
            SELECT
                q.id AS question_id,
                JSON_AGG(
                    JSONB_BUILD_OBJECT(
                        'id', qi.id,
                        'question_id', qi.question_id,
                        'code', qi.code,
                        'image', qi.image,
                        'extension', qi.extension
                    )
                )::TEXT  AS images
            FROM question q
            INNER JOIN question_image qi ON q.id = qi.question_id AND qi.fl_status
            INNER JOIN tbl_question_exam_initial tqei ON q.id = tqei.question_id
            WHERE q.fl_status = true
            GROUP BY q.id
        ), subquestions_and_parents AS ( -- <-- Version 1.1
            SELECT
                se.material_exam_area_week_id AS material_exam_area_week_id,
                se.material_exam_parent_question_id AS material_exam_parent_question_id,
                se.parent_question_id,
                se.text_position,
                c.name AS course,
                se.course_id,
                c.code AS course_code,
                pqn.code AS code,
                tt.name AS category,
                tts.name AS subcategory,
                t.name AS topic,
                t.code AS topic_code,
                st.name AS subtopic,
                st.code AS subtopic_code,
                pqn.columns AS column_parent_question,
                COALESCE(mcc.column_count, 2) AS column_count_topic,
                mcc.column_width AS column_width_topic,
                mcc.column_spacing AS column_spacing_topic,
                mcc.layout_format AS layout_format_topic,
                mcc.number_format AS number_format_topic,
                ca.fl_image AS fl_image_conf_alter,
                pl.name AS parent_question_level,
                pqn.description AS description_parent_question,
                pqn.description_b AS description_b,
                pqn.text_traduction AS text_traduction,
                dd.diagrammed::JSON AS diagrammed,
                q.columns AS column_question,
                q.answer_id,
                q.code AS question_code,
                q.id AS question_id,
                q.config_alternative_id AS config_alternative_id,
                q.description AS description_question,
                ca.columns,
                ctcs.fl_show_in_material_with_solution,
                ctcs.fl_show_in_material_without_solution
            FROM subquestions_extracted se
            LEFT JOIN parent_question pqn ON pqn.id = se.parent_question_id
            LEFT JOIN level pl ON pl.id = pqn.level_id
            LEFT JOIN question q ON q.id = se.question_id
            LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
            LEFT JOIN tbl_diagrammed dd ON dd.question_id = se.question_id
            LEFT JOIN type_text tt ON tt.id = pqn.type_text_id
            LEFT JOIN type_text_subcategories tts ON tts.id = pqn.type_text_subcategory_id
            LEFT JOIN course c ON c.id = se.course_id
            LEFT JOIN topic t ON t.id = se.topic_id
            LEFT JOIN material_column_configurations mcc ON mcc.topic_id = se.topic_id /* 1.11 */
            LEFT JOIN subtopic st ON st.id = se.subtopic_id
            LEFT JOIN alternative al ON al.question_id = se.question_id
            LEFT JOIN course_text_category_settings ctcs ON ctcs.course_id = pqn.course_id AND pqn.type_text_id = ctcs.type_text_id
            WHERE 1 = 1
            AND ( p_course_id IS NULL OR se.course_id = p_course_id )
            GROUP BY
                se.material_exam_area_week_id,
                se.material_exam_parent_question_id,
                se.parent_question_id,
                se.text_position,
                pqn.code,
                pqn.columns,
                pqn.description,
                pqn.description_b,
                pqn.text_traduction,
                c.name,
                se.course_id,
                c.code,
                tt.name,
                tts.name,
                t.name,
                t.code,
                st.name,
                st.code,
                mcc.column_count,
                mcc.column_width,
                mcc.column_spacing,
                mcc.layout_format,
                mcc.number_format,
                ca.fl_image,
                pl.name,
                dd.diagrammed,
                q.columns,
                q.answer_id,
                q.code,
                q.id,
                q.config_alternative_id,
                q.description,
                ca.columns,
        ctcs.fl_show_in_material_with_solution,
        ctcs.fl_show_in_material_without_solution
        ), alternatives_on_subquestions AS ( -- <-- Version 1.1
            SELECT
                ssp.question_id,
                CASE
                    WHEN COUNT(al.id) > 0 THEN
                        JSON_AGG(
                            JSON_BUILD_OBJECT(
                                'id', al.id,
                                'question_id', al.question_id,
                                'description', al.description,
                                'value', CASE WHEN ssp.answer_id = al.id THEN TRUE ELSE FALSE END
                            ) ORDER BY al.id
                        )
                    ELSE '[]'::JSON
                END AS alternatives
            FROM subquestions_and_parents ssp
            LEFT JOIN alternative al ON al.question_id = ssp.question_id
            GROUP BY ssp.question_id
        ), subquestions_and_parents_with_alternatives AS ( -- <-- Version 1.1
            SELECT
                sas.*,
                aos.alternatives
            FROM subquestions_and_parents sas
            LEFT JOIN alternatives_on_subquestions aos ON aos.question_id = sas.question_id
        ), tbl_t_questions_material AS ( -- <-- Version 1.1
            SELECT
                sap.material_exam_parent_question_id AS id,
                NULL::smallint AS type_material_id,
                NULL::character varying AS type_material,
                ttmco.position AS order_course,
                NULL::smallint AS parent_type_material_id,
                NULL::bigint AS area_id,
                NULL::character varying AS area,
                sap.course_id::smallint AS course_id,
                sap.course AS course,
                sap.course_code AS course_code,
                NULL::smallint AS topic_id,
                NULL::character varying AS topic_code,
                NULL::character varying AS topic,
                NULL::smallint AS subtopic_id,
                NULL::character varying AS subtopic_code,
                NULL::character varying AS subtopic,
                NULL::bigint AS level_id,
                NULL::character varying AS level,
                'T'::text AS type_question,
                sap.parent_question_id AS question_id,
                sap.code AS code,
                sap.description_parent_question AS description_question,
                sap.description_parent_question AS description_parent_question,
                NULL::bigint AS answer_id,
                sap.parent_question_id AS parent_id,
                NULL::bigint AS config_alternative_id,
                NULL::smallint AS columns,
                sap.column_parent_question AS columns_question,
                sap.column_count_topic AS column_count_topic,
                sap.column_width_topic AS column_width_topic,
                sap.column_spacing_topic AS column_spacing_topic,
                sap.layout_format_topic AS layout_format_topic,
                sap.number_format_topic AS number_format_topic,
                sap.fl_image_conf_alter AS fl_image_conf_alter,
                NULL::json AS diagrammed,
                NULL::json AS diagrammed_images,
                NULL::json AS images,
                NULL::json AS alternatives,
                NULL::json AS question_maths,
                NULL::json AS alternative_maths,
                NULL::json AS didi_maths,
                NULL::smallint AS area_exam_id,
                NULL::character varying AS exam_area,
                sap.text_position AS position,
                NULL::character varying AS status,
                opq.question_origin_text AS text_origin,
                NULL::boolean AS fl_is_manual,
                sap.category AS text_category,
                sap.description_b AS description_b,
                sap.text_traduction AS text_traduction,
                JSONB_AGG(
                    JSONB_BUILD_OBJECT(
                        'topic_name', sap.topic,
                        'subtopic_name', sap.subtopic,
                        'question_id', sap.question_id,
                        'column_question', sap.column_question,
                        'code', sap.question_code,
                        'course', sap.course,
                        'topic_code', sap.topic_code,
                        'subtopic_code', sap.subtopic_code,
                        'course_code', sap.course_code,
                        'description_question', sap.description_question,
                        'alternatives', sap.alternatives,
                        'diagrammed', sap.diagrammed,
                        'answer_id', sap.answer_id,
                        'config_alternative_id', sap.config_alternative_id,
                        'columns', sap.columns
                    )
                ) AS subquestion,
                vpq.parent_img::jsonb AS parent_img,
                sap.fl_show_in_material_with_solution,
                sap.fl_show_in_material_without_solution
            FROM subquestions_and_parents_with_alternatives sap
            LEFT JOIN vm_parent_question_images vpq ON vpq.parent_question_id = sap.parent_question_id
            JOIN material_exam_area_week mek ON mek.id = sap.material_exam_area_week_id
            JOIN detail_week_type_mat dwt ON dwt.id = mek.week_type_material_id
            JOIN material m ON m.id = dwt.material_id
            JOIN type_material tm ON tm.id = COALESCE(dwt.parent_type_material_id, dwt.type_material_id)
            JOIN template_type_material_courses_order ttmco ON ttmco.template_type_material_id = tm.type_material_template_id AND ttmco.course_id = sap.course_id
                AND ttmco.university_id IS NOT DISTINCT FROM v_university_id
            LEFT JOIN v_all_parent_origins_by_university opq ON opq.parent_id = sap.parent_question_id
                AND opq.university_id = m.university_id
            WHERE 1 = 1
            GROUP BY
                sap.material_exam_parent_question_id,
                sap.parent_question_id,
                sap.code,
                sap.category,
                sap.subcategory,
                sap.course,
                sap.course_code,
                sap.course_id,
                sap.parent_question_level,
                sap.material_exam_area_week_id,
                sap.text_position,
                sap.description_parent_question,
                sap.description_b,
                sap.text_traduction,
                sap.column_parent_question,
                sap.column_count_topic,
                sap.column_width_topic,
                sap.column_spacing_topic,
                sap.layout_format_topic,
                sap.number_format_topic,
                sap.fl_image_conf_alter,
                ttmco.position,
                vpq.parent_img::JSONB,
                opq.question_origin_text,
                sap.fl_show_in_material_with_solution,
                sap.fl_show_in_material_without_solution
        ),
        tbl_p_questions_material AS (
            SELECT
                meq.id AS id,
                dwt.type_material_id AS type_material_id,
                tm.description AS type_material,
                ttmco.position AS order_course,
                dwt.parent_type_material_id AS parent_type_material_id,
                c.area_id AS area_id,
                a.description AS area,
                meq.course_id AS course_id,
                c.name AS course,
                c.code AS course_code,
                meq.topic_id AS topic_id,
                t.code AS topic_code,
                t.name AS topic,
                meq.subtopic_id AS subtopic_id,
                s.code AS subtopic_code,
                s.name AS subtopic,
                meq.level_id AS level_id,
                l.name AS level,
                'P'::text AS type_question,
                meq.question_id AS question_id,
                COALESCE(qsh.code, q.code) AS code,
                q.description AS description_question,
                NULL AS description_parent_question,
                q.answer_id AS answer_id,
                q.parent_id AS parent_id,
                q.config_alternative_id AS config_alternative_id,
                ca.columns AS columns,
                q.columns AS columns_question,
                COALESCE(mcc.column_count, 2) AS column_count_topic,
                mcc.column_width AS column_width_topic,
                mcc.column_spacing AS column_spacing_topic,
                mcc.layout_format AS layout_format_topic,
                mcc.number_format AS number_format_topic,
                ca.fl_image AS fl_image_conf_alter,
                td.diagrammed::json AS diagrammed,
                tdi.diagrammed_images::json AS diagrammed_images,
                qi.images::json AS images,
                CASE
                    WHEN count(al.id) > 0 THEN json_agg(
                        json_build_object(
                            'id', al.id,
                            'question_id', al.question_id,
                            'description', al.description,
                            'value', CASE WHEN q.answer_id = al.id THEN TRUE ELSE FALSE END
                        ) ORDER BY al.id
                    )
                    ELSE '[]'::json
                END AS alternatives,
                tqma.question_maths::json,
                tam.alternative_maths::json,
                tdm.didi_maths::json,
                ea.id AS area_exam_id,
                ea.description AS exam_area,
                meq.position AS position,
                q.status AS status,
                oqu.question_origin_text AS text_origin,
                meq.fl_is_manual AS fl_is_manual,
                NULL AS text_category,
                NULL AS description_b,
                NULL AS text_traduction,
                NULL::jsonb AS subquestion,
                NULL::jsonb AS parent_img,
                NULL::boolean fl_show_in_material_with_solution,
                NULL::boolean fl_show_in_material_without_solution
            FROM detail_week_type_mat dwt
            INNER JOIN material m ON dwt.material_id = m.id
            INNER JOIN material_exam_area_week meaw ON dwt.id = meaw.week_type_material_id
            INNER JOIN material_exam_question meq ON meaw.id = meq.material_exam_area_week_id AND meq.fl_status = true
            LEFT JOIN question_shares qsh ON qsh.question_id = meq.question_id AND qsh.deleted_at IS NULL
            INNER JOIN question q ON meq.question_id = q.id
            INNER JOIN course c ON meq.course_id = c.id
            INNER JOIN topic t ON meq.topic_id = t.id
            INNER JOIN subtopic s ON meq.subtopic_id = s.id
            INNER JOIN level l ON meq.level_id = l.id
            INNER JOIN type_material tm ON dwt.type_material_id = tm.id
            INNER JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
            INNER JOIN area a ON c.area_id = a.id
            LEFT JOIN material_column_configurations mcc ON meq.topic_id = mcc.topic_id
            LEFT JOIN template_type_material_courses_order ttmco ON tm.type_material_template_id = ttmco.template_type_material_id
                AND ttmco.course_id = meq.course_id
                AND ttmco.university_id IS NOT DISTINCT FROM v_university_id
            LEFT JOIN alternative al ON q.id = al.question_id
            LEFT JOIN tbl_diagrammed td ON q.id = td.question_id
            LEFT JOIN tbl_diagrammed_image tdi ON q.id = tdi.question_id
            LEFT JOIN tbl_question_image qi ON q.id = qi.question_id
            LEFT JOIN tbl_question_math tqma ON tqma.question_id = q.id
            LEFT JOIN tbl_alternative_maths tam ON tam.question_id = q.id
            LEFT JOIN exam_area ea ON ea.id = meaw.area_id AND ea.fl_status = true
            LEFT JOIN tbl_didi_maths tdm ON tdm.question_id = q.id
            LEFT JOIN v_all_question_origins_by_university oqu ON meq.question_id = oqu.question_id
                AND oqu.university_id = m.university_id
            WHERE 1 = 1 
            AND meaw.id IN ( SELECT xe.exam_area_id FROM area_ids xe )
            AND ( p_course_id IS NULL OR meq.course_id = p_course_id )
            GROUP BY
                meq.id,
                dwt.type_material_id,
                dwt.parent_type_material_id,
                ttmco.position,
                tm.description,
                c.area_id,
                a.description,
                meq.course_id,
                c.name,
                c.code,
                meq.topic_id,
                t.name,
                meq.subtopic_id,
                s.name,
                meq.level_id,
                meq.question_id,
                COALESCE(qsh.code, q.code),
                q.description,
                q.answer_id,
                q.parent_id,
                q.config_alternative_id,
                mcc.column_count,
                mcc.column_width,
                mcc.column_spacing,
                mcc.layout_format,
                mcc.number_format,
                ca.fl_image,
                td.diagrammed,
                tdi.diagrammed_images,
                qi.images,
                t.code,
                s.code,
                l.name,
                tdm.didi_maths,
                tqma.question_maths,
                tam.alternative_maths,
                q.columns,
                ea.id,
                meq.position,
                q.status,
                ca.columns,
                oqu.question_origin_text
        ), text_with_subquestions_and_questions AS  (
            SELECT * FROM tbl_t_questions_material -- <-- Version 1.1
            UNION ALL
            SELECT * FROM tbl_p_questions_material
        )
        SELECT tqm.* FROM text_with_subquestions_and_questions tqm
        ORDER BY
            tqm.order_course,
            tqm.position,
            tqm.type_question DESC,
            tqm.topic_code,
            tqm.subtopic_code,
            tqm.level,
            tqm.parent_id,
            tqm.question_id;
    END;
    $$;


ALTER FUNCTION odiseo.fn_question_material_exam_pdf(p_week_exam_areas jsonb, p_course_id smallint) OWNER TO postgres;

--

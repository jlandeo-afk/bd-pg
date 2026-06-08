-- Function: odiseo.fn_question_material_ballot_pdf(jsonb, smallint)

--

CREATE FUNCTION odiseo.fn_question_material_ballot_pdf(p_week_type_materials jsonb, p_course_id smallint) RETURNS TABLE(id bigint, type_material_id smallint, type_material character varying, order_course smallint, parent_type_material_id smallint, area_id bigint, area character varying, course_id smallint, course character varying, topic_id smallint, topic_code character varying, topic character varying, subtopic_id smallint, subtopic_code character varying, subtopic character varying, level_id bigint, level character varying, type character varying, question_id bigint, absolute_position smallint, position_question smallint, code character varying, description_question text, answer_id bigint, parent_id bigint, config_alternative_id bigint, columns smallint, styles text, column_count_topic bigint, column_width_topic numeric, column_spacing_topic numeric, layout_format_topic character varying, number_format_topic character varying, fl_image_conf_alter boolean, diagrammed json, diagrammed_images json, images json, alternatives json, question_maths json, alternative_maths json, didi_maths json, column_question smallint, course_code character varying, ter numeric, parent_img json, type_question text, text_traduction text, description_parent_question text, subquestion json, description_b text, category character varying, subcategory character varying, text_origin text, status character varying, fl_show_in_material_with_solution boolean, fl_show_in_material_without_solution boolean)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_type_materials BIGINT[];
        BEGIN
            SELECT ARRAY(SELECT jsonb_array_elements_text(p_week_type_materials)::BIGINT) INTO v_type_materials;

            RETURN QUERY
            WITH tlb_question_materials AS (
                SELECT
                    mbq.id,
                    dwt.type_material_id,
                    tm.description AS type_material,
                    course_order.position AS order_course,
                    dwt.parent_type_material_id,
                    c.area_id,
                    a.description AS area,
                    mbq.course_id,
                    c.name AS course,
                    mbq.topic_id,
                    t.code as topic_code,
                    t.name AS topic,
                    mbq.subtopic_id::SMALLINT,
                    s.code AS subtopic_code,
                    s.name AS subtopic,
                    COALESCE(mbq.usage_level_id, mbq.level_id) AS level_id,
                    l.name as level,
                    mbq.type,
                    mbq.question_id,
                    mbq.position AS position_question,
                    mbq.absolute_position,
                    COALESCE(qsh.code, q.code, pq.code) AS code,
                    COALESCE(q.description, pq.description) AS description_question,
                    q.answer_id,
                    q.parent_id,
                    q.config_alternative_id,
                    ca.columns,
                    ca.styles,
                    COALESCE(mcc.column_count, 2)  AS column_count_topic,
                    mcc.column_width AS column_width_topic,
                    mcc.column_spacing AS column_spacing_topic,
                    mcc.layout_format AS layout_format_topic,
                    mcc.number_format AS number_format_topic,
                    ca.fl_image AS fl_image_conf_alter,
                    diag.diagrammed::JSON,
                    vqdi.diagrammed_images::JSON,
                    img.images::JSON,
                    COALESCE(alt.alternatives::JSON, '[]'::JSON) AS alternatives,
                    math.question_maths::JSON,
                    vam.alternative_maths::JSON,
                    vdm.didi_maths::JSON,
                    COALESCE(q.columns, pq.columns) AS column_question,
                    c.code AS course_code,
                    q.ter,
                    vpdm.parent_img::JSON,
                    CASE WHEN pq.id IS NULL THEN 'P' ELSE 'T' END AS type_question,
                    pq.text_traduction,
                    pq.description description_parent_question,
                    (
                        SELECT
                        json_agg(
                            jsonb_build_object(
                                'topic_name', t.name,
                                'subtopic_name', st.name,
                                'question_id', mbs.question_id,
                                'column_question', q.columns,
                                'code', q.code,
                                'course', c.name,
                                'topic_code', t.code,
                                'subtopic_code', st.code,
                                'course_code', c.code,
                                'description_question', q.description,
                                'alternatives', COALESCE(vqa.alternatives, '[]'::jsonb),
                                'diagrammed', vqd.diagrammed,
                                'answer_id', q.answer_id
                            )
                        )
                        FROM
                        material_ballot_subquestions mbs
                        JOIN question q ON mbs.question_id = q.id
                        JOIN topic AS t ON mbs.topic_id = t.id
                        JOIN subtopic AS st ON mbs.subtopic_id = st.id
                        JOIN course c ON mbs.course_id = c.id
                        LEFT JOIN LATERAL (
                            SELECT jsonb_agg(jsonb_build_object('id', a.id, 'description', a.description) ORDER BY a.id) AS alternatives
                            FROM odiseo.alternative a WHERE a.question_id = mbs.question_id AND a.fl_status = true
                        ) vqa ON TRUE
                        LEFT JOIN LATERAL (
                            SELECT jsonb_agg(jsonb_build_object('id', edf.id, 'value', edf.value, 'position', sd."position", 'field_diagram', fd.name) ORDER BY sd.position) AS diagrammed
                            FROM odiseo.employee_didi_question ed
                            JOIN odiseo.employee_didi_question_field edf ON ed.id = edf.employee_didi_question_id AND edf.fl_status = true
                            JOIN odiseo.setting_diagrammed_courses sd ON edf.setting_diagrammed_course_id = sd.id AND sd.fl_active = true AND sd.fl_status = true
                            JOIN odiseo.field_diagrammed fd ON sd.field_diagram_id = fd.id
                            WHERE ed.question_id = mbs.question_id AND ed.fl_status = true AND edf.value IS NOT NULL
                        ) vqd ON TRUE
                        WHERE mbs.material_ballot_question_id = mbq.id
                          AND mbs.fl_status = TRUE
                          AND mbs.deleted_at IS NULL
                          AND mbs.question_id IS NOT NULL
                    ) subquestion,
                    pq.description_b,
                    tt.name category,
                    tts.name subcategory,
                    COALESCE(vaqo.question_origin_text, vapo.question_origin_text) text_origin,
                    q.status,
                    ctcs.fl_show_in_material_with_solution,
                    ctcs.fl_show_in_material_without_solution
                FROM detail_week_type_mat dwt
                INNER JOIN material m ON dwt.material_id = m.id
            
                INNER JOIN material_ballot_question mbq
                    ON dwt.id = mbq.week_type_material_id
                    AND mbq.fl_status = TRUE
                    AND mbq.week_type_material_id = ANY(v_type_materials)
                    AND (p_course_id IS NULL OR mbq.course_id = p_course_id)
                    AND COALESCE(mbq.question_id, mbq.parent_question_id) IS NOT NULL
                LEFT JOIN question q ON mbq.question_id = q.id
                LEFT JOIN LATERAL (
                    SELECT qs.code
                    FROM question_shares qs
                    WHERE qs.question_id = q.id
                    AND qs.course_id = mbq.course_id
                    AND qs.topic_id = mbq.topic_id
                    AND qs.subtopic_id = mbq.subtopic_id
                    AND qs.deleted_at IS NULL
                    ORDER BY qs.updated_at DESC NULLS LAST
                    LIMIT 1
                ) qsh ON TRUE
                LEFT JOIN parent_question pq ON pq.id = mbq.parent_question_id
                INNER JOIN course c ON mbq.course_id = c.id
                
                LEFT JOIN topic t ON mbq.topic_id = t.id
                LEFT JOIN subtopic s ON mbq.subtopic_id = s.id
                INNER JOIN level l ON COALESCE(mbq.usage_level_id, mbq.level_id) = l.id
                INNER JOIN type_material tm ON dwt.type_material_id = tm.id
                LEFT JOIN configuration_alternative ca ON q.config_alternative_id = ca.id
                INNER JOIN area a ON c.area_id = a.id
                LEFT JOIN material_column_configurations mcc ON mbq.topic_id = mcc.topic_id
                LEFT JOIN (
                    SELECT ttmco.course_id, tm.id AS type_material_id, ttmco.position, ttmco.university_id
                    FROM template_type_material_courses_order ttmco
                    JOIN type_material tm ON tm.type_material_template_id = ttmco.template_type_material_id
                ) AS course_order ON course_order.type_material_id = COALESCE(dwt.parent_type_material_id, dwt.type_material_id)
                    AND course_order.course_id = mbq.course_id
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', a.id, 'description', a.description) ORDER BY a.id) AS alternatives
                    FROM odiseo.alternative a WHERE a.question_id = q.id AND a.fl_status = true
                ) alt ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', edf.id, 'value', edf.value, 'position', sd."position", 'field_diagram', fd.name) ORDER BY sd.position) AS diagrammed
                    FROM odiseo.employee_didi_question ed
                    JOIN odiseo.employee_didi_question_field edf ON ed.id = edf.employee_didi_question_id AND edf.fl_status = true
                    JOIN odiseo.setting_diagrammed_courses sd ON edf.setting_diagrammed_course_id = sd.id AND sd.fl_active = true AND sd.fl_status = true
                    JOIN odiseo.field_diagrammed fd ON sd.field_diagram_id = fd.id
                    WHERE ed.question_id = q.id AND ed.fl_status = true AND edf.value IS NOT NULL
                ) diag ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', edfi.id, 'question_id', ed.question_id, 'code', edfi.code, 'image', edfi.image, 'extension', edfi.extension)) AS diagrammed_images
                    FROM odiseo.employee_didi_question ed
                    JOIN odiseo.employee_didi_question_field_image edfi ON ed.id = edfi.employee_didi_question_id AND edfi.fl_status = true
                    WHERE ed.question_id = q.id AND ed.fl_status = true
                ) vqdi ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', qi.id, 'code', qi.code, 'image', qi.image, 'extension', qi.extension)) AS images
                    FROM odiseo.question_image qi WHERE qi.question_id = q.id AND qi.fl_status = true
                ) img ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', qm.id, 'code', qm.code, 'path', qm.path, 'properties', qm.properties)) AS question_maths
                    FROM odiseo.question_maths qm WHERE qm.question_id = q.id AND qm.fl_status = true
                ) math ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', am.id, 'code', am.code, 'path', am.path, 'properties', am.properties)) AS alternative_maths
                    FROM odiseo.alternative a
                    JOIN odiseo.alternative_maths am ON a.id = am.alternative_id AND am.fl_status = true
                    WHERE a.question_id = q.id AND a.fl_status = true
                ) vam ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', dm.id, 'code', dm.code, 'path', dm.path, 'properties', dm.properties)) AS didi_maths
                    FROM odiseo.employee_didi_question ed
                    JOIN odiseo.employee_didi_question_field edf ON ed.id = edf.employee_didi_question_id AND edf.fl_status = true
                    JOIN odiseo.didi_maths dm ON edf.id = dm.didi_question_id AND dm.fl_status = true
                    WHERE ed.question_id = q.id AND ed.fl_status = true
                ) vdm ON TRUE
                LEFT JOIN LATERAL (
                    SELECT jsonb_agg(jsonb_build_object('id', pi.id, 'code', pi.code, 'image', pi.image)) AS parent_img
                    FROM odiseo.parent_image pi WHERE pi.parent_id = pq.id AND pi.fl_status = true
                ) vpdm ON TRUE
                LEFT JOIN type_text tt ON tt.id = pq.type_text_id
                LEFT JOIN course_text_category_settings ctcs on ctcs.course_id = c.id and ctcs.type_text_id = tt.id
                LEFT JOIN type_text_subcategories tts ON tts.id = pq.type_text_subcategory_id
                LEFT JOIN v_all_question_origins_by_university vaqo ON mbq.question_id = vaqo.question_id
                    AND vaqo.university_id = m.university_id
                LEFT JOIN v_all_parent_origins vapo ON mbq.parent_question_id = vapo.parent_id
                    AND vapo.university_id = m.university_id
                WHERE 1 = 1
                AND course_order.university_id IS NULL
                ORDER BY
                    order_course,
                    area DESC,
                    mbq.course_id,
                    type_material_id,
                    mbq.absolute_position,
                    mbq.position,
                    s.code,
                    l.name,
                    q.parent_id,
                    mbq.type,
                    mbq.question_id
            )
            SELECT * FROM tlb_question_materials;
        END;
        $$;


ALTER FUNCTION odiseo.fn_question_material_ballot_pdf(p_week_type_materials jsonb, p_course_id smallint) OWNER TO postgres;

--

-- Function: questions.fn_question_material_class_pdf(jsonb, smallint)

--

CREATE FUNCTION questions.fn_question_material_class_pdf(p_week_type_materials jsonb, p_course_id smallint) RETURNS TABLE(id bigint, type_material_id smallint, type_material character varying, order_course smallint, parent_type_material_id smallint, area_id bigint, area character varying, course_id smallint, course character varying, topic_id smallint, topic_code character varying, topic character varying, subtopic_id smallint, subtopic_code character varying, subtopic character varying, level_id bigint, level character varying, type character varying, question_id bigint, code character varying, description_question text, answer_id bigint, parent_id bigint, config_alternative_id bigint, columns smallint, styles text, column_count_topic bigint, column_width_topic numeric, column_spacing_topic numeric, layout_format_topic character varying, number_format_topic character varying, fl_image_conf_alter boolean, diagrammed json, diagrammed_images json, images json, alternatives json, question_maths json, alternative_maths json, didi_maths json, column_question smallint, position_question smallint, absolute_position smallint, status character varying, origin jsonb)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_type_materials JSONB;
                BEGIN
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
                        WHERE ed.fl_status = true
                        AND q.status = 'VERI'
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
                        WHERE ed.fl_status = true
                        AND q.status = 'VERI'
                        AND q.fl_status = true
                        GROUP BY ed.question_id
                    ), tbl_question_image AS (
                        SELECT
                            q.id AS question_id,
                            json_agg(json_build_object(
                                'id', qi.id,
                                'question_id', qi.question_id,
                                'code', qi.code,
                                'image', qi.image,
                                'extension', qi.extension
                            ))::TEXT  AS images
                        FROM question q
                        INNER JOIN question_image qi ON q.id = qi.question_id AND qi.fl_status
                        where q.fl_status = true
                        GROUP BY q.id
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
                        join alternative a on a.id = am.alternative_id
                        JOIN question q on q.id = a.question_id
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
                        GROUP BY edq.question_id
                    ), tbl_active_ballot_questions AS (
                        SELECT
                            mbq.id AS mbq_id,
                            mbq.week_type_material_id,
                            mbq.course_id,
                            mbq.topic_id,
                            mbq.subtopic_id,
                            mbq.level_id,
                            mbq.type,
                            COALESCE(mbq.position, 0) AS position,
                            COALESCE(mbq.absolute_position, 0) AS absolute_position,
                            q.id AS question_id,
                            q.code,
                            q.description AS description_question,
                            q.answer_id,
                            q.parent_id,
                            q.config_alternative_id,
                            q.columns,
                            q.status
                        FROM materials.material_ballot_question mbq
                        JOIN questions.question q ON q.id = mbq.question_id AND q.fl_status IS TRUE
                        WHERE mbq.fl_status IS TRUE AND mbq.deleted_at IS NULL

                        UNION ALL

                        SELECT
                            mbq.id AS mbq_id,
                            mbq.week_type_material_id,
                            mbq.course_id,
                            mbq.topic_id,
                            mbq.subtopic_id,
                            mbq.level_id,
                            'T' AS type,
                            COALESCE(mbq.position, 0) AS position,
                            COALESCE(mbq.absolute_position, 0) AS absolute_position,
                            subq.id AS question_id,
                            subq.code,
                            subq.description AS description_question,
                            subq.answer_id,
                            subq.parent_id,
                            subq.config_alternative_id,
                            subq.columns,
                            subq.status
                        FROM materials.material_ballot_question mbq
                        JOIN materials.material_ballot_subquestions mbs ON mbs.material_ballot_question_id = mbq.id AND mbs.fl_status IS TRUE AND mbs.deleted_at IS NULL
                        JOIN questions.question subq ON subq.id = mbs.question_id AND subq.fl_status IS TRUE
                        WHERE mbq.fl_status IS TRUE AND mbq.deleted_at IS NULL
                    ), tbl_questions_material AS (
                        SELECT
                            abq.mbq_id AS id,
                            dwt.type_material_id,
                            tm.description AS type_material,
                            course_ordering.position AS order_course,
                            dwt.parent_type_material_id,
                            c.area_id,
                            a.description AS area,
                            abq.course_id,
                            c.name AS course,
                            abq.topic_id,
                            t.code as topic_code,
                            t.name AS topic,
                            abq.subtopic_id::smallint,
                            s.code AS subtopic_code,
                            s.name AS subtopic,
                            abq.level_id,
                            l.name as level,
                            abq.type,
                            abq.question_id,
                            abq.code,
                            abq.description_question,
                            abq.answer_id,
                            abq.parent_id,
                            abq.config_alternative_id,
                            ca.columns,
                            ca.styles,
                            mcc.column_count AS column_count_topic,
                            mcc.column_width AS column_width_topic,
                            mcc.column_spacing AS column_spacing_topic,
                            mcc.layout_format AS layout_format_topic,
                            mcc.number_format AS number_format_topic,
                            ca.fl_image AS fl_image_conf_alter,
                            td.diagrammed::JSON,
                            tdi.diagrammed_images::JSON,
                            qi.images::JSON,
                            CASE
                                WHEN count(al.id) > 0 THEN json_agg(
                                    json_build_object(
                                        'id', al.id,
                                        'question_id', al.question_id,
                                        'description', al.description
                                    ) ORDER BY al.id
                                )
                                ELSE '[]'::json
                            END AS alternatives,
                            tqma.question_maths::JSON,
                            tam.alternative_maths::JSON,
                            tdm.didi_maths::JSON,
                            abq.columns AS column_question,
                            abq.position::smallint AS position_question,
                            abq.absolute_position::smallint AS absolute_position,
                            abq.status,
                            CASE
                                WHEN count(oqu.id) > 0 THEN jsonb_agg(DISTINCT jsonb_build_object(
                                        'id', oqu.id,
                                        'year', oqu.year,
                                        'region_id', oqu.region_id,
                                        'region', oqu.region,
                                        'university_id', oqu.university_id,
                                        'university', oqu.university,
                                        'university_slug', oqu.university_slug,
                                        'option_id', oqu.option_id,
                                        'option', oqu.option,
                                        'modality_id', oqu.modality_id,
                                        'modality', oqu.modality,
                                        'areas', oqu.areas,
                                        'version', fn_number_to_roman(oqu.version),
                                        'order_version', oqu.order_version
                                    )
                                )
                                ELSE '[]'::JSONB
                            END AS origin
                        FROM detail_week_type_mat dwt
                        INNER JOIN material m ON dwt.material_id = m.id
                        JOIN tbl_active_ballot_questions abq ON abq.week_type_material_id = dwt.id
                        INNER JOIN course c ON abq.course_id = c.id
                        INNER JOIN topic t ON abq.topic_id = t.id
                        INNER JOIN subtopic s ON abq.subtopic_id = s.id
                        INNER JOIN level l ON abq.level_id = l.id
                        INNER JOIN type_material tm ON dwt.type_material_id = tm.id
                        INNER JOIN configuration_alternative ca ON abq.config_alternative_id = ca.id
                        INNER JOIN area a ON c.area_id = a.id
                        LEFT JOIN material_column_configurations mcc ON abq.topic_id = mcc.topic_id
                        LEFT JOIN tbl_question_math tqma ON tqma.question_id = abq.question_id
                        LEFT JOIN tbl_alternative_maths tam ON tam.question_id = abq.question_id
                        LEFT JOIN tbl_didi_maths tdm ON tdm.question_id = abq.question_id
                        LEFT JOIN (
                            SELECT
                                ttmco.course_id,
                                tm.id AS type_material_id,
                                ttmco.position
                            FROM template_type_material_courses_order ttmco
                            INNER JOIN type_material tm
                                ON tm.type_material_template_id = ttmco.template_type_material_id
                            WHERE ttmco.university_id IS NULL
                        ) AS course_ordering
                        ON course_ordering.type_material_id = COALESCE(dwt.parent_type_material_id, dwt.type_material_id)
                        AND course_ordering.course_id = abq.course_id
                        -- images
                        LEFT JOIN alternative al ON abq.question_id = al.question_id
                        LEFT JOIN tbl_diagrammed td ON abq.question_id = td.question_id
                        LEFT JOIN tbl_diagrammed_image tdi ON abq.question_id = tdi.question_id
                        LEFT JOIN tbl_question_image qi ON abq.question_id = qi.question_id
                        LEFT JOIN (
                            SELECT DISTINCT
                                oq.id,
                                oq.question_id,
                                oq.year,
                                oq.region_id,
                                r.name AS region,
                                oq.university_id,
                                ou.name AS university,
                                ou.slug AS university_slug,
                                oq.option_id,
                                o.name AS option,
                                oq.modality_id,
                                m.name AS modality,
                                oq.areas,
                                oq.version,
                                tv.order AS order_version
                            FROM origin_question oq
                            LEFT JOIN region r ON oq.region_id = r.id
                            LEFT JOIN origin_university ou ON oq.university_id = ou.id
                            LEFT JOIN option o ON oq.option_id = o.id
                            LEFT JOIN modality m ON oq.modality_id = m.id
                            LEFT JOIN tlb_versions tv ON ou.id = tv.university_id
                                AND oq.version = tv.version
                            WHERE oq.fl_status = TRUE
                            ORDER BY oq.university_id, oq.question_id, oq.year DESC, tv.order ASC
                        ) oqu ON abq.question_id = oqu.question_id
                            AND m.university_id = oqu.university_id
                        WHERE 1 = 1
                        AND abq.week_type_material_id = ANY(SELECT jsonb_array_elements_text(p_week_type_materials)::BIGINT)
                        AND abq.course_id = p_course_id
                        GROUP BY abq.mbq_id,
                            abq.level_id,
                            abq.type,
                            abq.question_id,
                            abq.course_id,
                            abq.topic_id,
                            abq.subtopic_id,
                            dwt.type_material_id,
                            dwt.parent_type_material_id,
                            course_ordering.position,
                            tm.description,
                            c.area_id,
                            c.name,
                            a.description,
                            t.name,
                            t.code,
                            s.name,
                            s.code,
                            l.name,
                            abq.code,
                            abq.description_question,
                            abq.answer_id,
                            abq.parent_id,
                            abq.config_alternative_id,
                            ca.columns,
                            ca.styles,
                            ca.fl_image,
                            mcc.column_count,
                            mcc.column_width,
                            mcc.column_spacing,
                            mcc.layout_format,
                            mcc.number_format,
                            td.diagrammed,
                            tdi.diagrammed_images,
                            qi.images,
                            tdm.didi_maths,
                            tqma.question_maths,
                            tam.alternative_maths,
                            abq.columns,
                            abq.position,
                            abq.absolute_position,
                            abq.status
                    )
                    SELECT tqm.* FROM tbl_questions_material tqm
                    ORDER BY
                        tqm.course,
                        tqm.area,
                        tqm.type_material_id,
                        tqm.absolute_position,
                        tqm.topic_code,
                        tqm.position_question,
                        tqm.subtopic_code,
                        tqm.level,
                        tqm.parent_id,
                        tqm.type,
                        tqm.question_id;
                END;
                $$;


ALTER FUNCTION questions.fn_question_material_class_pdf(p_week_type_materials jsonb, p_course_id smallint) OWNER TO postgres;

--

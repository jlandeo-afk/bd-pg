-- Function: exams.fn_get_report_missing_question_exam(bigint, smallint, smallint)

--

CREATE FUNCTION exams.fn_get_report_missing_question_exam(p_material_id bigint, p_type_material_id smallint, p_week smallint) RETURNS TABLE(material_id bigint, type_material character varying, url_excel character varying, missing jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                dwtm.id,
                tm.description AS type_material,
                NULL::VARCHAR AS url_excel_exam,
                jsonb_agg(
                    jsonb_build_object(
                        'area_id', meaw.area_id,
                        'data_incomplete_questions', meaw.data_incomplete_questions
                    )
                ) AS missing
            FROM detail_week_type_mat dwtm
            JOIN type_material tm ON dwtm.type_material_id = tm.id
            JOIN material_exam_area_week meaw ON meaw.week_type_material_id = dwtm.id
                AND meaw.fl_status = true
            WHERE dwtm.material_id = p_material_id
                AND dwtm.type_material_id = p_type_material_id
                AND dwtm.week = p_week
                AND dwtm.fl_status = true
            GROUP BY dwtm.id,
                tm.description;
        END;
        $$;


ALTER FUNCTION exams.fn_get_report_missing_question_exam(p_material_id bigint, p_type_material_id smallint, p_week smallint) OWNER TO postgres;

--

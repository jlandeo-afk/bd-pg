-- Function: materials.fn_get_material_incomplete_questions(bigint, smallint, jsonb)

--

CREATE FUNCTION materials.fn_get_material_incomplete_questions(p_material_id bigint, p_week smallint, p_type_material_ids jsonb) RETURNS TABLE(type_material_id bigint, type_material character varying, message text, issues character varying, missing_course_config character varying, missing_config_message character varying, missing_course_text json)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                dwtm.type_material_id::BIGINT AS type_material_id,
                tm.description AS type_material,
                'Faltan preguntas para el tipo de material '  || tm.description AS message, 
                dwtm.data_incomplete_questions AS issues,
                dwtm.data_missing_course_config  as missing_course_config,
                dwtm.missing_config_message  as missing_config_message,
				dwtm.data_missing_text as missing_course_text
            FROM academic.detail_week_type_mat dwtm
            LEFT JOIN materials.type_material tm ON dwtm.type_material_id = tm.id
            WHERE 1 = 1
              AND dwtm.material_id = p_material_id
              AND dwtm.week = p_week
              AND dwtm.type_material_id IN ( SELECT JSONB_ARRAY_ELEMENTS_TEXT(p_type_material_ids::JSONB)::INT )
              -- AND (dwtm.fl_complete_questions IS FALSE OR dwtm.missing_config_message IS NULL)
              AND dwtm.fl_status IS TRUE
              AND dwtm.deleted_at IS NULL;
        END;
        $$;


ALTER FUNCTION materials.fn_get_material_incomplete_questions(p_material_id bigint, p_week smallint, p_type_material_ids jsonb) OWNER TO postgres;

--

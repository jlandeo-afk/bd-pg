-- Function: odiseo.fn_amount_parent_question_level(bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION odiseo.fn_amount_parent_question_level(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) RETURNS TABLE(number_of_passages integer, level_id bigint, level_name character varying, description character varying, course_id bigint)
    LANGUAGE plpgsql
    AS $$
	DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
            v_headquarte_id BIGINT;
	BEGIN
		SELECT m.cycle_id, m.university_id, m.headquarte_id
		INTO v_cycle_id, v_university_id, v_headquarte_id 
		FROM odiseo.material m WHERE m.id = p_material_id LIMIT 1;

		RETURN QUERY
		SELECT 
			dlswp.number_of_passages,
			dlswp.level_id,
			l."name" level_name,
			l.description,
			ls.course_id
		FROM detail_level_syllabus_weeks_parents dlswp 
		JOIN level_syllabus_weeks lsw ON lsw.id = dlswp.level_syllabus_weeks_id
		JOIN level_syllabus ls on ls.id = lsw.level_syllabus_id
		JOIN "level" l ON l.id = dlswp.level_id
		WHERE dlswp.fl_status = TRUE
		AND dlswp.type_material_id = p_type_material_id
		AND ls.fl_status = TRUE
		AND ls.headquarter_id = v_headquarte_id
		AND ls.cycle_id = v_cycle_id
        AND ls.university_id = v_university_id
		AND ls.course_id IN (SELECT JSONB_ARRAY_ELEMENTS_TEXT(p_courses)::SMALLINT)
		AND lsw.week = p_week;

	END;
$$;


ALTER FUNCTION odiseo.fn_amount_parent_question_level(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) OWNER TO postgres;

--

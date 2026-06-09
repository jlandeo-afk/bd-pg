-- Function: questions.fn_question_configuration_comparison(bigint, bigint)

--

CREATE FUNCTION questions.fn_question_configuration_comparison(p_syllabus_id bigint, p_company_id bigint) RETURNS TABLE(syllabus_id bigint, course_amount_question integer, course_id smallint, course_name character varying, type_material_id smallint, type_material character varying, week_number smallint, amount_used integer, type text, status text, cycle_description character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cycle_id int;
    v_university_id int;
    v_company_id int;
BEGIN
    SELECT 
        sy.cycle_id,
        sy.university_id,
        sy.company_id
    INTO v_cycle_id, v_university_id, v_company_id
    FROM syllabus sy
    WHERE sy.id = p_syllabus_id;

    RETURN QUERY
    SELECT 
        fgmc.syllabus_id, 
        fgmc.expected_amount course_amount_question, 
        fgmc.course_id,
        fgmc.course_name,
        fgmc.type_material_id,
        fgmc.type_material_name type_material,
        fgmc.week_number,
        fgmc.syllabus_actual_amount amount_used,
        fgmc.record_type type,
        CASE
            WHEN fgmc.has_configuration IS FALSE THEN 'not_configurable'
            WHEN fgmc.has_syllabus_configuration IS FALSE THEN 'empty'
            WHEN fgmc.has_syllabus_mismatch IS TRUE THEN 'inconsistent'
            WHEN fgmc.has_syllabus_mismatch IS FALSE THEN 'complete'
        END status,
        fgmc.cycle_description
    FROM fn_get_material_configuration_inconsistencies(null, v_cycle_id, v_university_id, v_company_id) fgmc
    WHERE fgmc.syllabus_id = p_syllabus_id
    ORDER BY fgmc.week_number;
END;
$$;


ALTER FUNCTION questions.fn_question_configuration_comparison(p_syllabus_id bigint, p_company_id bigint) OWNER TO postgres;

--

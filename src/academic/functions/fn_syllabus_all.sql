-- Function: academic.fn_syllabus_all(smallint, smallint, bigint, smallint, bigint)

--

CREATE FUNCTION academic.fn_syllabus_all(f_university_id smallint, f_course_id smallint, f_cycle_id bigint, f_type_material_id smallint, p_company_id bigint) RETURNS TABLE(id bigint, university_id smallint, university character varying, course_id bigint, course character varying, cycle_id bigint, cycle character varying)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        SELECT DISTINCT
            s.id, s.university_id, u.name AS university,
            s.course_id, co.name AS course,
            s.cycle_id, cy.description AS cycle
        FROM syllabus s
        INNER JOIN origin_university u ON s.university_id = u.id
        INNER JOIN course co ON s.course_id = co.id
        INNER JOIN cycle cy ON s.cycle_id = cy.id
        LEFT JOIN syllabus_topic st ON s.id = st.syllabus_id AND st.fl_status = true
        LEFT JOIN syllabus_topic_week tw ON st.id = tw.syllabus_topic_id AND tw.fl_status = true
        LEFT JOIN syllabus_detail_subtopic ds ON tw.id = ds.syllabus_topic_week_id AND ds.fl_status = true
        LEFT JOIN syllabus_subtopic_type_material stm ON ds.id = stm.syllabus_detail_subtopic_id AND stm.fl_status = true
        WHERE u.deleted_by IS NULL
        AND u.fl_active = true
        AND (f_university_id IS NULL OR s.university_id = f_university_id)
        AND (f_course_id IS NULL OR s.course_id = f_course_id)
        AND (f_cycle_id IS NULL OR s.cycle_id = f_cycle_id)
        AND (f_type_material_id IS NULL OR stm.type_material_id = f_type_material_id)
        AND s.company_id = p_company_id
        ORDER BY s.university_id ASC;
    END;
    $$;


ALTER FUNCTION academic.fn_syllabus_all(f_university_id smallint, f_course_id smallint, f_cycle_id bigint, f_type_material_id smallint, p_company_id bigint) OWNER TO postgres;

--

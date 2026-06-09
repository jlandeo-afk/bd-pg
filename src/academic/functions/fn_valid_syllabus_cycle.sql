-- Function: academic.fn_valid_syllabus_cycle(smallint, bigint, bigint, bigint, bigint)

--

CREATE FUNCTION academic.fn_valid_syllabus_cycle(f_university_id smallint, f_cycle_id bigint, f_course_id bigint, f_pseudo_course_id bigint, p_company_id bigint) RETURNS TABLE(error_message text)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            IF EXISTS (
                SELECT 1 FROM syllabus s
                WHERE s.university_id = f_university_id
                    AND (f_pseudo_course_id IS NULL OR s.pseudo_course_id = f_pseudo_course_id)
                    AND (f_course_id IS NULL OR s.course_id = f_course_id)
                    AND s.company_id = p_company_id
                    AND s.cycle_id = f_cycle_id
                    AND s.fl_status = true
            ) THEN
                RETURN QUERY SELECT 'Ya existe el syllabus para este ciclo, curso y universidad.'::TEXT;
            ELSE
                RETURN QUERY SELECT NULL::TEXT;
            END IF;
        END;
        $$;


ALTER FUNCTION academic.fn_valid_syllabus_cycle(f_university_id smallint, f_cycle_id bigint, f_course_id bigint, f_pseudo_course_id bigint, p_company_id bigint) OWNER TO postgres;

--

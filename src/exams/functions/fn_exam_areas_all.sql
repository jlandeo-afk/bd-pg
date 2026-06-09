-- Function: exams.fn_exam_areas_all()

--

CREATE FUNCTION exams.fn_exam_areas_all() RETURNS SETOF exams.exam_area
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY SELECT * FROM exams.exam_area WHERE fl_status = true;
            END;
            $$;


ALTER FUNCTION exams.fn_exam_areas_all() OWNER TO postgres;

--

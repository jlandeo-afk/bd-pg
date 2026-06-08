-- Function: odiseo.fn_exam_areas_all()

--

CREATE FUNCTION odiseo.fn_exam_areas_all() RETURNS SETOF odiseo.exam_area
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY SELECT * FROM odiseo.exam_area WHERE fl_status = true;
            END;
            $$;


ALTER FUNCTION odiseo.fn_exam_areas_all() OWNER TO postgres;

--

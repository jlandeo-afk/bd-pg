-- Function: academic.fn_search_modality_option(character varying, integer, integer)

--

CREATE FUNCTION academic.fn_search_modality_option(p_name character varying, p_option_id integer, p_university integer) RETURNS TABLE(id smallint, name character varying, type integer[], fl_status boolean, created_by bigint, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    m.id,
                    m.name,
                    m.option_ids,
                    m.fl_status,
                    m.created_by,
                    m.created_at
                FROM
                    academic.modality m
                WHERE
                    unaccent(lower(m.name)) = unaccent(lower(p_name))
                    AND p_option_id = ANY(m.option_ids)
                    AND (p_university IS NULL OR p_university = ANY(m.university_ids));
            END;
            $$;


ALTER FUNCTION academic.fn_search_modality_option(p_name character varying, p_option_id integer, p_university integer) OWNER TO postgres;

--

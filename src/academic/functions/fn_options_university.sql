-- Function: academic.fn_options_university(integer)

--

CREATE FUNCTION academic.fn_options_university(p_university integer) RETURNS TABLE(id integer, name character varying, university_ids integer[])
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    ou.id::INT,
                    ou.name::VARCHAR,
                    ARRAY[ou.university_id]::INT[] AS university_ids
                FROM option_university ou
                WHERE ou.deleted_at IS NULL
                  AND (p_university IS NULL OR ou.university_id = p_university)
                ORDER BY ou.id ASC;
            END;
            $$;


ALTER FUNCTION academic.fn_options_university(p_university integer) OWNER TO postgres;

--

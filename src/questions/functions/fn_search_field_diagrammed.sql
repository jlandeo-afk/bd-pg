-- Function: questions.fn_search_field_diagrammed(integer, integer, character varying)

--

CREATE FUNCTION questions.fn_search_field_diagrammed(p_perpage integer, p_npage integer, p_name_text character varying) RETURNS TABLE(id bigint, name character varying, created_by bigint, created_at timestamp without time zone, total_count bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
            BEGIN
                -- Calculate the offset
                offset_val := p_perpage * (p_npage - 1);

                RETURN QUERY
                WITH tbl_field_diagrammed AS (
                    SELECT
                    fd.id,
                    fd.name,
                    fd.created_by,
                    fd.created_at
                    from questions.field_diagrammed fd
                    WHERE fd.fl_status = TRUE
                    AND fd.deleted_at IS NULL
                    AND (p_name_text IS NULL
                        OR unaccent(LOWER(fd.name)) LIKE '%' || unaccent(LOWER(p_name_text)) || '%'
                    )
                )
                SELECT *, count(*) OVER () AS total_count
                FROM tbl_field_diagrammed
                ORDER BY name ASC, id ASC, created_at DESC
                LIMIT p_perpage
                OFFSET offset_val;
            END;
            $$;


ALTER FUNCTION questions.fn_search_field_diagrammed(p_perpage integer, p_npage integer, p_name_text character varying) OWNER TO postgres;

--

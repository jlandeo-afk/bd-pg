-- Function: questions.fn_search_configuration_alternative(integer, integer, character varying)

--

CREATE FUNCTION questions.fn_search_configuration_alternative(p_perpage integer, p_npage integer, p_search character varying) RETURNS TABLE(id bigint, name character varying, columns smallint, styles text, fl_image boolean, fl_default boolean, fl_status boolean, created_by bigint, updated_by bigint, deleted_by bigint, created_at timestamp without time zone, updated_at timestamp without time zone, deleted_at timestamp without time zone, total integer)
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    total_count INTEGER;
                    offset_val INTEGER;
                BEGIN
                    offset_val := p_perpage * (p_npage - 1);

                    SELECT COUNT(*)
                    INTO total_count
                    FROM questions.configuration_alternative altern
                    WHERE altern.fl_status = true
                    AND (p_search IS NULL OR (LOWER(altern.name) LIKE '%' || LOWER(p_search) || '%'));

                    RETURN QUERY
                    SELECT
                        altern.id,
                        altern.name,
                        altern.columns,
                        altern.styles,
                        altern.fl_image,
                        altern.fl_default,
                        altern.fl_status,
                        altern.created_by,
                        altern.updated_by,
                        altern.deleted_by,
                        altern.created_at,
                        altern.updated_at,
                        altern.deleted_at,
                        total_count AS total
                    FROM questions.configuration_alternative altern
                    WHERE altern.fl_status = true
                    AND (p_search IS NULL OR (LOWER(altern.name) LIKE '%' || LOWER(p_search) || '%'))
                    ORDER BY altern.created_at DESC
                    LIMIT p_perpage
                    OFFSET offset_val;
                END;
            $$;


ALTER FUNCTION questions.fn_search_configuration_alternative(p_perpage integer, p_npage integer, p_search character varying) OWNER TO postgres;

--

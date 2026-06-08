-- Function: odiseo.fn_rebuild_parent_search_text(bigint)

--

CREATE FUNCTION odiseo.fn_rebuild_parent_search_text(v_parent_id bigint) RETURNS void
    LANGUAGE plpgsql
    SET search_path TO 'odiseo', 'public'
    AS $$
                    DECLARE
                        v_new_search_text TEXT;
                    BEGIN
                        SELECT 
                            COALESCE(pq_alias.code, '') || ' ' || 
                            COALESCE(pq_alias.number_question, '') || ' ' || 
                            COALESCE(pq_alias.short_description, '') || ' ' ||
                            STRING_AGG(COALESCE(sub.search_text, ''), ' ')
                        INTO
                            v_new_search_text
                        FROM parent_question pq_alias
                        LEFT JOIN question sub ON pq_alias.id = sub.parent_id
                        WHERE pq_alias.id = v_parent_id
                        GROUP BY pq_alias.id;

                        UPDATE parent_question pq
                        SET 
                            search_text = v_new_search_text
                        WHERE 
                            pq.id = v_parent_id
                            AND COALESCE(pq.search_text, '') <> COALESCE(v_new_search_text, '');

                    END;
                    $$;


ALTER FUNCTION odiseo.fn_rebuild_parent_search_text(v_parent_id bigint) OWNER TO postgres;

--

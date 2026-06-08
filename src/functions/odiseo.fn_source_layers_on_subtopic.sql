-- Function: odiseo.fn_source_layers_on_subtopic(integer, integer, integer, integer)

--

CREATE FUNCTION odiseo.fn_source_layers_on_subtopic(p_perpage integer, p_n_page integer, p_university_id integer, p_subtopic_id integer) RETURNS TABLE(year character varying, option_name character varying, area_name text, total bigint)
    LANGUAGE plpgsql
    AS $$
                                DECLARE
                                    total_count INTEGER;
                                    offset_val INTEGER;
                                BEGIN
                                    offset_val := p_perpage * (p_n_page - 1);
                        
                                    RETURN QUERY
                                        WITH source_layers_list AS (
                                            SELECT 
                                                oq."year",
                                                o.name AS option_name,
                                                array_to_string(
                                                    ARRAY(
                                                        SELECT json_array_elements_text(oq.areas::json)
                                                    ),
                                                    ' - '
                                                ) AS area_name
                                            FROM origin_question oq 
                                            JOIN question q ON q.id = oq.question_id
                                            JOIN question_subtopic qs ON qs.question_id = q.id AND qs.fl_status = true
                                            JOIN subtopic s ON s.id = qs.subtopic_id
                                            JOIN modality_options m ON m.id = oq.modality_option_id
                                            JOIN option_university o ON o.id = m.option_university_id 
                                            WHERE oq.fl_status = true
                                            AND s.id = p_subtopic_id
                                            AND o.university_id = p_university_id
                                            ORDER BY s.id
                                        ), counted_source_layers_list AS (
                                            SELECT
                                                *,
                                                COUNT(*) OVER () AS total
                                            FROM source_layers_list
                                        )
                                        SELECT
                                            *
                                        FROM counted_source_layers_list
                                        LIMIT p_perpage OFFSET offset_val;
                                END;
                            $$;


ALTER FUNCTION odiseo.fn_source_layers_on_subtopic(p_perpage integer, p_n_page integer, p_university_id integer, p_subtopic_id integer) OWNER TO postgres;

--

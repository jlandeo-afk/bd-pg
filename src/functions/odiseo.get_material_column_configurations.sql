-- Function: odiseo.get_material_column_configurations(integer, integer, integer)

--

CREATE FUNCTION odiseo.get_material_column_configurations(p_perpage integer, p_npage integer, f_course_id integer) RETURNS TABLE(course_id smallint, name_course character varying, topics jsonb, total_count bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
            BEGIN
                -- Calcular el offset
                offset_val := p_perpage * (p_npage - 1);

                RETURN QUERY
                WITH filtered_configurations AS (
                    SELECT 
                        c.id AS course_id,
                        CONCAT(c.code, ' - ' , c.name)::VARCHAR AS name_course,
                        jsonb_agg(
                            jsonb_build_object(
                                'topic_id', t.id,
                                'material_id', mcc.id,  -- Cambiado de 'id' a 'material_id'
                                'topic_name', t.name,
                                'column', COALESCE(mcc.column_count, 2)
                            )
                        ) AS topics
                    FROM 
                        odiseo.course c
                    INNER JOIN 
                        odiseo.topic t 
                    ON 
                        t.course_id = c.id
                    LEFT JOIN 
                        odiseo.material_column_configurations mcc 
                    ON 
                        mcc.topic_id = t.id
                    WHERE
                        c.fl_status = true
                        AND (f_course_id IS NULL OR c.id = f_course_id)
                    GROUP BY 
                        c.id, c.name
                    ORDER BY c.code ASC, unaccent(c.name) ASC
                ),
                counted_questions AS (
                    SELECT *, count(*) OVER () AS total_count
                    FROM filtered_configurations
                )
                SELECT *
                FROM counted_questions
                LIMIT p_perpage
                OFFSET offset_val;
            END;
            $$;


ALTER FUNCTION odiseo.get_material_column_configurations(p_perpage integer, p_npage integer, f_course_id integer) OWNER TO postgres;

--

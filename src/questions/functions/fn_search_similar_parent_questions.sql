-- Function: questions.fn_search_similar_parent_questions(text, bigint)

--

CREATE FUNCTION questions.fn_search_similar_parent_questions(p_search text, p_course_id bigint) RETURNS TABLE(id bigint, short_description text, score real, code character varying)
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_umbral_final FLOAT;
                    BEGIN
                        SELECT ase.similarity_percentage::float / 100.0 INTO v_umbral_final 
                        FROM advanced_settings ase 
                        WHERE ase.company_id = 1
                        LIMIT 1;

                        v_umbral_final := GREATEST(0.0, LEAST(1.0, v_umbral_final));

                        EXECUTE format('SET LOCAL pg_trgm.similarity_threshold = %L', v_umbral_final);

                        RETURN QUERY
                        SELECT 
                            pq.id,
                            pq.short_description,
                            extensions.similarity(
                                lower(fn_immutable_unaccent(pq.short_description)), 
                                lower(fn_immutable_unaccent(p_search))
                            ) AS score,
                            pq.code
                        FROM parent_question pq
                        WHERE 
                            pq.course_id = p_course_id AND
                            lower(fn_immutable_unaccent(pq.short_description)) OPERATOR(extensions.%) lower(fn_immutable_unaccent(p_search))
                        ORDER BY score DESC;
                    END;
                    $$;


ALTER FUNCTION questions.fn_search_similar_parent_questions(p_search text, p_course_id bigint) OWNER TO postgres;

--

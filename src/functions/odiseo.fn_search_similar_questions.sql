-- Function: odiseo.fn_search_similar_questions(text, bigint)

--

CREATE FUNCTION odiseo.fn_search_similar_questions(p_search text, p_course_id bigint) RETURNS TABLE(id bigint, short_description text, score real, code character varying)
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
                                        q.id,
                                        q.short_description,
                                        extensions.similarity(
                                            lower(fn_immutable_unaccent(q.short_description)), 
                                            lower(fn_immutable_unaccent(p_search))
                                        ) AS score,
                                        q.code
                                    FROM question q
                                    WHERE
                                        q.course_id = p_course_id AND
                                        lower(fn_immutable_unaccent(q.short_description)) OPERATOR(extensions.%) lower(fn_immutable_unaccent(p_search)) AND
                                        q.parent_id IS NULL AND
                                        q.status NOT IN ('ARCH')
                                    ORDER BY score DESC;
                                END;
                                $$;


ALTER FUNCTION odiseo.fn_search_similar_questions(p_search text, p_course_id bigint) OWNER TO postgres;

--

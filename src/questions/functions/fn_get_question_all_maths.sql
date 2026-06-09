-- Function: questions.fn_get_question_all_maths(bigint)

--

CREATE FUNCTION questions.fn_get_question_all_maths(p_question_id bigint) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                result jsonb;
            BEGIN
                SELECT jsonb_agg(obj)
                INTO result
                FROM (
                    -- formulas de alternative_maths
                    SELECT jsonb_build_object(
                            'id', am.id,
                            'path', am.path,
                            'properties', am.properties
                        ) AS obj
                    FROM alternative_maths am
                    JOIN alternative a ON a.id = am.alternative_id
                    WHERE a.question_id = p_question_id
                    AND am.fl_status = true

                    UNION ALL

                    -- formulas de didi_maths
                    SELECT jsonb_build_object(
                            'id', dm.id,
                            'path', dm.path,
                            'properties', dm.properties
                        ) AS obj
                    FROM didi_maths dm
                    JOIN employee_didi_question_field edqf ON edqf.id = dm.didi_question_id AND edqf.math_migration_status NOT IN ('TO_BE_MIGRATED', 'MIGRATING')
                    JOIN employee_didi_question edq ON edq.id = edqf.employee_didi_question_id
                    WHERE edq.question_id = p_question_id
                    AND dm.fl_status = true

                    UNION ALL

                    -- formulas de question_maths
                    SELECT jsonb_build_object(
                            'id', qm.id,
                            'path', qm.path,
                            'properties', qm.properties
                        ) AS obj
                    FROM question_maths qm
                    WHERE qm.question_id = p_question_id
                    AND qm.fl_status = true
                ) t;

                RETURN COALESCE(result, '[]'::jsonb);
            END;
        $$;


ALTER FUNCTION questions.fn_get_question_all_maths(p_question_id bigint) OWNER TO postgres;

--

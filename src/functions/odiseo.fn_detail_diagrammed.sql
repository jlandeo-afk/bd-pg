-- Function: odiseo.fn_detail_diagrammed(bigint)

--

CREATE FUNCTION odiseo.fn_detail_diagrammed(p_id bigint) RETURNS TABLE(id bigint, employee_id bigint, question_id bigint, theory_base text, data_unknown text, development text, answer text, images jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    dq.id,
                    dq.employee_id,
                    dq.question_id,
                    dq.theory_base,
                    dq.data_unknown,
                    dq."development ",
                    dq.answer,
                    COALESCE(
                        jsonb_agg(
                            CASE
                                WHEN edq.id IS NOT NULL THEN json_build_object(
                                    'id', edq.id,
                                    'code', edq.code,
                                    'image', edq.image,
                                    'fl_status', edq.fl_status
                                )
                                ELSE NULL
                            END
                        ) FILTER (WHERE edq.id IS NOT NULL),
                        '[]'::jsonb
                    ) AS images
                FROM odiseo.employee_didi_question dq
				LEFT JOIN odiseo.employee_didi_question_image edq ON dq.id = edq.employee_didi_question_id AND edq.fl_status = true
                WHERE dq.question_id = p_id
                AND dq.fl_status = true
				GROUP BY dq.id, dq.employee_id, dq.question_id, dq.theory_base, dq.data_unknown, dq."development ", dq.answer;
            END;
            $$;


ALTER FUNCTION odiseo.fn_detail_diagrammed(p_id bigint) OWNER TO postgres;

--

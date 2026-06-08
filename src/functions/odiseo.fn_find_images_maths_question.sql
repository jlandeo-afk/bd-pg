-- Function: odiseo.fn_find_images_maths_question(integer)

--

CREATE FUNCTION odiseo.fn_find_images_maths_question(p_question_id integer) RETURNS TABLE(question_id bigint, question_maths json, alternative_maths json, didi_maths json, column_question smallint)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH tbl_question_math AS (
                    SELECT 
                        qm.question_id,
                        jsonb_agg(json_build_object(
                            'id', qm.id,
                            'code', qm.code,
                            'path', qm.path,
                            'properties', qm.properties
                        ))::TEXT AS question_maths
                    FROM odiseo.question_maths qm 
                    JOIN odiseo.question q ON q.id = qm.question_id
                    WHERE 1 = 1
                    AND q.fl_status = TRUE 
                    AND q.id = p_question_id
                    AND qm.fl_status = TRUE
                    GROUP BY qm.question_id
                ), tbl_alternative_maths AS (
                    SELECT 
                        a.question_id,
                        jsonb_agg(json_build_object(
                            'id', am.id,
                            'code', am.code,
                            'path', am.path,
                            'properties', am.properties
                        ))::TEXT AS alternative_maths
                    FROM odiseo.alternative_maths am 
                    JOIN odiseo.alternative a on a.id = am.alternative_id 
                    JOIN odiseo.question q on q.id = a.question_id 
                    WHERE q.id = p_question_id
                    GROUP BY a.question_id
                ), tbl_didi_maths AS (
                    SELECT
                        edq.question_id,
                        jsonb_agg(json_build_object(
                            'id', dm.id,
                            'code', dm.code,
                            'path', dm.path,
                            'properties', dm.properties
                        ))::TEXT AS didi_maths
                    FROM odiseo.didi_maths dm 
                    LEFT JOIN odiseo.employee_didi_question_field edqf on edqf.id = dm.didi_question_id
                    LEFT JOIN odiseo.employee_didi_question edq on edq.id = edqf.employee_didi_question_id 
                    LEFT JOIN odiseo.question q on q.id = edq.question_id
                    WHERE q.id = p_question_id
                    GROUP BY edq.question_id
                ), tbl_question AS (
                    SELECT
                        q.id,
                        tqma.question_maths::JSON,
                        tam.alternative_maths::JSON,
                        tdm.didi_maths::JSON,
                        q.columns column_question
                    FROM odiseo.question q
                    LEFT JOIN tbl_question_math tqma ON tqma.question_id = q.id
                    LEFT JOIN tbl_alternative_maths tam ON tam.question_id = q.id
                    LEFT JOIN tbl_didi_maths tdm ON tdm.question_id = q.id
                    WHERE q.id = p_question_id
                )

                SELECT tq.* FROM tbl_question tq;
                END;
            $$;


ALTER FUNCTION odiseo.fn_find_images_maths_question(p_question_id integer) OWNER TO postgres;

--

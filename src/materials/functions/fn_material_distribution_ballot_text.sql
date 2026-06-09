-- Function: materials.fn_material_distribution_ballot_text(bigint, smallint, smallint, bigint)

--

CREATE FUNCTION materials.fn_material_distribution_ballot_text(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) RETURNS TABLE(id bigint, material_id bigint, week smallint, type_material_id smallint, week_type_material_id bigint, course_id smallint, code_course character varying, course character varying, "position" smallint, position_initial smallint, category_id bigint, category character varying, subcategory_id bigint, subcategory character varying, level_id bigint, level_description character varying, level_name character varying, usage_level_id bigint, question_id bigint, type character varying, usage_status boolean, subquestion jsonb, parent_question_id integer)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    SELECT
                        mdqb.id,
                        mdqb.material_id,
                        mdqb.week,
                        mdqb.type_material_id,
                        mdqb.week_type_material_id,
                        mdqb.course_id,
                        c.code AS course_code,
                        c.name AS course,
                        mdqb.position,
                        mdqb.position_initial,
                        tt.id category_id,
                        tt.name AS category,
                        tts.id AS subcategory_id,
                        tts.name AS subcategory,
                        mdqb.level_id,
                        l.description AS level_description,
                        l.name AS level_name,
                        mdqb.usage_level_id,
                        mdqb.question_id,
                        mdqb.type,
                        mdqb.usage_status,
                        (
                            SELECT JSONB_AGG(
                                JSONB_BUILD_OBJECT(
                                    'question_id', mbs.question_id,
                                    'position', mbs.position
                                ) ORDER BY mbs.position ASC
                            )
                            FROM material_ballot_subquestions mbs
                            WHERE mbs.material_ballot_question_id = mdqb.id
                              AND mbs.fl_status = TRUE
                        ) AS subquestion,
                        mdqb.parent_question_id
                    FROM material_ballot_question AS mdqb
                    JOIN course AS c ON mdqb.course_id = c.id
                    JOIN level AS l ON mdqb.level_id = l.id
                    JOIN type_text tt ON tt.id = mdqb.type_text_id
                    JOIN type_text_subcategories tts ON tts.id = mdqb.type_text_subcategory_id 
                    WHERE
                        mdqb.material_id = p_material_id
                        AND mdqb.week = p_week
                        AND mdqb.type_material_id = p_type_material_id
                        AND mdqb.week_type_material_id = p_week_type_material_id
                        AND mdqb.fl_status = true
                    ORDER BY mdqb.course_id ASC, mdqb.position ASC;
                END;
            $$;


ALTER FUNCTION materials.fn_material_distribution_ballot_text(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint) OWNER TO postgres;

--

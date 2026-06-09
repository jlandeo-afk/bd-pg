-- Function: questions.fn_amount_parent_question_category(bigint, smallint, smallint, jsonb)

--

CREATE FUNCTION questions.fn_amount_parent_question_category(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) RETURNS TABLE(category_id bigint, subcategory_id bigint, type_material_id smallint, course_id bigint, course_name character varying, material character varying, category character varying, subcategory character varying, topic_subquestions jsonb, position_initial bigint, position_text smallint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
            v_cycle_id BIGINT;
            v_university_id SMALLINT;
    BEGIN
    SELECT m.cycle_id, m.university_id INTO v_cycle_id, v_university_id
    FROM odiseo.material m WHERE m.id = p_material_id LIMIT 1;

    RETURN QUERY
    SELECT 
    tt.id AS category_id,
    tts.id AS subcategory_id,
    tm.id AS type_material_id,
    s.course_id,
    c."name" AS course_name,
    tm.description AS material,
    tt.name AS category,
    tts.name AS subcategory,
    (
        SELECT jsonb_agg(
            jsonb_build_object(
                'topic_id', t.id,
                'subtopic_id', stc.subtopic_id,
                'quantity', stc.quantity
            )
        ) AS topic_subquestions
        FROM syllabus_text_content stc
        JOIN subtopic sub ON sub.id = stc.subtopic_id
        JOIN topic t ON t.id = sub.topic_id
        WHERE stc.syllabus_text_id = st.id AND stc.fl_status = true
    ) AS topic_subquestions,
    (ROW_NUMBER() OVER (ORDER BY tt.position, tts.id) - 1) AS position_initial,
    tt.position position_text
    FROM syllabus s
    JOIN course c 
        ON c.id = s.course_id

    JOIN syllabus_text_weeks stw 
        ON stw.syllabus_id = s.id 
        AND stw.fl_status = true

    JOIN syllabus_text_distributions std 
        ON std.syllabus_text_week_id = stw.id 
        AND std.fl_status = true

    JOIN type_material tm 
        ON tm.id = std.type_material_id

    JOIN syllabus_texts st 
        ON st.syllabus_text_distribution_id = std.id 
        AND st.fl_status = true

    JOIN type_text tt 
        ON tt.id = st.type_text_id

    JOIN type_text_subcategories tts 
        ON tts.id = st.type_text_subcategory_id

    WHERE std.type_material_id = p_type_material_id
        AND s.university_id = v_university_id
        AND s.cycle_id = v_cycle_id
        AND stw.week = p_week
        AND s.course_id IN (
            SELECT jsonb_array_elements_text(p_courses)::BIGINT
        )
    ORDER BY tt.id, tts.id;

    END;
$$;


ALTER FUNCTION questions.fn_amount_parent_question_category(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_courses jsonb) OWNER TO postgres;

--

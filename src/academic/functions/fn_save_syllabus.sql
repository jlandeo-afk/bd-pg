-- Function: academic.fn_save_syllabus(smallint, smallint, smallint, bigint, jsonb, jsonb, bigint, bigint)

--

CREATE FUNCTION academic.fn_save_syllabus(p_university_id smallint, p_course_id smallint, p_pseudo_course_id smallint, p_cycle_id bigint, p_syllabus_week_titles jsonb, p_syllabus jsonb, p_created_by bigint, p_company_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus_id BIGINT;
            v_syllabus JSONB;
            v_syllabus_week_title JSONB;
            v_syllabus_topic_id BIGINT;
            v_weeks JSONB;
            v_syllabus_topic_week_id BIGINT;
            v_subtopics JSONB;
            v_syllabus_detail_subtopic_id BIGINT;
            v_type_materials JSONB;
            v_total_type_material_amount INT;
            v_total_questions_amount INT;

        BEGIN
            INSERT INTO syllabus (university_id, course_id, pseudo_course_id, cycle_id, created_by, created_at, company_id)
            VALUES (p_university_id, p_course_id, p_pseudo_course_id, p_cycle_id, p_created_by, now(), p_company_id)
            RETURNING id INTO v_syllabus_id;

            IF p_syllabus_week_titles IS NOT NULL OR jsonb_array_length(p_syllabus_week_titles) > 0 THEN
                FOR v_syllabus_week_title IN SELECT jsonb_array_elements(p_syllabus_week_titles) LOOP
                        INSERT INTO syllabus_week_titles (syllabus_id, week, title, created_by, created_at, company_id)
                        VALUES (v_syllabus_id, (v_syllabus_week_title->>'week_id')::SMALLINT, (v_syllabus_week_title->>'title'), p_created_by, now(), p_company_id);
                END LOOP;
            END IF;


            FOR v_syllabus IN SELECT jsonb_array_elements(p_syllabus) LOOP
                INSERT INTO syllabus_topic (syllabus_id, topic_id, created_by, created_at, company_id)
                VALUES (v_syllabus_id, (v_syllabus->>'topic_id')::SMALLINT, p_created_by, now(), p_company_id)
                RETURNING id INTO v_syllabus_topic_id;

                FOR v_weeks IN SELECT jsonb_array_elements(v_syllabus->'weeks') LOOP
                    IF jsonb_typeof(v_weeks->'subtopics') = 'array' AND jsonb_array_length(v_weeks->'subtopics') > 0 THEN
                        INSERT INTO syllabus_topic_week (syllabus_topic_id, week, created_by, created_at, company_id)
                        VALUES (v_syllabus_topic_id, (v_weeks->>'week_id')::SMALLINT, p_created_by, now(), p_company_id)
                        RETURNING id INTO v_syllabus_topic_week_id;

                        FOR v_subtopics IN SELECT jsonb_array_elements(v_weeks->'subtopics') LOOP
                            INSERT INTO syllabus_detail_subtopic (syllabus_topic_week_id, subtopic_id, questions_amount, created_by, created_at, company_id)
                            VALUES (v_syllabus_topic_week_id, (v_subtopics->>'id')::SMALLINT, 0, p_created_by, now(), p_company_id)
                            RETURNING id INTO v_syllabus_detail_subtopic_id;

                            FOR v_type_materials IN SELECT jsonb_array_elements(v_subtopics->'questions_amount') LOOP
                                INSERT INTO syllabus_subtopic_type_material (syllabus_detail_subtopic_id, type_material_id, questions_amount, created_by, created_at, company_id)
                                VALUES (v_syllabus_detail_subtopic_id, (v_type_materials->>'type_material_id')::SMALLINT, (v_type_materials->>'amount')::SMALLINT, p_created_by, now(), p_company_id);
                            END LOOP;

                            SELECT COALESCE(SUM(questions_amount), 0) INTO v_total_type_material_amount
                            FROM syllabus_subtopic_type_material
                            WHERE syllabus_detail_subtopic_id = v_syllabus_detail_subtopic_id AND fl_status = true AND company_id = p_company_id;

                            UPDATE syllabus_detail_subtopic SET questions_amount = v_total_type_material_amount WHERE id = v_syllabus_detail_subtopic_id;
                        END LOOP;

                        SELECT COALESCE(SUM(questions_amount), 0) INTO v_total_questions_amount FROM syllabus_detail_subtopic WHERE syllabus_topic_week_id = v_syllabus_topic_week_id AND fl_status = true AND company_id = p_company_id;

                        UPDATE syllabus_topic_week SET total_questions_amount = v_total_questions_amount WHERE id = v_syllabus_topic_week_id AND company_id = p_company_id;
                    END IF;
                END LOOP;
            END LOOP;

            RETURN v_syllabus_id;
        END;
    $$;


ALTER FUNCTION academic.fn_save_syllabus(p_university_id smallint, p_course_id smallint, p_pseudo_course_id smallint, p_cycle_id bigint, p_syllabus_week_titles jsonb, p_syllabus jsonb, p_created_by bigint, p_company_id bigint) OWNER TO postgres;

--

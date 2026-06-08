-- Function: odiseo.fn_save_syllabus_texts(smallint, smallint, smallint, bigint, jsonb, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_save_syllabus_texts(p_university_id smallint, p_course_id smallint, p_pseudo_course_id smallint, p_cycle_id bigint, p_syllabus jsonb, p_syllabus_week_titles jsonb, p_created_by bigint, p_company_id bigint) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_syllabus_id BIGINT;
        v_week_config RECORD;
        v_text_week_id BIGINT;
        v_distribution RECORD;
        v_distribution_id BIGINT;
        v_text RECORD;
        v_text_id BIGINT;
        v_subtopic RECORD;
        v_syllabus_week_title JSONB;
    BEGIN
        -- PASO 1: CREAR EL REGISTRO PRINCIPAL EN LA TABLA SYLLABUS
        INSERT INTO syllabus (university_id, course_id, pseudo_course_id, cycle_id, created_by, created_at, company_id)
        VALUES (p_university_id, p_course_id, p_pseudo_course_id, p_cycle_id, p_created_by, now(), p_company_id)
        RETURNING id INTO v_syllabus_id;

        IF p_syllabus_week_titles IS NOT NULL OR jsonb_array_length(p_syllabus_week_titles) > 0 THEN
            FOR v_syllabus_week_title IN SELECT jsonb_array_elements(p_syllabus_week_titles) LOOP
                    INSERT INTO syllabus_week_titles (syllabus_id, week, title, created_by, created_at, company_id)
                    VALUES (v_syllabus_id, (v_syllabus_week_title->>'week_id')::SMALLINT, (v_syllabus_week_title->>'title'), p_created_by, now(), p_company_id);
            END LOOP;
        END IF;

        -- PASO 2: Recorrer el payload para insertar las configuraciones de texto,
        FOR v_week_config IN SELECT * FROM jsonb_to_recordset(p_syllabus) AS w(week INT, distributions JSONB)
        LOOP
            -- Insertar la configuración de la semana
            INSERT INTO syllabus_text_weeks(syllabus_id, week, created_by, created_at, company_id)
            VALUES (v_syllabus_id, v_week_config.week, p_created_by, now(), p_company_id)
            RETURNING id INTO v_text_week_id;

            -- Recorrer las distribuciones (materiales) de esa semana
            FOR v_distribution IN SELECT * FROM jsonb_to_recordset(v_week_config.distributions) AS d(material_id INT, texts JSONB)
            LOOP
                INSERT INTO syllabus_text_distributions(syllabus_text_week_id, type_material_id, created_by, created_at, company_id)
                VALUES (v_text_week_id, v_distribution.material_id, p_created_by, now(), p_company_id)
                RETURNING id INTO v_distribution_id;

                -- Recorrer los textos (instancias) de esa distribución
                FOR v_text IN SELECT * FROM jsonb_to_recordset(v_distribution.texts) AS t(category_id INT, subcategory_id INT, position INT, style_type VARCHAR,quantity INT, subtopics JSONB)
                LOOP
                    INSERT INTO syllabus_texts(syllabus_text_distribution_id, type_text_id, type_text_subcategory_id, "position", created_by, created_at, company_id)
                    VALUES (v_distribution_id, v_text.category_id, v_text.subcategory_id, v_text.position, p_created_by, now(), p_company_id)
                    RETURNING id INTO v_text_id;

                    IF v_text.quantity IS NOT NULL 
                        AND v_text.style_type IS NOT NULL 
                        AND TRIM(v_text.style_type) <> '' THEN

                        INSERT INTO syllabus_text_detail(
                            syllabus_text_id,
                            quantity,
                            style_type,
                            created_at,
                            created_by
                        )
                        VALUES (
                            v_text_id,
                            v_text.quantity,
                            v_text.style_type,
                            now(),
                            p_created_by
                        );

                    END IF;

                    -- Recorrer el contenido (subtemas) de ese texto
                    FOR v_subtopic IN SELECT * FROM jsonb_to_recordset(v_text.subtopics) AS s(subtopic_id INT, quantity INT)
                    LOOP
                        INSERT INTO syllabus_text_content(syllabus_text_id, subtopic_id, quantity, created_by, created_at, company_id)
                        VALUES (v_text_id, v_subtopic.subtopic_id, v_subtopic.quantity, p_created_by, now(), p_company_id);
                    END LOOP;
                END LOOP;
            END LOOP;
        END LOOP;

        RETURN v_syllabus_id;
    END;
$$;


ALTER FUNCTION odiseo.fn_save_syllabus_texts(p_university_id smallint, p_course_id smallint, p_pseudo_course_id smallint, p_cycle_id bigint, p_syllabus jsonb, p_syllabus_week_titles jsonb, p_created_by bigint, p_company_id bigint) OWNER TO postgres;

--

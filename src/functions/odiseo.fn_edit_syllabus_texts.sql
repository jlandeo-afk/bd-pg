-- Function: odiseo.fn_edit_syllabus_texts(bigint, jsonb, bigint, boolean, bigint)

--

CREATE FUNCTION odiseo.fn_edit_syllabus_texts(p_syllabus_id bigint, p_payload jsonb, p_user_id bigint, p_is_partial_update boolean, p_company_id bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_week_config    RECORD;
    v_text_week_id   BIGINT;
    v_distribution   RECORD;
    v_distribution_id BIGINT;
    v_text           RECORD;
    v_text_id        BIGINT;
    v_subtopic       RECORD;
    v_content_id     BIGINT;
    v_syllabus_text_detail_id BIGINT;
BEGIN

    -- ----------------------------------------------------------------
    -- Soft-delete de semanas que no vienen en el payload
    -- ----------------------------------------------------------------
    IF NOT p_is_partial_update THEN
        UPDATE syllabus_text_weeks
           SET fl_status  = false,
               updated_by = p_user_id,
               updated_at = now()
         WHERE syllabus_id = p_syllabus_id
           AND company_id  = p_company_id
           AND week NOT IN (
               SELECT (w ->> 'week')::int
               FROM jsonb_array_elements(p_payload) w
           );
    END IF;

    -- ----------------------------------------------------------------
    -- Iterar semanas del payload
    -- ----------------------------------------------------------------
    FOR v_week_config IN
        SELECT *
        FROM jsonb_to_recordset(p_payload) AS w(week INT, distributions JSONB)
    LOOP

        -- Upsert semana
        SELECT id INTO v_text_week_id
          FROM syllabus_text_weeks
         WHERE syllabus_id = p_syllabus_id
           AND week        = v_week_config.week
           AND company_id  = p_company_id;

        IF v_text_week_id IS NULL THEN
            INSERT INTO syllabus_text_weeks (syllabus_id, week, created_by, created_at, company_id)
            VALUES (p_syllabus_id, v_week_config.week, p_user_id, now(), p_company_id)
            RETURNING id INTO v_text_week_id;
        ELSE
            UPDATE syllabus_text_weeks
               SET fl_status  = true,
                   updated_by = p_user_id,
                   updated_at = now()
             WHERE id         = v_text_week_id
               AND company_id = p_company_id;
        END IF;

        -- Soft-delete de distributions que no vienen en el payload de esta semana
        UPDATE syllabus_text_distributions
           SET fl_status  = false,
               updated_by = p_user_id,
               updated_at = now()
         WHERE syllabus_text_week_id = v_text_week_id
           AND company_id            = p_company_id
           AND type_material_id NOT IN (
               SELECT (d ->> 'material_id')::int
               FROM jsonb_array_elements(v_week_config.distributions) d
           );

        -- Iterar distributions de la semana
        FOR v_distribution IN
            SELECT *
            FROM jsonb_to_recordset(v_week_config.distributions) AS d(material_id INT, texts JSONB)
        LOOP

            -- Upsert distribution
            SELECT id INTO v_distribution_id
              FROM syllabus_text_distributions
             WHERE syllabus_text_week_id = v_text_week_id
               AND type_material_id      = v_distribution.material_id
               AND company_id            = p_company_id;

            IF v_distribution_id IS NULL THEN
                INSERT INTO syllabus_text_distributions (syllabus_text_week_id, type_material_id, created_at, created_by, company_id)
                VALUES (v_text_week_id, v_distribution.material_id, now(), p_user_id, p_company_id)
                RETURNING id INTO v_distribution_id;
            ELSE
                UPDATE syllabus_text_distributions
                   SET fl_status  = true,
                       updated_by = p_user_id,
                       updated_at = now()
                 WHERE id         = v_distribution_id
                   AND company_id = p_company_id;
            END IF;

            -- Soft-delete de todos los textos de esta distribution (se reactivan abajo)
            UPDATE syllabus_texts
               SET fl_status  = false,
                   updated_by = p_user_id,
                   updated_at = now()
             WHERE syllabus_text_distribution_id = v_distribution_id
               AND company_id                    = p_company_id;

            -- Iterar textos de la distribution
            FOR v_text IN
                SELECT *
                FROM jsonb_to_recordset(v_distribution.texts) AS t(
                    category_id    INT,
                    subcategory_id INT,
                    position       INT,
                    style_type     VARCHAR, 
                    quantity       INT,
                    subtopics      JSONB
                )
            LOOP

                -- Upsert texto
                SELECT id INTO v_text_id
                  FROM syllabus_texts
                 WHERE syllabus_text_distribution_id = v_distribution_id
                   AND position                      = v_text.position
                   AND type_text_id                  = v_text.category_id
                   AND type_text_subcategory_id      = v_text.subcategory_id
                   AND company_id                    = p_company_id;

                IF v_text_id IS NULL THEN
                    INSERT INTO syllabus_texts (
                        syllabus_text_distribution_id, type_text_id, type_text_subcategory_id,
                        position, created_at, created_by, company_id
                    )
                    VALUES (
                        v_distribution_id, v_text.category_id, v_text.subcategory_id,
                        v_text.position, now(), p_user_id, p_company_id
                    )
                    RETURNING id INTO v_text_id;
                ELSE
                    UPDATE syllabus_texts
                       SET fl_status               = true,
                           type_text_id            = v_text.category_id,
                           type_text_subcategory_id = v_text.subcategory_id,
                           updated_by              = p_user_id,
                           updated_at              = now()
                     WHERE id         = v_text_id
                       AND company_id = p_company_id;
                END IF;

                IF v_text.quantity IS NOT NULL 
                    AND v_text.style_type IS NOT NULL 
                    AND TRIM(v_text.style_type) <> '' THEN
                    
                        SELECT id INTO v_syllabus_text_detail_id FROM syllabus_text_detail WHERE syllabus_text_id = v_text_id;

                        IF v_syllabus_text_detail_id IS NOT NULL THEN
                            UPDATE syllabus_text_detail 
                            SET 
                                quantity = v_text.quantity,
                                style_type = v_text.style_type,
                                updated_at = now(),
                                updated_by = p_user_id
                            WHERE syllabus_text_id = v_text_id;

                        ELSE 

                            INSERT INTO syllabus_text_detail 
                            (   syllabus_text_id,
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
                                p_user_id
                            );

                        END IF;

                END IF;

                -- Soft-delete de todos los subtopics de este texto (se reactivan abajo)
                UPDATE syllabus_text_content
                   SET fl_status  = false,
                       updated_by = p_user_id,
                       updated_at = now()
                 WHERE syllabus_text_id = v_text_id
                   AND company_id       = p_company_id;

                -- Iterar subtopics del texto
                FOR v_subtopic IN
                    SELECT *
                    FROM jsonb_to_recordset(v_text.subtopics) AS s(subtopic_id INT, quantity INT)
                LOOP

                    -- Upsert subtopic
                    SELECT id INTO v_content_id
                      FROM syllabus_text_content
                     WHERE syllabus_text_id = v_text_id
                       AND subtopic_id      = v_subtopic.subtopic_id
                       AND company_id       = p_company_id;

                    IF v_content_id IS NULL THEN
                        INSERT INTO syllabus_text_content (syllabus_text_id, subtopic_id, quantity, created_at, created_by, company_id)
                        VALUES (v_text_id, v_subtopic.subtopic_id, v_subtopic.quantity, now(), p_user_id, p_company_id);
                    ELSE
                        UPDATE syllabus_text_content
                           SET fl_status  = true,
                               quantity   = v_subtopic.quantity,
                               updated_by = p_user_id,
                               updated_at = now()
                         WHERE id         = v_content_id
                           AND company_id = p_company_id;
                    END IF;

                END LOOP; -- subtopics
            END LOOP; -- textos
        END LOOP; -- distributions
    END LOOP; -- semanas

    RETURN 'Configuración de textos actualizada para el syllabus ' || p_syllabus_id;
END;
$$;


ALTER FUNCTION odiseo.fn_edit_syllabus_texts(p_syllabus_id bigint, p_payload jsonb, p_user_id bigint, p_is_partial_update boolean, p_company_id bigint) OWNER TO postgres;

--

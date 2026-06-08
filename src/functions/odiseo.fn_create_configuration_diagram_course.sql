-- Function: odiseo.fn_create_configuration_diagram_course(smallint, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_create_configuration_diagram_course(p_course_id smallint, p_field_diagram jsonb, p_category_text_id bigint, p_created_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                    IF NOT EXISTS (
                        SELECT 1
                        FROM setting_diagrammed_courses sdc
                        WHERE sdc.course_id = p_course_id
                            AND (
                                (p_category_text_id IS NULL AND sdc.category_text_id IS NULL) OR
                                (p_category_text_id IS NOT NULL AND sdc.category_text_id = p_category_text_id)
                            )
                            AND sdc.fl_status = true
                    ) THEN
                        INSERT INTO setting_diagrammed_courses (
                            course_id,
                            field_diagram_id,
                            "position",
                            category_text_id,
                            fl_active,
                            fl_optional,
                            created_by,
                            created_at
                        )
                        SELECT
                            p_course_id BIGINT,
                            (fd.value->>'field_diagram_id')::SMALLINT,
                            (fd.value->>'position')::SMALLINT,
                            p_category_text_id,
                            (fd.value->>'fl_active')::BOOL,
                            (fd.value->>'fl_optional')::BOOL,
                            p_created_by,
                            now()
                        FROM jsonb_array_elements(p_field_diagram) AS fd;
                    END IF;

            END;
                    $$;


ALTER FUNCTION odiseo.fn_create_configuration_diagram_course(p_course_id smallint, p_field_diagram jsonb, p_category_text_id bigint, p_created_by bigint) OWNER TO postgres;

--

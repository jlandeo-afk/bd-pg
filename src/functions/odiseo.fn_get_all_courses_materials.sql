-- Function: odiseo.fn_get_all_courses_materials(integer, integer, text)

--

CREATE FUNCTION odiseo.fn_get_all_courses_materials(p_type_material_id integer, p_material_per_period_ballot_id integer, p_type_url text) RETURNS TABLE(id bigint, course_id smallint, code character varying, material_per_period_ballot_id bigint, type character varying, job_status character varying, url character varying, course_name character varying, position_order smallint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_template_type_material_id INT;
            BEGIN

                -- 1) Obtener template_type_material_id
                SELECT tm.type_material_template_id
                INTO v_template_type_material_id
                FROM type_material tm
                WHERE tm.id = p_type_material_id;

                -- 2) Query principal
                RETURN QUERY
                WITH base AS (
                    SELECT 
                        mppc.id,
                        mppc.course_id,
                        c.code,
                        mppc.material_per_period_ballot_id,
                        mppc.type,
                        mppc.job_status,
                        mppc.url,
                        c.name AS course_name
                    FROM material_per_period_course mppc
                    INNER JOIN course c 
                        ON c.id = mppc.course_id
                    WHERE 
                        mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
                        AND mppc.type = p_type_url
                        AND mppc.job_status = 'completed'
                        AND mppc.url IS NOT NULL
                ),

                template_base AS (
                    SELECT 
                        tm.parent_id,
                        tm.type_material_template_id AS template_id,
                        parent_tm.type_material_template_id AS template_parent_id
                    FROM type_material tm
                    LEFT JOIN type_material parent_tm 
                        ON tm.parent_id = parent_tm.id
                        WHERE tm.id = p_type_material_id
                ),

                ttmco_template AS (
                    SELECT 
                        ttmco.course_id,
                        ttmco.position
                    FROM template_type_material_courses_order ttmco
                    JOIN template_base tb 
                        ON ttmco.template_type_material_id = tb.template_id
                    WHERE ttmco.university_id IS NULL
                ),

                ttmco_parent AS (
                    SELECT 
                        ttmco.course_id,
                        ttmco.position
                    FROM template_type_material_courses_order ttmco
                    JOIN template_base tb 
                        ON ttmco.template_type_material_id = tb.template_parent_id
                    WHERE ttmco.university_id IS NULL
                ),

                final_result AS (
                    SELECT 
                        b.id,
                        b.course_id,
                        b.code,
                        b.material_per_period_ballot_id,
                        b.type,
                        b.job_status,
                        b.url,
                        b.course_name,
                        COALESCE(tt.position, tp.position) AS position_order
                    FROM base b
                    LEFT JOIN ttmco_template tt
                        ON tt.course_id = b.course_id
                    LEFT JOIN ttmco_parent tp
                        ON tp.course_id = b.course_id
                )

                SELECT 
                    fr.id,
                    fr.course_id,
                    fr.code,
                    fr.material_per_period_ballot_id,
                    fr.type,
                    fr.job_status,
                    fr.url,
                    fr.course_name,
                    fr.position_order
                FROM final_result fr
                ORDER BY 
                    fr.position_order IS NULL,
                    fr.position_order ASC,
                    fr.code ASC;

                -- 3) Fallback si base no devuelve nada
                IF NOT FOUND THEN
                    RETURN QUERY
                    SELECT 
                        tmc.id,
                        tmc.course_id,
                        c.code::VARCHAR AS code,
                        NULL::BIGINT AS material_per_period_ballot_id,
                        NULL::VARCHAR AS type,
                        NULL::VARCHAR AS job_status,
                        NULL::VARCHAR AS url,
                        c.name AS course_name,
                        NULL::SMALLINT AS position_order
                    FROM type_material_course tmc
                    INNER JOIN course c 
                        ON c.id = tmc.course_id
                    WHERE tmc.type_material_id = p_type_material_id
                    ORDER BY c.code ASC;
                END IF;

            END;
            $$;


ALTER FUNCTION odiseo.fn_get_all_courses_materials(p_type_material_id integer, p_material_per_period_ballot_id integer, p_type_url text) OWNER TO postgres;

--

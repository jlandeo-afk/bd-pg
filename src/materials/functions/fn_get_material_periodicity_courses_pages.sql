-- Function: materials.fn_get_material_periodicity_courses_pages(bigint, character varying, smallint)

--

CREATE FUNCTION materials.fn_get_material_periodicity_courses_pages(p_material_per_period_ballot_id bigint, p_type character varying, p_course_id smallint) RETURNS TABLE(course_id smallint, pages smallint, previous_course_pages smallint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_type_material_id BIGINT;
        v_has_custom_order BOOLEAN;
        v_university_id SMALLINT;
    BEGIN
        ------------------------------------------------------------------
        -- 1. Obtener type_material y universidad
        ------------------------------------------------------------------
        SELECT
            mpp.type_material_id,
            m.university_id
        INTO
            v_type_material_id,
            v_university_id
        FROM material_per_period_ballot mppb
        JOIN material_per_period mpp ON mpp.id = mppb.material_per_period_id
        JOIN material m ON m.id = mpp.material_id
        WHERE mppb.id = p_material_per_period_ballot_id;

        ------------------------------------------------------------------
        -- 2. Verificar si existe ordenamiento personalizado por template
        ------------------------------------------------------------------
        SELECT EXISTS (
            SELECT 1
            FROM type_material tm
            JOIN type_material_template tmt ON tmt.id = tm.type_material_template_id
            JOIN template_type_material_courses_order ttmco
                ON ttmco.template_type_material_id = tmt.id
            WHERE tm.id = v_type_material_id
            AND ttmco.university_id IS NULL
        )
        INTO v_has_custom_order;

        ------------------------------------------------------------------
        -- 3. Selección según tipo de orden
        ------------------------------------------------------------------
        IF v_has_custom_order THEN

            ------------------------------------------------------------------
            -- OPCIÓN A: Orden por Template (position)
            ------------------------------------------------------------------
            RETURN QUERY
            WITH all_courses AS (
                SELECT
                    mppc.course_id,
                    mppc.pages,
                    ttmco.position
                FROM material_per_period_course mppc
                JOIN material_per_period_ballot mppb
                    ON mppb.id = mppc.material_per_period_ballot_id
                JOIN material_per_period mpp
                    ON mpp.id = mppb.material_per_period_id
                JOIN type_material tm
                    ON tm.id = mpp.type_material_id
                JOIN type_material_template tmt
                    ON tmt.id = tm.type_material_template_id
                JOIN template_type_material_courses_order ttmco
                    ON ttmco.template_type_material_id = tmt.id
                AND ttmco.course_id = mppc.course_id
                WHERE mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
                AND mppc.type = p_type
                AND mppc.deleted_at IS NULL
                AND ttmco.university_id IS NULL
            ),
            calc_prev AS (
                SELECT
                    ac.course_id,
                    ac.pages,
                    (
                        SELECT ac2.pages
                        FROM all_courses ac2
                        WHERE ac2.position < ac.position
                        AND ac2.pages IS NOT NULL
                        AND ac2.pages > 0
                        ORDER BY ac2.position DESC
                        LIMIT 1
                    ) AS prev_pages
                FROM all_courses ac
            )
            SELECT
                cp.course_id::SMALLINT,
                cp.pages::SMALLINT,
                COALESCE(cp.prev_pages, 0)::SMALLINT
            FROM calc_prev cp
            WHERE cp.course_id = p_course_id;

        ELSE

            ------------------------------------------------------------------
            -- OPCIÓN B: Fallback por course_id
            ------------------------------------------------------------------
            RETURN QUERY
            WITH type_materials AS (
                SELECT
                    CASE WHEN EXISTS (
                        SELECT 1 FROM type_material tm
                        WHERE tm.parent_id = v_type_material_id) THEN
                        ARRAY (
                            SELECT tm.id FROM type_material tm WHERE tm.parent_id = v_type_material_id
                        )
                    ELSE
                        ARRAY[v_type_material_id]
                    END AS ids
            ), type_material_ids AS (
                SELECT UNNEST(tm.ids) AS id FROM type_materials tm
            ), courses_type_material AS (
                SELECT DISTINCT
                    c.id AS course_id
                FROM type_material_course tmc
                JOIN course c ON c.id = tmc.course_id
                WHERE tmc.type_material_id IN (SELECT tmi.id FROM type_material_ids tmi)
            ), all_courses AS (
                SELECT
                    mppc.course_id,
                    mppc.pages
                FROM material_per_period_course mppc
                JOIN material_per_period_ballot mppb
                    ON mppb.id = mppc.material_per_period_ballot_id
                JOIN material_per_period mpp
                    ON mpp.id = mppb.material_per_period_id
                JOIN courses_type_material ctm
                    ON ctm.course_id = mppc.course_id
                WHERE mppc.material_per_period_ballot_id = p_material_per_period_ballot_id
                AND mppc.type = p_type
                AND mppc.deleted_at IS NULL
            ),
            calc_prev AS (
                SELECT
                    ac.course_id,
                    ac.pages,
                    (
                        SELECT ac2.pages
                        FROM all_courses ac2
                        WHERE ac2.course_id < ac.course_id
                        AND ac2.pages IS NOT NULL
                        AND ac2.pages > 0
                        ORDER BY ac2.course_id DESC
                        LIMIT 1
                    ) AS prev_pages
                FROM all_courses ac
            )
            SELECT
                cp.course_id::SMALLINT,
                cp.pages::SMALLINT,
                COALESCE(cp.prev_pages, 0)::SMALLINT
            FROM calc_prev cp
            WHERE cp.course_id = p_course_id;

        END IF;
    END;
    $$;


ALTER FUNCTION materials.fn_get_material_periodicity_courses_pages(p_material_per_period_ballot_id bigint, p_type character varying, p_course_id smallint) OWNER TO postgres;

--

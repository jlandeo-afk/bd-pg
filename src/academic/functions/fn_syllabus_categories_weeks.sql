-- Function: academic.fn_syllabus_categories_weeks(bigint, smallint, smallint, integer, integer)

--

CREATE FUNCTION academic.fn_syllabus_categories_weeks(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_course_id integer, p_company_id integer) RETURNS TABLE(category_id bigint, subcategory_id bigint, category character varying, subcategory character varying, position_type_text smallint)
    LANGUAGE plpgsql
    AS $$
DECLARE
    C_STARTING_WEEK  CONSTANT SMALLINT := 1;
    C_EXAM_TYPE_TWO  CONSTANT VARCHAR  := 'Tipo 2';
    C_EXAM_TYPE_THREE CONSTANT VARCHAR := 'Tipo 3';
BEGIN
    RETURN QUERY
    WITH
    -- ─── 1. Contexto base del material ────────────────────────────────────────
    material_context AS (
        SELECT
            m.cycle_id,
            m.university_id
        FROM material m
        WHERE m.id = p_material_id
        LIMIT 1
    ),

    -- ─── 2. Clasificación del tipo de material ────────────────────────────────
    material_type_children AS (
        SELECT material_ids::JSONB
        FROM fn_get_children_material_type_ids(
            p_type_material_id,
            (SELECT mc.cycle_id FROM material_context mc)
        )
        LIMIT 1
    ),
    material_type_is_exam AS (
        SELECT tm.fl_exam AS is_exam
        FROM type_material tm
        JOIN type_material_template tmt
            ON tmt.id = tm.type_material_template_id
           AND tm.id  = p_type_material_id
    ),
    material_type_exam_label AS (
        SELECT txs.name AS exam_type_name
        FROM type_material tm
        JOIN type_material_template tmt
            ON tmt.id = tm.type_material_template_id
           AND tm.id  = p_type_material_id
        JOIN type_exams txs ON txs.id = tmt.type_exam_id
    ),

    -- ─── 3. Rango de semanas del sílabo ───────────────────────────────────────
    syllabus_max_week AS (
        SELECT MAX(stw.week) AS week
        FROM syllabus s
        JOIN syllabus_text_weeks stw ON stw.syllabus_id = s.id
        WHERE s.university_id = (SELECT mc.university_id FROM material_context mc)
          AND s.cycle_id      = (SELECT mc.cycle_id      FROM material_context mc)
          AND (p_course_id IS NULL OR s.course_id = p_course_id)
          AND stw.fl_status IS TRUE
    ),

    -- ─── 4. Resolución del rango efectivo de semanas ──────────────────────────
    --   Centraliza la lógica condicional que antes vivía en el WHERE final,
    effective_week_range AS (
        SELECT
            C_STARTING_WEEK AS week_from,
            CASE
                WHEN EXISTS (SELECT 1 FROM material_type_exam_label WHERE exam_type_name = C_EXAM_TYPE_THREE)
                    THEN (SELECT week FROM syllabus_max_week)
                WHEN EXISTS (SELECT 1 FROM material_type_exam_label WHERE exam_type_name = C_EXAM_TYPE_TWO)
                    THEN p_week
                ELSE
                    p_week
            END AS week_to
        -- Nota: para el caso default (ni Tipo 2 ni Tipo 3),
        -- week_from = week_to = p_week → filtra exactamente esa semana.
    )

    -- ─── 5. Consulta principal ────────────────────────────────────────────────
    SELECT
        s4.type_text_id             AS category_id,
        s4.type_text_subcategory_id AS subcategory_id,
        t.name                      AS category,
        t2.name                     AS subcategory,
        t.position                  AS position_type_text
    FROM syllabus s
    JOIN syllabus_text_weeks        s2  ON s2.syllabus_id              = s.id  AND s2.fl_status IS TRUE
    JOIN syllabus_text_distributions s3 ON s3.syllabus_text_week_id    = s2.id AND s3.fl_status IS TRUE
    JOIN type_material              tm  ON tm.id                       = s3.type_material_id
    JOIN type_material_template     tmt ON tmt.id                      = tm.type_material_template_id
    JOIN syllabus_texts             s4  ON s4.syllabus_text_distribution_id = s3.id AND s4.fl_status IS TRUE
    JOIN type_text                  t   ON t.id                        = s4.type_text_id
    JOIN type_text_subcategories    t2  ON t2.id                       = s4.type_text_subcategory_id
    JOIN course_assigned_categories cac ON cac.type_text_id            = t.id AND cac.course_id = s.course_id and cac.deleted_at is null
    JOIN material_type_is_exam      te  ON TRUE
    WHERE s.fl_status IS TRUE
      AND s.university_id = (SELECT mc.university_id FROM material_context mc)
      AND s.cycle_id      = (SELECT mc.cycle_id      FROM material_context mc)
      AND s.course_id     = p_course_id
      AND s.company_id    = p_company_id
      AND s2.week BETWEEN (SELECT week_from FROM effective_week_range)
                      AND (SELECT week_to   FROM effective_week_range)
      AND (
              (te.is_exam IS TRUE AND tmt.fl_use_syllabus_exam IS TRUE)
          OR  NOT EXISTS (SELECT material_ids FROM material_type_children)
          OR  s3.type_material_id IN (
                  SELECT JSONB_ARRAY_ELEMENTS_TEXT(
                      (SELECT material_ids FROM material_type_children)
                  )::SMALLINT
              )
      );
END;
$$;


ALTER FUNCTION academic.fn_syllabus_categories_weeks(p_material_id bigint, p_type_material_id smallint, p_week smallint, p_course_id integer, p_company_id integer) OWNER TO postgres;

--

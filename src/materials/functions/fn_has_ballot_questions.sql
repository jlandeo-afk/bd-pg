-- Function: materials.fn_has_ballot_questions(integer, integer)

--

CREATE FUNCTION materials.fn_has_ballot_questions(p_material_id integer, p_cycle_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        BEGIN
        RETURN EXISTS (
            WITH relevant_ids AS (
            SELECT d.id
            FROM detail_week_type_mat d
            JOIN material m
                ON m.id = d.material_id
            AND m.cycle_id = p_cycle_id
            WHERE d.material_id = p_material_id
                AND d.fl_status   IS TRUE
            )
            SELECT 1
            FROM relevant_ids r
            WHERE EXISTS (
            SELECT 1
            FROM material_ballot_question mbq
            WHERE mbq.week_type_material_id = r.id
                AND mbq.fl_status IS TRUE
            LIMIT 1
            )
            OR EXISTS (
            SELECT 1
            FROM material_ballot_question mdq
            WHERE mdq.week_type_material_id = r.id
                AND mdq.fl_status IS TRUE
            LIMIT 1
            )
            LIMIT 1
        );
        END;
        $$;


ALTER FUNCTION materials.fn_has_ballot_questions(p_material_id integer, p_cycle_id integer) OWNER TO postgres;

--

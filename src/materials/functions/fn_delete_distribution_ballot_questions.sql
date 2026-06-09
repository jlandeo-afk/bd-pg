-- Function: materials.fn_delete_distribution_ballot_questions(bigint, smallint, smallint, bigint, bigint)

--

CREATE FUNCTION materials.fn_delete_distribution_ballot_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_deleted_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
        BEGIN
            UPDATE material_ballot_subquestions
            SET fl_status = false,
                deleted_at = NOW()
            WHERE material_ballot_question_id IN (
                SELECT id 
                FROM material_ballot_question 
                WHERE material_id = p_material_id 
                  AND week = p_week 
                  AND type_material_id = p_type_material_id 
                  AND week_type_material_id = p_week_type_material_id
            );

            UPDATE material_ballot_question
            SET fl_status = false,
                deleted_at = NOW(),
                deleted_by = p_deleted_by
            WHERE material_id = p_material_id AND week = p_week AND type_material_id = p_type_material_id AND week_type_material_id = p_week_type_material_id;
        END;
        $$;


ALTER FUNCTION materials.fn_delete_distribution_ballot_questions(p_material_id bigint, p_week smallint, p_type_material_id smallint, p_week_type_material_id bigint, p_deleted_by bigint) OWNER TO postgres;

--

-- Function: materials.fn_type_material_periodicity(integer)

--

CREATE FUNCTION materials.fn_type_material_periodicity(p_id integer) RETURNS TABLE(id smallint, code character varying, description character varying, type_material_template_id bigint, type_material_template character varying, fl_status boolean, fl_exam boolean, periodicity_id smallint, periodicity character varying, quantity smallint, start_week smallint, group_previous_week boolean, group_remaining_week boolean, weeks jsonb)
    LANGUAGE plpgsql
    AS $$
		DECLARE
            v_cycle_id BIGINT;
		    v_ids_children INT[];
        BEGIN
            RETURN QUERY
            SELECT
                t.id,
                t.code,
                t.description,
                t.type_material_template_id,
                tmt.name AS type_material_template,
                t.fl_status,
                t.fl_exam,
                tmp.periodicity_id,
                p.name AS periodicity,
                COALESCE(p.quantity, tmp.quantity_week, 1::SMALLINT) AS quantity,
                tmp.start_week,
                tmp.group_previous_week,
                tmp.group_remaining_week,
                COALESCE((
                    SELECT jsonb_agg(tmdt.week ORDER BY tmdt.week ASC)
                    FROM type_material_detail_template tmdt
                    WHERE tmdt.type_material_id = t.id
                        AND tmdt.fl_status = true
                ), '[]'::JSONB) AS weeks
            FROM type_material t
            LEFT JOIN type_material_template tmt
                ON tmt.id = t.type_material_template_id
            LEFT JOIN type_material_periodicity tmp
                ON t.id = tmp.type_material_id AND tmp.fl_status = true
            LEFT JOIN periodicity p
                ON tmp.periodicity_id = p.id
            WHERE t.id = p_id;
        END;
        $$;


ALTER FUNCTION materials.fn_type_material_periodicity(p_id integer) OWNER TO postgres;

--

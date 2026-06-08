-- Function: odiseo.fn_order_list_material_per_period(bigint, smallint, smallint, smallint, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_order_list_material_per_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_distribution_orders jsonb, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                WITH get_material_per_period_ballot AS (
                    SELECT
                        mpp.id AS material_per_period_id,
                        mppb.id AS material_per_period_ballot_id
                    FROM material_per_period mpp
                    JOIN material_per_period_ballot mppb ON mpp.id = mppb.material_per_period_id
                    WHERE mpp.material_id = p_material_id
                        AND mpp.type_material_id = p_type_material_id
                        AND mppb.start_week = p_start_week
                        AND mppb.end_week = p_end_week
                        AND mppb.deleted_by IS NULL
                        AND mpp.deleted_by IS NULL
                    LIMIT 1
                ), update_order_date AS (
                    UPDATE material_per_period_ballot mppb
                    SET order_date = NOW(),
                        order_by_user_id = p_updated_by
                    WHERE mppb.id IN (
                        SELECT gmppb.material_per_period_ballot_id FROM get_material_per_period_ballot gmppb
                    )
                ), get_distribution_orders AS (
                    SELECT
                        COALESCE((dist->>'material_ballot_question_id')::BIGINT, (dist->>'id')::BIGINT) AS id,
                        (dist->>'absolute_position')::SMALLINT AS absolute_position,
                        (dist->>'random')::BOOLEAN AS random,
                        (dist->>'order')::SMALLINT AS order
                    FROM jsonb_array_elements(p_distribution_orders) dist
                )
                UPDATE material_ballot_question mbq
                SET absolute_position = gdo.absolute_position,
                    random = gdo.random,
                    "position" = gdo.order
                FROM get_distribution_orders gdo
                WHERE mbq.id = gdo.id;
            END;
            $$;


ALTER FUNCTION odiseo.fn_order_list_material_per_period(p_material_id bigint, p_type_material_id smallint, p_start_week smallint, p_end_week smallint, p_distribution_orders jsonb, p_updated_by bigint) OWNER TO postgres;

--

-- Function: odiseo.fn_update_cycle(bigint, character varying, character varying, smallint, smallint, date, date, smallint, smallint, smallint, bigint, jsonb, boolean, integer, bigint)

--

CREATE FUNCTION odiseo.fn_update_cycle(p_id bigint, p_code character varying, p_description character varying, p_month smallint, p_year smallint, p_start_date date, p_end_date date, p_weeks smallint, p_cycle_type_id smallint, p_days smallint, p_type_template_id bigint, p_cycle_weeks jsonb, p_active boolean, p_company_id integer, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        -- 1. Actualización del Ciclo Principal
                        UPDATE cycle
                        SET code = p_code,
                            description = p_description,
                            month = p_month,
                            year = p_year,
                            cycle_type_id = p_cycle_type_id,
                            start_date = p_start_date,
                            end_date = p_end_date,
                            weeks = p_weeks,
                            days = p_days,
                            active = p_active,
                            type_template_id = p_type_template_id,
                            updated_by = p_updated_by,
                            updated_at = now()
                        WHERE id = p_id;

                        -- 2. Upsert Masivo de Semanas
                        INSERT INTO cycle_weeks (week, type_week_id, cycle_id, start_date, end_date, created_by, created_at)
                        SELECT 
                            (w->>'week')::smallint,
                            (w->>'type_week_id')::bigint,
                            p_id,
                            (w->>'start_date')::date,
                            (w->>'end_date')::date,
                            p_updated_by,
                            now()
                        FROM jsonb_array_elements(p_cycle_weeks) AS w
                        ON CONFLICT (cycle_id, start_date) WHERE (fl_status IS TRUE)
                        DO UPDATE SET 
                            week = EXCLUDED.week,
                            type_week_id = EXCLUDED.type_week_id,
                            end_date = EXCLUDED.end_date,
                            updated_by = EXCLUDED.created_by,
                            updated_at = now();

                        -- 3. Desactivar semanas que no están en el JSON
                         UPDATE cycle_weeks
                        SET fl_status = FALSE,
                            updated_by = p_updated_by,
                            updated_at = now()
                        WHERE cycle_id = p_id 
                        AND fl_status IS TRUE
                        AND start_date NOT IN (
                            SELECT (w->>'start_date')::date 
                            FROM jsonb_array_elements(p_cycle_weeks) AS w
                            WHERE (w->>'start_date') IS NOT NULL
                        );

                        -- 4. Eliminar configuraciones posteriores si se reducen las semanas
                        PERFORM fn_clean_cycle_posterior_weeks(
                            p_id, 
                            (SELECT MAX((w->>'week')::smallint) FROM jsonb_array_elements(p_cycle_weeks) AS w)
                        );

                    END;
                    $$;


ALTER FUNCTION odiseo.fn_update_cycle(p_id bigint, p_code character varying, p_description character varying, p_month smallint, p_year smallint, p_start_date date, p_end_date date, p_weeks smallint, p_cycle_type_id smallint, p_days smallint, p_type_template_id bigint, p_cycle_weeks jsonb, p_active boolean, p_company_id integer, p_updated_by bigint) OWNER TO postgres;

--

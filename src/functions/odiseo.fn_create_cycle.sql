-- Function: odiseo.fn_create_cycle(character varying, character varying, smallint, smallint, date, date, smallint, bigint, smallint, bigint, jsonb, boolean, integer, bigint)

--

CREATE FUNCTION odiseo.fn_create_cycle(p_code character varying, p_description character varying, p_month smallint, p_year smallint, p_start_date date, p_end_date date, p_weeks smallint, p_cycle_type_id bigint, p_days smallint, p_type_template_id bigint, p_cycle_weeks jsonb, p_active boolean, p_company_id integer, p_user bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        v_cycle_id BIGINT;
                    BEGIN

                        INSERT INTO cycle(
                            code, description, year, month, start_date, end_date,
                            weeks, cycle_type_id, days,
                            active, type_template_id, company_id, created_by, created_at
                        )
                        VALUES (
                            p_code, p_description, p_year, p_month, p_start_date, p_end_date,
                            p_weeks, p_cycle_type_id, p_days,
                            p_active, p_type_template_id, p_company_id, p_user, NOW()
                        )
                        RETURNING id INTO v_cycle_id;

                        -- 3. Insertar Semanas (Mapeo directo desde JSON)
                        INSERT INTO cycle_weeks (
                            week, type_week_id, cycle_id, start_date, end_date,
                            created_by, created_at
                        )
                        SELECT
                            w.week,
                            w.type_week_id,
                            v_cycle_id,
                            w.start_date,
                            w.end_date,
                            p_user,
                            NOW()
                        FROM jsonb_to_recordset(p_cycle_weeks) AS w(
                            week SMALLINT,
                            type_week_id BIGINT,
                            start_date DATE,
                            end_date DATE
                        );

                        RETURN;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_create_cycle(p_code character varying, p_description character varying, p_month smallint, p_year smallint, p_start_date date, p_end_date date, p_weeks smallint, p_cycle_type_id bigint, p_days smallint, p_type_template_id bigint, p_cycle_weeks jsonb, p_active boolean, p_company_id integer, p_user bigint) OWNER TO postgres;

--

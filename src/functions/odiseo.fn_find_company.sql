-- Function: odiseo.fn_find_company(bigint)

--

CREATE FUNCTION odiseo.fn_find_company(p_id bigint) RETURNS TABLE(id bigint, uuid uuid, social_reason character varying, commercial_name character varying, type_company character varying, document_number character varying, domain_email character varying, schema character varying, address character varying, city character varying, state character varying, main_number character varying, other_number character varying, prospect_id bigint, plan_id bigint, plan character varying, plan_description character varying, plan_cost numeric, fl_status boolean)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    c.id,
                    c.uuid,
                    c.social_reason,
                    c.commercial_name,
                    c.type_company,
                    c.document_number,
                    c.domain_email,
                    c."schema",
                    c.address,
                    c.city,
                    c.state,
                    c.main_number,
                    c.other_number,
                    c.prospect_id,
                    c.plan_id,
                    p.name AS plan,
                    p.description AS plan_description,
                    p.cost AS plan_cost,
                    c.fl_status
                FROM odiseo.companies c
                LEFT JOIN odiseo.plans p ON c.plan_id = p.id
                WHERE c.id = p_id
                AND c.fl_status = true;
            END;
            $$;


ALTER FUNCTION odiseo.fn_find_company(p_id bigint) OWNER TO postgres;

--

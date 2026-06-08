-- Function: odiseo.fn_configuration_alternative_update(bigint, character varying, smallint, text, boolean, boolean, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_configuration_alternative_update(p_id bigint, p_name character varying, p_columns smallint, p_styles text, p_fl_image boolean, p_fl_default boolean, p_company_id bigint, p_user_id bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE
            v_edit_id integer;
        BEGIN
            UPDATE configuration_alternative
            SET
                name = p_name,
                columns = p_columns,
                styles = p_styles,
                fl_image = p_fl_image,
                fl_default = p_fl_default,
                updated_by = p_user_id,
                updated_at = now()
            WHERE
                id = p_id
            RETURNING id INTO v_edit_id;

            IF p_fl_default = true THEN
                UPDATE configuration_alternative
                SET fl_default = false
                WHERE id <> p_id;
            END IF;

            RETURN v_edit_id;
        END;
    $$;


ALTER FUNCTION odiseo.fn_configuration_alternative_update(p_id bigint, p_name character varying, p_columns smallint, p_styles text, p_fl_image boolean, p_fl_default boolean, p_company_id bigint, p_user_id bigint) OWNER TO postgres;

--

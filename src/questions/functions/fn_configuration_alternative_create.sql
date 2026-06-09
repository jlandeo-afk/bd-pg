-- Function: questions.fn_configuration_alternative_create(character varying, smallint, text, boolean, boolean, bigint, integer)

--

CREATE FUNCTION questions.fn_configuration_alternative_create(p_name character varying, p_columns smallint, p_styles text, p_fl_image boolean, p_fl_default boolean, p_company_id bigint, p_user_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
                DECLARE
                    v_new_id integer;
                BEGIN
                    INSERT INTO questions.configuration_alternative (name, columns, styles, fl_image, fl_default, fl_status, company_id, created_by, created_at)
                    VALUES (
                        p_name,
                        p_columns,
                        p_styles,
                        p_fl_image,
                        p_fl_default,
                        true,
                        p_company_id,
                        p_user_id,
                        now()
                    )
                    RETURNING id INTO v_new_id;

                    IF p_fl_default = true THEN
                        UPDATE questions.configuration_alternative
                        SET fl_default = false
                        WHERE id <> v_new_id AND company_id = p_company_id;
                    END IF;

                    RETURN v_new_id;
                END;
            $$;


ALTER FUNCTION questions.fn_configuration_alternative_create(p_name character varying, p_columns smallint, p_styles text, p_fl_image boolean, p_fl_default boolean, p_company_id bigint, p_user_id integer) OWNER TO postgres;

--

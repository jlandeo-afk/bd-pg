-- Function: odiseo.fn_update_syllabus_week_title(bigint, integer, character varying, bigint, integer)

--

CREATE FUNCTION odiseo.fn_update_syllabus_week_title(p_syllabus_id bigint, p_week integer, p_title character varying, p_company_id bigint, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
        DECLARE
            v_syllabus_week_title_id INT;
        BEGIN
            -- Buscar el ID del syllabus_week_title
            SELECT swt.id
            INTO v_syllabus_week_title_id
            FROM syllabus_week_titles swt
            WHERE swt.syllabus_id = p_syllabus_id
            AND swt.company_id = p_company_id
            AND swt.week = p_week
            AND swt.fl_status = TRUE;

            -- Si no existe un registro, insertamos uno nuevo
            IF v_syllabus_week_title_id IS NULL THEN
                INSERT INTO syllabus_week_titles(syllabus_id, title, week, created_by, created_at, company_id)
                VALUES (p_syllabus_id, p_title, p_week, p_user_id, now(), p_company_id);
            ELSE
                -- Si ya existe, actualizamos el título
                UPDATE syllabus_week_titles
                SET title = p_title
                WHERE syllabus_id = p_syllabus_id
                AND company_id = p_company_id
                AND week = p_week
                AND fl_status = TRUE;
            END IF;
        END;
$$;


ALTER FUNCTION odiseo.fn_update_syllabus_week_title(p_syllabus_id bigint, p_week integer, p_title character varying, p_company_id bigint, p_user_id integer) OWNER TO postgres;

--

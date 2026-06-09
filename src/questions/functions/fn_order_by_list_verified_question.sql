-- Function: questions.fn_order_by_list_verified_question(integer, integer, character varying, integer, integer, integer, character varying, json, json, json, integer, integer, integer, integer, character varying, integer[], text, text, smallint, smallint, smallint, smallint, character varying)

--

CREATE FUNCTION questions.fn_order_by_list_verified_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id integer, f_course_id integer, f_teacher_id integer, f_type character varying, f_topics_id json, f_subtopics_id json, f_status json, f_cycle_id integer, f_week_id integer, f_type_material_id integer, f_level_id integer, p_number_question character varying, p_array_courses integer[], p_order_column text, p_order_direction text, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) RETURNS TABLE(id bigint, key_question text, parent_id bigint, subquestions jsonb, type_question text, code character varying, number_question character varying, short_description text, course_id smallint, course character varying, teacher_id bigint, subtopic_id bigint, teacher text, status character varying, date_status timestamp without time zone, observation text, level_id smallint, level_question character varying, origin_question jsonb, shared_status text, total_count bigint)
    LANGUAGE plpgsql
    AS $$
    DECLARE
    order_clause TEXT;
    sql_query TEXT;
    BEGIN
        -- Validamos el nombre de la columna permitida
        IF p_order_column IS NULL OR p_order_column NOT IN ('code', 'level_question', 'course', 'teacher', 'date_status') THEN
            p_order_column := NULL::TEXT;
        END IF;

        -- Validamos la dirección del orden
        IF UPPER(p_order_direction) NOT IN ('ASC', 'DESC') THEN
            p_order_direction := 'ASC';
        END IF;

        -- Construimos cláusula ORDER BY segura
        IF p_order_column IS NULL THEN
            order_clause := NULL::TEXT;
        ELSE
            -- Si es por fecha no usar unaccent
            IF p_order_column = 'date_status' THEN
                order_clause := format('ORDER BY %I %s', p_order_column, p_order_direction);
            -- Si es docente mandar al final los vacios cuando es ASC y viceversa
            ELSIF p_order_column = 'teacher' THEN
                IF UPPER(p_order_direction) = 'ASC' THEN
                    order_clause := 'ORDER BY CASE WHEN teacher IS NULL OR teacher = '''' THEN 1 ELSE 0 END, unaccent(teacher) ASC';
                ELSE
                    order_clause := 'ORDER BY CASE WHEN teacher IS NULL OR teacher = '''' THEN 0 ELSE 1 END, unaccent(teacher) DESC';
                END IF;
            -- Usar los filtro siguientes
            ELSE
                order_clause := format('ORDER BY unaccent(%I) %s', p_order_column, p_order_direction);
            END IF;
        END IF;

        sql_query := 'SELECT * FROM fn_list_verified_question(';

        sql_query := sql_query || COALESCE(format('%L', p_name_text), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', p_employee_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_course_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_teacher_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_type), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_topics_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_subtopics_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_status), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_cycle_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_week_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_type_material_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_level_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', p_number_question), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', p_array_courses), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_university_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_option_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_modality_id), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_version), 'NULL') || ', ';
        sql_query := sql_query || COALESCE(format('%L', f_year), 'NULL') || ') ';

        -- Agregar el ORDER BY
        IF p_order_column IS NOT NULL THEN
            sql_query := sql_query || order_clause || ', date_status ASC';
        END IF;

        -- Agregar LIMIT y OFFSET
        sql_query := sql_query || format(' LIMIT %s OFFSET %s', p_perpage, (p_npage - 1) * p_perpage);

        -- Ejecutar la consulta dinámica
        RETURN QUERY EXECUTE sql_query;
    END;
    $$;


ALTER FUNCTION questions.fn_order_by_list_verified_question(p_perpage integer, p_npage integer, p_name_text character varying, p_employee_id integer, f_course_id integer, f_teacher_id integer, f_type character varying, f_topics_id json, f_subtopics_id json, f_status json, f_cycle_id integer, f_week_id integer, f_type_material_id integer, f_level_id integer, p_number_question character varying, p_array_courses integer[], p_order_column text, p_order_direction text, f_university_id smallint, f_option_id smallint, f_modality_id smallint, f_version smallint, f_year character varying) OWNER TO postgres;

--

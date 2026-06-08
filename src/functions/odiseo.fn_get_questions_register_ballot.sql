-- Function: odiseo.fn_get_questions_register_ballot(bigint, boolean, smallint, smallint, smallint)

--

CREATE FUNCTION odiseo.fn_get_questions_register_ballot(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) RETURNS TABLE(id bigint, code character varying, course_id smallint, topic_id smallint, level_id smallint, level smallint, type character varying, status character varying, subtopic_id integer, frequent_subtopic boolean, cycle_id integer, week smallint, type_material_id smallint, history jsonb)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH get_config_syllabus AS ( -- Se trae la configuración de niveles
                SELECT
                    csrb.subtopic_id,
                    csrb.course_id
                FROM fn_get_config_syllabus_register_ballot_period(
                    p_material_id,
                    p_type_material_id,
                    p_start_week,
                    p_end_week
                ) csrb
            ), get_config_level AS ( -- Se trae la configuración de niveles
                SELECT
                    clrb.level_id,
                    clrb.type_question,
                    clrb.course_id
                FROM fn_get_config_level_register_ballot_period(
                    p_material_id,
                    p_type_material_id,
                    p_start_week,
                    p_end_week
                ) clrb
            )
            SELECT
                fqvm.id,
                fqvm.code,
                fqvm.course_id,
                fqvm.topic_id,
                fqvm.level_id,
                fqvm.level,
                fqvm.type,
                fqvm.status,
                fqvm.subtopic_id,
                fqvm.frequent_subtopic,
                fqvm.cycle_id,
                fqvm.week,
                fqvm.type_material_id,
                fqvm.history
            FROM fn_question_verified_material(
                p_material_id,
                p_fl_validate_code
            ) fqvm
            WHERE 1 = 1
                AND fqvm.subtopic_id IN (SELECT gcs.subtopic_id FROM get_config_syllabus gcs)
                AND fqvm.level_id IN (SELECT gcl.level_id FROM get_config_level gcl)
                AND fqvm.type IN (SELECT gcl.type_question FROM get_config_level gcl)
            ORDER BY fqvm.id DESC, fqvm.topic_id ASC, fqvm.subtopic_id ASC;
        END;
        $$;


ALTER FUNCTION odiseo.fn_get_questions_register_ballot(p_material_id bigint, p_fl_validate_code boolean, p_type_material_id smallint, p_start_week smallint, p_end_week smallint) OWNER TO postgres;

--

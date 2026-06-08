-- Function: odiseo.fn_change_status_admin(bigint, character varying, character varying, bigint)

--

CREATE FUNCTION odiseo.fn_change_status_admin(p_id bigint, p_status character varying, p_status_old character varying, p_updated_by bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
            BEGIN
                UPDATE odiseo.question
                SET status = p_status, updated_by = p_updated_by, updated_at = now()
                WHERE id = p_id;

                IF p_status = 'DASI' THEN

                    PERFORM odiseo.fn_delete_exception_question(p_id, p_status_old, p_updated_by); -- Eliminar excepciones
                    PERFORM odiseo.fn_delete_diagram_question(p_id, p_updated_by); -- Eliminar diagramación
                ELSIF p_status = 'INDE' THEN

                    PERFORM odiseo.fn_delete_exception_question(p_id, p_status_old, p_updated_by); -- Eliminar excepciones
                    PERFORM odiseo.fn_delete_diagram_question(p_id, p_updated_by); -- Eliminar diagramación

                    UPDATE odiseo.employee_didi_question SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                    WHERE question_id = p_id AND fl_status = true; -- Eliminar asignación de didi
                ELSIF p_status = 'ASIG' THEN

                    PERFORM odiseo.fn_delete_exception_question(p_id, p_status_old, p_updated_by); -- Eliminar excepciones
                    PERFORM odiseo.fn_delete_diagram_question(p_id, p_updated_by); -- Eliminar diagramación

                    UPDATE odiseo.employee_didi_question SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                    WHERE question_id = p_id AND fl_status = true; -- Eliminar asignación de didi

                    PERFORM odiseo.fn_delete_index_question(p_id, p_updated_by); -- Eliminar asignación de didi
                ELSIF p_status = 'SASI' THEN

                    PERFORM odiseo.fn_delete_exception_question(p_id, p_status_old, p_updated_by); -- Eliminar excepciones
                    PERFORM odiseo.fn_delete_diagram_question(p_id, p_updated_by); -- Eliminar diagramación

                    UPDATE odiseo.employee_didi_question SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                    WHERE question_id = p_id AND fl_status = true; -- Eliminar asignación de didi

                    PERFORM odiseo.fn_delete_index_question(p_id, p_updated_by); -- Eliminar asignación de didi

                    UPDATE odiseo.employee_question SET fl_status = false, deleted_by = p_updated_by, deleted_at = now()
                    WHERE question_id = p_id AND fl_status = true; -- Eliminar asignación de docente
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_change_status_admin(p_id bigint, p_status character varying, p_status_old character varying, p_updated_by bigint) OWNER TO postgres;

--

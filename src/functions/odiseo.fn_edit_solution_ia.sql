-- Function: odiseo.fn_edit_solution_ia(bigint, text, jsonb, bigint, bigint)

--

CREATE FUNCTION odiseo.fn_edit_solution_ia(p_id bigint, p_description text, p_images jsonb, p_field_diagrammed_id bigint, p_updated_by bigint) RETURNS TABLE(question_ia_id bigint)
    LANGUAGE plpgsql
    AS $$
    BEGIN
        RETURN QUERY
        WITH update_solution AS ( -- Editar content del parámetro en question_field_diagrammed_nq
            UPDATE question_field_diagrammed_nq qfdn
            SET
                content    = p_description,
                updated_by = p_updated_by,
                updated_at = NOW()
            WHERE qfdn.question_teacher_ia_id = p_id
                AND qfdn.field_diagrammed_id = p_field_diagrammed_id
                AND EXISTS (
                    SELECT 1 FROM question_teacher_ia qtia
                    WHERE qtia.id = p_id
                        AND qtia.status_revised = false
                        AND qtia.fl_status = true
                )
            RETURNING qfdn.question_teacher_ia_id AS question_ia_id
        ), delete_images_solution AS ( -- Se elimina las imágenes de la solución por parámetro
            UPDATE solution_ia_images siai
            SET
                fl_status  = false,
                deleted_by = p_updated_by,
                deleted_at = NOW()
            WHERE siai.solution_ia_id = (SELECT us.question_ia_id FROM update_solution us)
                AND siai.type_solution = (
                    SELECT fd.name_nq
                    FROM field_diagrammed fd
                    WHERE fd.id = p_field_diagrammed_id
                )
        ), get_new_images AS ( -- Se lista las nuevas imágenes
            SELECT
                pimg->>'code'      AS code,
                pimg->>'image'     AS image,
                pimg->>'extension' AS extension
            FROM jsonb_array_elements(p_images) AS pimg
            WHERE EXISTS (SELECT 1 FROM update_solution)
        ), insert_new_images AS ( -- Se inserta las nuevas imágenes
            INSERT INTO solution_ia_images (
                code,
                extension,
                image,
                solution_ia_id,
                type_solution
            )
            SELECT
                gni.code,
                gni.extension,
                gni.image,
                us.question_ia_id,
                (SELECT fd.name_nq FROM field_diagrammed fd WHERE fd.id = p_field_diagrammed_id)
            FROM get_new_images gni,
                update_solution us
        )
        SELECT us.question_ia_id FROM update_solution us;
    END;
    $$;


ALTER FUNCTION odiseo.fn_edit_solution_ia(p_id bigint, p_description text, p_images jsonb, p_field_diagrammed_id bigint, p_updated_by bigint) OWNER TO postgres;

--

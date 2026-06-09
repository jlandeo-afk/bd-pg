-- Function: questions.fn_edit_description_ia(bigint, text, text, jsonb, bigint)

--

CREATE FUNCTION questions.fn_edit_description_ia(p_id bigint, p_description text, p_description_short text, p_images jsonb, p_updated_by bigint) RETURNS TABLE(question_ia_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH update_description AS ( -- Editar descripción de la pregunta IA
                UPDATE question_teacher_ia qtia
                SET
                    description = p_description,
                    description_short = p_description_short,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                WHERE qtia.id = p_id
                    AND qtia.status_revised = false
                    AND qtia.fl_status = true
                RETURNING qtia.id AS question_ia_id
            ), delete_images_description AS ( -- Se elimina las imagenes de la pregunta IA
                UPDATE question_ia_images qiai
                SET
                    fl_status = false,
                    deleted_by = p_updated_by,
                    deleted_at = NOW()
                WHERE
                    qiai.question_ia_id = (SELECT ud.question_ia_id FROM update_description ud)
            ), get_new_images AS ( -- Se lista las nuevas imagenes de la pregunta IA
                SELECT
                    pimg->>'code' AS code,
                    pimg->>'image' AS image,
                    pimg->>'extension' AS extension
                FROM jsonb_array_elements(p_images) AS pimg
                WHERE EXISTS (SELECT 1 FROM update_description)
            ), insert_new_images AS ( -- Se inserta las nuevas imagenes
                INSERT INTO question_ia_images (
                    code,
                    extension,
                    image,
                    question_ia_id
                )
                SELECT
                    gni.code,
                    gni.extension,
                    gni.image,
                    ud.question_ia_id
                FROM get_new_images gni,
                    update_description ud
            )
            SELECT ud.question_ia_id FROM update_description ud;
        END;
        $$;


ALTER FUNCTION questions.fn_edit_description_ia(p_id bigint, p_description text, p_description_short text, p_images jsonb, p_updated_by bigint) OWNER TO postgres;

--

-- Function: odiseo.fn_edit_alternative_ia(bigint, text, jsonb, bigint)

--

CREATE FUNCTION odiseo.fn_edit_alternative_ia(p_id bigint, p_description text, p_images jsonb, p_updated_by bigint) RETURNS TABLE(alternative_ia_id bigint)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            WITH update_alternative AS ( -- Editar descripción de la alternativa IA
                UPDATE alternative_questions_ia aqia
                SET
                    description = p_description,
                    updated_by = p_updated_by,
                    updated_at = NOW()
                FROM question_teacher_ia qtia
                WHERE aqia.question_ia_id = qtia.id
                    AND aqia.id = p_id
                    AND aqia.fl_status = true
                    AND qtia.fl_status = true
                    AND qtia.status_revised = false
                RETURNING aqia.id AS alternative_ia_id
            ), delete_images_alternatives AS ( -- Se elimina las imagenes de la pregunta IA
                UPDATE alternative_ia_images aiai
                SET
                    fl_status = false,
                    deleted_by = p_updated_by,
                    deleted_at = NOW()
                WHERE
                    aiai.alternative_ia_id = (SELECT ud.alternative_ia_id FROM update_alternative ud)
            ), get_new_images AS ( -- Se lista las nuevas imagenes de la pregunta IA
                SELECT
                    pimg->>'code' AS code,
                    pimg->>'image' AS image,
                    pimg->>'extension' AS extension
                FROM jsonb_array_elements(p_images) AS pimg
                WHERE EXISTS (SELECT 1 FROM update_alternative)
            ), insert_new_images AS ( -- Se inserta las nuevas imagenes
                INSERT INTO alternative_ia_images (
                    code,
                    extension,
                    image,
                    alternative_ia_id
                )
                SELECT
                    gni.code,
                    gni.extension,
                    gni.image,
                    ua.alternative_ia_id
                FROM get_new_images gni,
                    update_alternative ua
            )
            SELECT ua.alternative_ia_id FROM update_alternative ua;
        END;
        $$;


ALTER FUNCTION odiseo.fn_edit_alternative_ia(p_id bigint, p_description text, p_images jsonb, p_updated_by bigint) OWNER TO postgres;

--

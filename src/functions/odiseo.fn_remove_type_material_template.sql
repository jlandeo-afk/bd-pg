-- Function: odiseo.fn_remove_type_material_template(bigint, bigint)

--

CREATE FUNCTION odiseo.fn_remove_type_material_template(p_type_material_template_id bigint, p_deleted_by bigint) RETURNS json
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_deleted_id odiseo.type_material_template.id%TYPE;
            BEGIN
                -- Verificar si hay tipos de material asociados al template
                IF EXISTS (
                    SELECT 1 FROM odiseo.type_material
                    WHERE type_material_template_id = p_type_material_template_id
                    AND fl_status = TRUE
                    AND deleted_at IS NULL
                ) THEN
                    RETURN json_build_object(
                        'status', 409,
                        'message', 'No se puede eliminar el template debido a que tiene tipos de material asociados'
                    );
                END IF;

                -- Intentar eliminar el template
                UPDATE odiseo.type_material_template
                SET deleted_at = NOW(),
                    deleted_by = p_deleted_by,
                    fl_status = FALSE
                WHERE id = p_type_material_template_id
                RETURNING id INTO v_deleted_id;

                -- Retornar respuesta según resultado de eliminación
                IF v_deleted_id IS NULL THEN
                    RETURN json_build_object(
                        'status', 404,
                        'message', 'No se encontró el template a eliminar en la base de datos'
                    );
                ELSE
                    RETURN json_build_object(
                        'status', 200,
                        'message', 'Template eliminado exitosamente'
                    );
                END IF;
            END;
            $$;


ALTER FUNCTION odiseo.fn_remove_type_material_template(p_type_material_template_id bigint, p_deleted_by bigint) OWNER TO postgres;

--

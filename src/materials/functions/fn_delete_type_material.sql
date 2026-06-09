-- Function: materials.fn_delete_type_material(smallint, bigint)

--

CREATE FUNCTION materials.fn_delete_type_material(p_id smallint, p_deleted_by bigint) RETURNS TABLE(deleted_id smallint)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY
                    UPDATE materials.type_material 
                    SET fl_status = false, deleted_by = p_deleted_by, deleted_at = now()
                    WHERE id = p_id OR parent_id = p_id
                    RETURNING id;
                END;
                $$;


ALTER FUNCTION materials.fn_delete_type_material(p_id smallint, p_deleted_by bigint) OWNER TO postgres;

--

-- Function: materials.fn_create_material_notification(bigint, integer, smallint, integer, integer, bigint, character varying, character varying, character varying, character varying)

--

CREATE FUNCTION materials.fn_create_material_notification(p_material_id bigint, p_type_material_id integer, p_week smallint, p_user_to_notify_id integer, p_trigger_by integer, p_notification_type bigint, p_prefix_title character varying, p_suffix_title character varying, p_web_route character varying, p_request_status character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
                DECLARE v_notification_type_name VARCHAR;
                
                BEGIN
                    SELECT name
                    INTO v_notification_type_name 
                    FROM materials.material_generation_notification_types
                    WHERE id = p_notification_type;
                
                    WITH type_material_name AS (
                        SELECT
                            description
                        FROM materials.type_material tm
                        WHERE tm.id = p_type_material_id
                    ), cycle_name AS (
                        SELECT
                            c.description,
                            h.name
                        FROM materials.material m
                        JOIN academic.cycle c ON m.cycle_id = c.id
                        JOIN odiseo.headquarters h ON h.id = m.headquarte_id
                        WHERE m.id = p_material_id
                    ), notification_info AS (
                        SELECT
                            tmn.description AS type_material_name,
                            cm.description AS cycle_name,
                            cm.name AS headquarter_name
                        FROM cycle_name cm
                        LEFT JOIN type_material_name tmn ON 1 = 1
                    )
                    INSERT INTO materials.material_generation_notifications(
                        title,
                        message,
                        user_id,
                        created_by,
                        type,
                        url_internal,
                        request_status
                    )
                    SELECT
                        p_prefix_title || ' ' || v_notification_type_name || ' ' || p_suffix_title,
                        ni.cycle_name || ' (' || ni.type_material_name || ') ' || ' Semana ' || p_week,
                        p_user_to_notify_id,
                        p_trigger_by,
                        p_notification_type,
                        p_web_route,
                        p_request_status
                    FROM notification_info ni;
                END;
            $$;


ALTER FUNCTION materials.fn_create_material_notification(p_material_id bigint, p_type_material_id integer, p_week smallint, p_user_to_notify_id integer, p_trigger_by integer, p_notification_type bigint, p_prefix_title character varying, p_suffix_title character varying, p_web_route character varying, p_request_status character varying) OWNER TO postgres;

--

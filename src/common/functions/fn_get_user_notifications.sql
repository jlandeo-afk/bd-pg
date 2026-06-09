-- Function: common.fn_get_user_notifications(integer, integer, bigint)

--

CREATE FUNCTION common.fn_get_user_notifications(p_perpage integer, p_npage integer, p_user_id bigint) RETURNS TABLE(id bigint, title character varying, message character varying, url_internal character varying, type bigint, fl_status boolean, fl_read boolean, created_at timestamp without time zone, notification_type text, request_status text, created_by text, total_unread_notification bigint, total bigint)
    LANGUAGE plpgsql
    AS $$
            
            DECLARE offset_val INTEGER;
            
            BEGIN offset_val := p_perpage * ( p_npage - 1 );
                
                RETURN QUERY    
                WITH individual_nots AS (
                    SELECT
                        nf.id,
                        nf.title,
                        nf.message,
                        nf.url_internal,
                        nf.type,
                        nf.fl_status,
                        nf.fl_read,
                        nf.created_at,
                        'individual_notification' AS notification_type,
                        NULL::BIGINT AS created_by,
                        nf.user_id AS user_to_notify,
                        NULL AS request_status
                    FROM common.individual_notifications nf
                    WHERE 1 = 1
                      AND nf.user_id = p_user_id
                      AND nf.fl_status IS TRUE
                ), material_nots AS (
                    SELECT
                        mf.id,
                        mf.title,
                        mf.message,
                        mf.url_internal,
                        mf.type,
                        mf.fl_status,
                        mf.fl_read,
                        mf.created_at,
                        'material_notification' AS notification_type,
                        mf.created_by AS created_by,
                        mf.user_id AS user_to_notify,
                        mf.request_status AS request_status
                    FROM materials.material_generation_notifications mf
                    WHERE 1 = 1
                      AND mf.user_id = p_user_id
                      AND mf.fl_status IS TRUE
                ), notifications AS (
                    SELECT * FROM individual_nots
                    UNION ALL
                    SELECT * FROM material_nots
                )
                SELECT
                    n.id,
                    n.title,
                    n.message,
                    n.url_internal,
                    n.type,
                    n.fl_status,
                    n.fl_read,
                    n.created_at,
                    n.notification_type,
                    n.request_status,
                    CASE
                        WHEN e.id IS NULL THEN 'Sistema'
                        ELSE CONCAT(e.first_surname, ' ', e.second_surname, ' ', e.first_name)
                    END AS created_by,
                    COUNT(*) FILTER ( WHERE n.fl_read IS FALSE ) OVER () AS total_unread_notification,
                    COUNT(*) OVER () AS total
                FROM notifications n
                LEFT JOIN organization.employees e ON e.user_id = n.created_by
                ORDER BY n.created_at DESC
                LIMIT p_perpage OFFSET offset_val;
            END;
        $$;


ALTER FUNCTION common.fn_get_user_notifications(p_perpage integer, p_npage integer, p_user_id bigint) OWNER TO postgres;

--

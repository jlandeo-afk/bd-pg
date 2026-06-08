-- Function: odiseo.fn_get_image_gallery_details(integer)

--

CREATE FUNCTION odiseo.fn_get_image_gallery_details(p_image_gallery_id integer) RETURNS TABLE(id bigint, description character varying, image character varying, path_full_version character varying, topics jsonb)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    ig.id,
                    ig.name AS description,
                    ig.image,
                    ig.path_full_version,
                    jsonb_agg(
                        json_build_object(
                            'id', t.id,
                            'name', t.name,
                            'code', t.code
                        )
                    ) AS topics
                FROM odiseo.image_gallery ig
                INNER JOIN odiseo.image_galery_topic igt
                    ON ig.id = igt.image_gallery_id
                LEFT JOIN odiseo.topic t
                    ON igt.topic_id = t.id
                WHERE ig.id = p_image_gallery_id AND ig.fl_status = true AND ig.deleted_at IS NULL AND igt.fl_status = true
                GROUP BY ig.id, ig.name, ig.image, ig.path_full_version;
            END;
            $$;


ALTER FUNCTION odiseo.fn_get_image_gallery_details(p_image_gallery_id integer) OWNER TO postgres;

--

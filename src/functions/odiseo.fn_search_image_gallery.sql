-- Function: odiseo.fn_search_image_gallery(integer, integer, character varying, integer, integer)

--

CREATE FUNCTION odiseo.fn_search_image_gallery(p_perpage integer, p_npage integer, p_name_text character varying, f_course_id integer, f_topic_id integer) RETURNS TABLE(id bigint, name character varying, image character varying, width integer, height integer, path_short_version character varying, path_full_version character varying, created_by bigint, created_at timestamp without time zone, topics jsonb, total_count bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                offset_val INTEGER;
            BEGIN
                -- Calculate the offset
                offset_val := p_perpage * (p_npage - 1);

                RETURN QUERY
                WITH filtered_image_gallery AS (
                    SELECT
                        ig.id,
                        ig.name,
                        ig.image,
                        ig.width,
                        ig.height,
                        ig.path_short_version,
                        ig.path_full_version,
                        ig.created_by,
                        ig.created_at,
                        (
                            SELECT jsonb_agg(
                                json_build_object(
                                    'topic_id', t.id,
                                    'topic', t.name,
                                    'course_id', c.id,
                                    'course', c.name
                                )
                            )
                            FROM odiseo.image_galery_topic igt
                            LEFT JOIN odiseo.topic t ON igt.topic_id = t.id
                            LEFT JOIN odiseo.course c ON t.course_id = c.id
                            WHERE igt.image_gallery_id = ig.id
                            AND igt.fl_status = TRUE
                            AND (f_course_id IS NULL OR c.id = f_course_id)
                            AND (f_topic_id IS NULL OR t.id = f_topic_id)
                        ) AS topics
                    FROM odiseo.image_gallery ig
                    WHERE ig.fl_status = TRUE
                    AND ig.deleted_at IS NULL
                    AND (p_name_text IS NULL
                        OR LOWER(ig.name) LIKE '%' || LOWER(p_name_text) || '%'
                    )
                    AND EXISTS (
                        SELECT 1
                        FROM odiseo.image_galery_topic igt
                        LEFT JOIN odiseo.topic t ON igt.topic_id = t.id
                        LEFT JOIN odiseo.course c ON t.course_id = c.id
                        WHERE igt.image_gallery_id = ig.id
                            AND igt.fl_status = TRUE
                            AND (f_course_id IS NULL OR c.id = f_course_id)
                            AND (f_topic_id IS NULL OR t.id = f_topic_id)
                    )
                )
                SELECT *, count(*) OVER () AS total_count
                FROM filtered_image_gallery
                ORDER BY created_at DESC, id ASC
                LIMIT p_perpage
                OFFSET offset_val;
            END;
            $$;


ALTER FUNCTION odiseo.fn_search_image_gallery(p_perpage integer, p_npage integer, p_name_text character varying, f_course_id integer, f_topic_id integer) OWNER TO postgres;

--

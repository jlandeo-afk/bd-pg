-- Function: academic.fn_search_subtopic(integer, integer, bigint, bigint, character varying)

--

CREATE FUNCTION academic.fn_search_subtopic(p_perpage integer, p_npage integer, f_topic_id bigint, f_course_id bigint, p_text character varying) RETURNS TABLE(id smallint, code character varying, name character varying, topic_id smallint, topic character varying, course_id smallint, code_course character varying, course character varying, fl_status boolean, total integer, created_by character varying, created_at timestamp without time zone, updated_by character varying, updated_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
        DECLARE
            total_count INTEGER;
            offset_val INTEGER;
        BEGIN
            -- Calculate offset value for pagination
            offset_val := p_perpage * (p_npage - 1);

            -- Calculate total count of subtopics matching the search criteria
            SELECT COUNT(*)
            INTO total_count
            FROM academic.subtopic s
            LEFT JOIN academic.topic t ON s.topic_id = t.id
            LEFT JOIN auth.users u ON s.created_by = u.id
            LEFT JOIN auth.users u2 ON s.updated_by = u2.id
            WHERE
                s.deleted_at IS NULL
                AND (f_topic_id IS NULL OR s.topic_id = f_topic_id)
                AND (f_course_id IS NULL OR t.course_id = f_course_id)
                AND (p_text IS NULL
                OR LOWER(s."name") LIKE '%' || LOWER(p_text) || '%'
                OR LOWER(s.code) LIKE '%' || LOWER(p_text) || '%');

            -- Return the paginated subtopics matching the search criteria
            RETURN QUERY
            SELECT
                s.id,
                s.code,
                s."name",
                t.id AS topic_id,
                t."name" AS topic,
				t.course_id,
				c.code AS code_course,
				c.name AS course,
                s.fl_status,
                total_count AS total,
                u."user" AS created_by,
                s.created_at,
                u2."user" AS updated_by,
                s.updated_at
            FROM academic.subtopic s
            LEFT JOIN academic.topic t ON s.topic_id = t.id
			LEFT JOIN academic.course c ON t.course_id = c.id
            LEFT JOIN auth.users u ON s.created_by = u.id
            LEFT JOIN auth.users u2 ON s.updated_by = u2.id
            WHERE
                s.deleted_at IS NULL
                AND (f_topic_id IS NULL OR s.topic_id = f_topic_id)
                AND (f_course_id IS NULL OR t.course_id = f_course_id)
                AND (p_text IS NULL
                OR LOWER(s."name") LIKE '%' || LOWER(p_text) || '%'
                OR LOWER(s.code) LIKE '%' || LOWER(p_text) || '%')
            ORDER BY
                  topic_id asc, s.code asc, s."name" asc
            LIMIT p_perpage
            OFFSET offset_val;
        END;
        $$;


ALTER FUNCTION academic.fn_search_subtopic(p_perpage integer, p_npage integer, f_topic_id bigint, f_course_id bigint, p_text character varying) OWNER TO postgres;

--

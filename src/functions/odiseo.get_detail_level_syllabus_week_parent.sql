-- Function: odiseo.get_detail_level_syllabus_week_parent(integer, integer, integer, integer, jsonb)

--

CREATE FUNCTION odiseo.get_detail_level_syllabus_week_parent(p_university_id integer, p_cycle_id integer, p_week_id integer, p_course_id integer, p_headquarter_id jsonb) RETURNS TABLE(level_id bigint, name_level character varying, type_material_id smallint, name_type_material character varying, total_text integer)
    LANGUAGE plpgsql
    AS $$
	BEGIN
		RETURN QUERY
		SELECT
		    tbl_detail_level_syllabus_week.level_id,
		    tbl_detail_level_syllabus_week.name_level,
		    tbl_detail_level_syllabus_week.type_material_id,
		    tbl_detail_level_syllabus_week.name_type_material,
		    COALESCE(tbl_value_detail_level_syllabus_week.number_of_passages, 0) AS number_of_passages
		FROM
		    (
		        SELECT
		            l.id AS level_id,
		            l.description AS name_level,
		            tm.type_material_id,
		            tm.name_type_material
		        FROM
		            course_level cl
		        INNER JOIN
		            "level" l
		        ON
		            cl.level_id = l.id
		        CROSS JOIN
		            (
		            SELECT
		                tm.id AS type_material_id,
		                tm.description AS name_type_material
					FROM
					    type_material tm
					JOIN "cycle" c ON c.id = tm.cycle_id
					WHERE
					    tm.fl_status = true
					    AND tm.deleted_at IS NULL
					    AND tm.fl_exam = false
					    AND c.id = p_cycle_id
					    AND tm.id NOT IN (
					        SELECT DISTINCT parent_id
					        FROM type_material
					        WHERE parent_id IS NOT NULL
					    )
		            ) AS tm
		        WHERE
		            cl.course_id = p_course_id
		            AND cl.fl_status = TRUE
		            AND l.fl_status = TRUE
		            AND l.deleted_at IS NULL
		    ) AS tbl_detail_level_syllabus_week
		LEFT JOIN
		    (
		        SELECT
		            DISTINCT dlsw.type_material_id,
		            dlsw.level_id,
		            l."name" level,
		            dlsw.number_of_passages
		        FROM
		            level_syllabus ls
		        INNER JOIN
		            level_syllabus_weeks lsw
		        ON
		            ls.id = lsw.level_syllabus_id
		        INNER JOIN
		            detail_level_syllabus_weeks_parents  dlsw
		        ON
		            dlsw.level_syllabus_weeks_id = lsw.id
		        INNER JOIN
		        	"level" l ON l.id = dlsw.level_id
		        WHERE
		            ls.course_id = p_course_id
		            AND ls.university_id = p_university_id
		            AND ls.cycle_id = p_cycle_id
		            AND lsw.week  = p_week_id
		            AND ls.headquarter_id = ANY (SELECT jsonb_array_elements_text(p_headquarter_id)::INTEGER)
		            AND ls.fl_status = true
		            AND lsw.fl_status = true
		            AND dlsw.fl_status = true
		    ) AS tbl_value_detail_level_syllabus_week
		ON
		    tbl_detail_level_syllabus_week.level_id = tbl_value_detail_level_syllabus_week.level_id 
		    AND tbl_detail_level_syllabus_week.type_material_id = tbl_value_detail_level_syllabus_week.type_material_id
		ORDER BY
		    tbl_detail_level_syllabus_week.name_level ASC,
		    tbl_detail_level_syllabus_week.type_material_id ASC;

	END;
$$;


ALTER FUNCTION odiseo.get_detail_level_syllabus_week_parent(p_university_id integer, p_cycle_id integer, p_week_id integer, p_course_id integer, p_headquarter_id jsonb) OWNER TO postgres;

--

-- Function: odiseo.fn_material_detail_generation(integer, integer, smallint, integer)

--

CREATE FUNCTION odiseo.fn_material_detail_generation(p_material_id integer, p_type_material_id integer, p_week smallint, p_cycle integer) RETURNS TABLE(solution boolean, quality boolean, material_progress integer, is_material_class boolean, process_status smallint, url character varying, type_material_id integer, solution_type_name text, week smallint, quality_type_name text, children_type_material_ids json, questions_are_completed boolean, config_level boolean, config_type boolean, lower_limit smallint, upper_limit smallint, total_processing bigint, lock_status boolean, locked_by_id bigint, locked_at timestamp without time zone, has_distribution boolean, locked_by_name text)
    LANGUAGE plpgsql
    AS $$
                BEGIN
--					DROP TABLE IF EXISTS material_variants;
--					
--                  CREATE TEMPORARY TABLE material_variants (
--                        solution BOOLEAN,
--                        quality BOOLEAN
--                  );
--            
--                  INSERT INTO material_variants (solution, quality)
--                  VALUES
--                        (TRUE, FALSE),
--                        (TRUE, TRUE),
--                        (FALSE, TRUE),
--                        (FALSE, FALSE);
                        
                    RETURN QUERY
                    
                    WITH material_variants AS (
                        SELECT *
						FROM (
						    VALUES
						        (TRUE, FALSE),
						        (TRUE, TRUE),
						        (FALSE, TRUE),
						        (FALSE, FALSE)
						) AS material_variants(solution, quality)
					),
                    type_materials_ids	AS (
                        SELECT
                            tm.id single_id,
                            tpm.id children_id
                        FROM type_material_template tmt
                        JOIN type_material tm ON tm.type_material_template_id = tmt.id
                        LEFT JOIN cycle c ON c.id = p_cycle
                        LEFT JOIN cycle_templates cs ON cs.id = c.cycle_template_id
                        LEFT JOIN type_material_bound tmb ON tmb.type_material_template_id = tmt.id AND tmb.deleted_at IS NULL
                        LEFT JOIN type_material tpm ON tpm.type_material_template_id = tmb.type_material_template_extra_id AND tpm.fl_status IS TRUE AND cs.id = tpm.id_cycle_template
                        WHERE tm.id = p_type_material_id
                    ), material_class AS (
                        SELECT
                            CASE WHEN COUNT(*) > 1 THEN 'children_material' ELSE 'single_type_material' END AS type_material_class
                        FROM type_materials_ids
                    ), material_class_to_retrieve AS (
                        SELECT 
                            CASE
                                WHEN (SELECT type_material_class FROM material_class) = 'children_material'
                                THEN children_id
                                ELSE single_id
                            END AS id
                        FROM type_materials_ids
                    ), material_unrepeated AS (
                        SELECT
                            DISTINCT smw.id,
                            mv.solution::BOOLEAN AS solution,
                            mv.quality::BOOLEAN AS quality,
                            CASE
                                WHEN dwtm.id IS NULL THEN 0
                                ELSE smw.fl_process_status
                            END AS fl_process_status,
                            smw.type_material_id,
                            CASE 
                                WHEN ( mv.quality IS FALSE AND mv.solution IS TRUE ) THEN dwtm.fl_process_status
                                WHEN ( mv.quality IS FALSE AND mv.solution IS FALSE ) THEN dwtm.fl_process_status_without
                                WHEN ( mv.quality IS TRUE AND mv.solution IS TRUE ) THEN dwtm.fl_process_quality
                                WHEN ( mv.quality IS TRUE AND mv.solution IS FALSE ) THEN dwtm.fl_process_without_quality
                            END AS process_status,
                            CASE 
                                WHEN mv.quality IS FALSE AND mv.solution IS TRUE THEN dwtm.url_solution
                                WHEN mv.quality IS FALSE AND mv.solution IS FALSE THEN dwtm.url_without_solution
                                WHEN mv.quality IS TRUE AND mv.solution IS TRUE THEN dwtm.url_quality
                                WHEN mv.quality IS TRUE AND mv.solution IS FALSE THEN dwtm.url_without_quality
                            END AS url,
                            (dwtm.fl_complete_questions AND dwtm.data_missing_course_config IS NULL) AS questions_are_completed,
                            dwtm.fl_config_level::BOOLEAN AS config_level,
                            dwtm.fl_config_type::BOOLEAN AS config_type,
                            dwtm.limit_lower_question AS lower_limit,
                            dwtm.limit_upper_question AS upper_limit,
                            dwtm.locked AS locked_status,
                            dwtm.locked_by AS locked_by,
                            dwtm.locked_at AS locked_at,
                            CASE
                                WHEN dwtm.id IS NULL THEN FALSE
                                ELSE EXISTS(SELECT * FROM material_distribution_ballot_questions mmd WHERE mmd.week_type_material_id = dwtm.id AND fl_status IS TRUE)
                            END AS has_distribution
                        FROM material_variants mv
                        LEFT JOIN detail_week_type_mat dwtm ON dwtm.week = p_week AND dwtm.type_material_id IN ( SELECT * FROM material_class_to_retrieve) AND dwtm.material_id = p_material_id
                        LEFT JOIN separated_material_week smw
                            ON dwtm.material_id = smw.material_id
                            AND smw.type_material_id IN ( SELECT single_id FROM type_materials_ids )
                            AND smw.fl_status IS TRUE
                            AND smw.week = p_week
                            AND mv.solution = smw.fl_solution
                            AND mv.quality = smw.fl_quality
                    ), regular_material AS (
                        SELECT
                            mu.solution,
                            mu.quality,
                            SUM( CASE WHEN mu.id IS NOT NULL THEN 1 ELSE 0 END ) total_material_courses,
                            SUM( CASE WHEN mu.fl_process_status = 3 THEN 1 ELSE 0 END ) AS total_completed_material_courses,
							SUM( CASE WHEN mu.fl_process_status = 2 THEN 1 ELSE 0 END ) AS total_processing_material_courses, -- Agregué
                            FALSE AS is_material_class,
                            COALESCE(mu.process_status, 0)::SMALLINT AS process_status,
                            mu.url,
                            mu.questions_are_completed,
                            mu.config_level AS config_level,
                            mu.config_type AS config_type,
                            mu.lower_limit AS lower_limit,
                            mu.upper_limit AS upper_limit,
                            mu.locked_status AS locked_status,
                            mu.locked_by AS locked_by,
                            mu.locked_at AS locked_at,
                            BOOL_AND(mu.has_distribution) has_distribution
                        FROM material_unrepeated mu
                        GROUP BY
                            mu.solution,
                            mu.quality,
                            mu.process_status,
                            mu.url,
                            mu.questions_are_completed,
                            mu.config_level,
                            mu.config_type,
                            mu.lower_limit,
                            mu.upper_limit,
                            mu.locked_status,
                            mu.locked_by,
                            mu.locked_at
                    ), class_material_percentages AS (
                        SELECT
                            NULL::BOOLEAN AS solution,
                            NULL::BOOLEAN AS quality,
                            COUNT(mcw.*) AS total_material_courses,
                            SUM( CASE WHEN mcw.fl_process_status = 3 THEN 1 ELSE 0 END ) AS total_completed_material_courses,
							SUM( CASE WHEN mcw.fl_process_status = 2 THEN 1 ELSE 0 END ) AS total_processing_material_courses, -- Agregué
                            TRUE AS is_material_class
                        FROM material_class_week mcw
                        WHERE mcw.type_material_id = p_type_material_id
                            AND mcw.week = p_week
                            AND mcw.fl_status IS TRUE
                        GROUP BY mcw.type_material_id
                    ), class_material_resources AS (
                    	SELECT
                    		dwtt.url_zip_class_mat AS url,
                    		dwtt.fl_process_class_mat AS process_status,
                    	    (dwtt.fl_complete_questions AND dwtt.data_missing_course_config IS NULL) AS questions_are_completed,
                    		dwtt.fl_config_level AS config_level,
                    		dwtt.fl_config_type AS config_type,
                            dwtt.limit_lower_question AS lower_limit,
                            dwtt.limit_upper_question AS upper_limit,
                            dwtt.locked AS locked_status,
                            dwtt.locked_by AS locked_by,
                            dwtt.locked_at AS locked_at
                    	FROM class_material_percentages cmp
                    	LEFT JOIN detail_week_type_mat dwtt ON dwtt.week = p_week AND dwtt.type_material_id IN ( SELECT id FROM material_class_to_retrieve ) AND dwtt.material_id = p_material_id
                    	GROUP BY
                    	    dwtt.url_zip_class_mat,
                    	    dwtt.fl_process_class_mat,
                    	    dwtt.fl_complete_questions,
                    	    dwtt.data_missing_course_config,
                    	    dwtt.fl_config_level,
                    	    dwtt.fl_config_type,
                            dwtt.limit_lower_question,
                            dwtt.limit_upper_question,
                            dwtt.locked,
                            dwtt.locked_by,
                            dwtt.locked_at
                    ), class_material AS (
                        SELECT
                            cmp.solution AS solution,
                            cmp.quality AS quality,
                            cmp.total_material_courses AS total_material_courses,
                            cmp.total_completed_material_courses AS total_completed_material_courses,
							cmp.total_processing_material_courses AS total_processing_material_courses, -- Agregué
                            cmp.is_material_class AS is_material_class,
                            cmr.process_status AS process_status,
                            cmr.url AS url,
                            cmr.questions_are_completed AS questions_are_completed,
                            cmr.config_level AS config_level,
                            cmr.config_type AS config_type,
                            cmr.lower_limit AS lower_limit,
                            cmr.upper_limit AS upper_limit,
                            cmr.locked_status AS locked_status,
                            cmr.locked_by AS locked_by,
                            cmr.locked_at AS locked_at,
                            FALSE AS has_distribution
                        FROM class_material_percentages cmp
                        LEFT JOIN class_material_resources cmr ON 1 = 1
                    ), all_materials AS (
                        SELECT * FROM regular_material
                        UNION
                        SELECT * FROM class_material
                    ), complete_materials AS (
                        SELECT
                            m.solution,
                            m.quality,
                            CASE
                                WHEN m.total_material_courses = 0 THEN 0::INTEGER
                                ELSE COALESCE((( m.total_completed_material_courses::DECIMAL / m.total_material_courses ) * 100 ), 0)::INTEGER
                            END AS material_progress,
                            m.is_material_class,
                            m.process_status AS process_status,
                            m.url AS url,
                            p_type_material_id AS type_material_id,
                            CASE
                                WHEN m.solution IS TRUE THEN 'Con solución'
                                WHEN m.solution IS FALSE THEN 'Sin solución'
                                ELSE 'Material de clases'
                            END AS solution_type_name,
                            p_week AS week,
                            CASE
                                WHEN m.quality IS FALSE THEN 'Oficial'
                                WHEN m.quality IS TRUE THEN 'Revisión'
                                ELSE 'Material de Clases'
                            END AS quality_type_name,
                            ( SELECT
                                JSON_AGG(id)
                                FROM material_class_to_retrieve
                            ) children_type_material_ids,
                            BOOL_AND(m.questions_are_completed) AS questions_are_completed,
                            m.config_level AS config_level,
                            m.config_type AS config_type,
                            m.lower_limit AS lower_limit,
                            m.upper_limit AS upper_limit,
                            m.total_processing_material_courses as total_processing,
                            m.locked_status AS lock_status,
                            m.locked_by AS locked_by,
                            m.locked_at AS locked_at,
                            BOOL_OR(m.has_distribution) AS has_distribution
                        FROM all_materials m
                        GROUP BY
                            m.solution,
                            m.quality,
                            m.is_material_class,
                            m.process_status,
                            m.url,
                            m.config_level,
                            m.config_type,
                            m.lower_limit,
                            m.upper_limit,
                            m.total_material_courses,
                            m.total_completed_material_courses,
                            m.total_processing_material_courses,
                            m.locked_status,
                            m.locked_by,
                            m.locked_at
                        ORDER BY
                            CASE
                                WHEN m.quality IS FALSE THEN 1
                                WHEN m.quality IS TRUE  THEN 2
                                ELSE 3
                            END DESC,
						    m.solution ASC
                    ) SELECT
                        cpm.*,
                        CASE
                            WHEN locked_by IS NULL THEN 'Sin acciones registradas'
                            WHEN locked_by IN (1, 2) THEN 'Administrador'
                            ELSE CONCAT( e.first_surname, ' ', e.second_surname, ' ', e.first_name )
                        END AS locked_by_name
                    FROM complete_materials cpm
                    LEFT JOIN employees e ON e.user_id = cpm.locked_by;
                END;
            $$;


ALTER FUNCTION odiseo.fn_material_detail_generation(p_material_id integer, p_type_material_id integer, p_week smallint, p_cycle integer) OWNER TO postgres;

--

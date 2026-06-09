-- Function: academic.fn_clean_cycle_posterior_weeks(bigint, smallint)

--

CREATE FUNCTION academic.fn_clean_cycle_posterior_weeks(p_cycle_id bigint, p_weeks smallint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- type_material (Query 3)
    UPDATE type_material_detail_text_subquestions tmdts
    SET deleted_at = now()
    FROM type_material_detail_course_texts tmdct
    JOIN type_material_detail_template tmdt ON tmdt.id = tmdct.type_material_detail_template_id
    JOIN type_material tm ON tm.id = tmdt.type_material_id
    WHERE tmdts.type_material_detail_course_text_id = tmdct.id
      AND tm.cycle_id = p_cycle_id
      AND tmdt.week > p_weeks
      AND tmdts.deleted_at IS NULL;

    UPDATE type_material_detail_course_texts tmdct
    SET deleted_at = now(), fl_status = false
    FROM type_material_detail_template tmdt
    JOIN type_material tm ON tm.id = tmdt.type_material_id
    WHERE tmdct.type_material_detail_template_id = tmdt.id
      AND tm.cycle_id = p_cycle_id
      AND tmdt.week > p_weeks
      AND tmdct.fl_status IS TRUE;

    -- type_material (Query 1)
    UPDATE type_material_detail_courses tmdc
    SET deleted_at = now(), fl_status = false
    FROM type_material tm
    JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
    WHERE tmdc.type_material_detail_template_id = tmdt.id
      AND tm.cycle_id = p_cycle_id 
      AND tmdt.week > p_weeks
      AND tmdc.fl_status IS TRUE;

    UPDATE type_material_detail_template tmdt
    SET deleted_at = now(), fl_status = false
    FROM type_material tm
    WHERE tmdt.type_material_id = tm.id
      AND tm.cycle_id = p_cycle_id
      AND tmdt.week > p_weeks
      AND tmdt.fl_status IS TRUE;

    -- type_text_material_type_course (only deleted_at, as requested)
    UPDATE type_text_material_type_course ttmtc
    SET deleted_at = now()
    FROM type_material_course tmc
    JOIN type_material tm ON tm.id = tmc.type_material_id
    JOIN type_material_detail_template tmdt ON tmdt.type_material_id = tm.id
    WHERE ttmtc.type_material_id = tm.id  
      AND tmc.course_id = ttmtc.course_id
      AND tm.cycle_id = p_cycle_id
      AND tmdt.week > p_weeks
      AND ttmtc.deleted_at IS NULL;

    -- syllabus (Query 4)
    UPDATE syllabus_subtopic_type_material sstm
    SET deleted_at = now(), fl_status = false
    FROM syllabus_detail_subtopic sds
    JOIN syllabus_topic_week stw ON stw.id = sds.syllabus_topic_week_id
    JOIN syllabus_topic st ON st.id = stw.syllabus_topic_id
    JOIN syllabus s ON s.id = st.syllabus_id
    WHERE sstm.syllabus_detail_subtopic_id = sds.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND sstm.fl_status IS TRUE;

    UPDATE syllabus_detail_subtopic sds
    SET deleted_at = now(), fl_status = false
    FROM syllabus_topic_week stw
    JOIN syllabus_topic st ON st.id = stw.syllabus_topic_id
    JOIN syllabus s ON s.id = st.syllabus_id
    WHERE sds.syllabus_topic_week_id = stw.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND sds.fl_status IS TRUE;

    UPDATE syllabus_topic_week stw
    SET deleted_at = now(), fl_status = false
    FROM syllabus_topic st
    JOIN syllabus s ON s.id = st.syllabus_id
    WHERE stw.syllabus_topic_id = st.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND stw.fl_status IS TRUE;

    -- syllabus_week_titles (Added as requested)
    UPDATE syllabus_week_titles swt
    SET deleted_at = now(), fl_status = false
    FROM syllabus s
    WHERE swt.syllabus_id = s.id
      AND s.cycle_id = p_cycle_id
      AND swt.week > p_weeks
      AND swt.fl_status IS TRUE;

    -- syllabus_text (Query 5)
    UPDATE syllabus_text_content stc
    SET fl_status = false
    FROM syllabus_text_distributions std
    JOIN syllabus_text_weeks stw ON stw.id = std.syllabus_text_week_id
    JOIN syllabus s ON s.id = stw.syllabus_id
    WHERE stc.syllabus_text_id = std.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND stc.fl_status IS TRUE;

    UPDATE syllabus_text_distributions std
    SET fl_status = false
    FROM syllabus_text_weeks stw
    JOIN syllabus s ON s.id = stw.syllabus_id
    WHERE std.syllabus_text_week_id = stw.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND std.fl_status IS TRUE;

    UPDATE syllabus_text_weeks stw
    SET fl_status = false
    FROM syllabus s
    WHERE stw.syllabus_id = s.id
      AND s.cycle_id = p_cycle_id
      AND stw.week > p_weeks
      AND stw.fl_status IS TRUE;

    -- level_syllabus (Query 6 & 7)
    UPDATE detail_level_syllabus_weeks dlsw
    SET deleted_at = now(), fl_status = false
    FROM level_syllabus_weeks lsw
    JOIN level_syllabus ls ON ls.id = lsw.level_syllabus_id
    WHERE dlsw.level_syllabus_weeks_id = lsw.id
      AND ls.cycle_id = p_cycle_id
      AND lsw.week > p_weeks
      AND dlsw.fl_status IS TRUE;

    UPDATE detail_level_syllabus_weeks_parents dlswp
    SET deleted_at = now(), fl_status = false
    FROM level_syllabus_weeks lsw
    JOIN level_syllabus ls ON ls.id = lsw.level_syllabus_id
    WHERE dlswp.level_syllabus_weeks_id = lsw.id
      AND ls.cycle_id = p_cycle_id
      AND lsw.week > p_weeks
      AND dlswp.fl_status IS TRUE;

    UPDATE level_syllabus_weeks lsw
    SET deleted_at = now(), fl_status = false
    FROM level_syllabus ls
    WHERE lsw.level_syllabus_id = ls.id
      AND ls.cycle_id = p_cycle_id
      AND lsw.week > p_weeks
      AND lsw.fl_status IS TRUE;

END;
$$;


ALTER FUNCTION academic.fn_clean_cycle_posterior_weeks(p_cycle_id bigint, p_weeks smallint) OWNER TO postgres;

--

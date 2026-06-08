-- View: odiseo.vm_material_exam_parent_question_with_subquestions

--

CREATE MATERIALIZED VIEW odiseo.vm_material_exam_parent_question_with_subquestions AS
 WITH parent_questions_with_json_subquestion AS (
         SELECT mepq.material_exam_area_week_id,
            mepq.course_id,
            mepq.parent_question_id,
            jsonb_array_elements(mepq.subquestion) AS subquestion
           FROM odiseo.material_exam_parent_question mepq
          WHERE ((1 = 1) AND (mepq.deleted_at IS NULL) AND (mepq.parent_question_id IS NOT NULL))
        ), subquestions_to_extract AS (
         SELECT pj.material_exam_area_week_id,
            pj.course_id,
            pj.parent_question_id,
            ((pj.subquestion ->> 'question_id'::text))::integer AS question_id
           FROM parent_questions_with_json_subquestion pj
        )
 SELECT sext.material_exam_area_week_id,
    sext.course_id,
    sext.parent_question_id,
    p_hc.id AS parent_question_history_id,
    sext.question_id,
    q_hc.id AS question_history_id
   FROM (((((subquestions_to_extract sext
     JOIN odiseo.material_exam_area_week meaw ON ((meaw.id = sext.material_exam_area_week_id)))
     JOIN odiseo.detail_week_type_mat dwtm ON ((dwtm.id = meaw.week_type_material_id)))
     JOIN odiseo.material m ON ((m.id = dwtm.material_id)))
     LEFT JOIN odiseo.question_history_cycle q_hc ON (((q_hc.fl_status IS TRUE) AND (q_hc.cycle_id = m.cycle_id) AND (q_hc.university_id = m.university_id) AND (q_hc.headquarters_id = m.headquarte_id) AND (q_hc.question_id = sext.question_id))))
     LEFT JOIN odiseo.question_history_cycle p_hc ON (((p_hc.fl_status IS TRUE) AND (p_hc.cycle_id = m.cycle_id) AND (p_hc.university_id = m.university_id) AND (p_hc.headquarters_id = m.headquarte_id) AND (p_hc.parent_question_id = sext.parent_question_id))))
  WITH NO DATA;


ALTER MATERIALIZED VIEW odiseo.vm_material_exam_parent_question_with_subquestions OWNER TO postgres;

--

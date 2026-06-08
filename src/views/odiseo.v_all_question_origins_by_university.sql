-- View: odiseo.v_all_question_origins_by_university

--

CREATE VIEW odiseo.v_all_question_origins_by_university AS
 WITH all_possible_origins AS (
         SELECT oq.question_id,
            oq.year,
            oq.version,
            oq.modality_option_id,
            ou.university_id,
            oq.created_at
           FROM (((odiseo.origin_question oq
             JOIN odiseo.question q ON ((q.id = oq.question_id)))
             JOIN odiseo.modality_options mo ON ((mo.id = oq.modality_option_id)))
             JOIN odiseo.option_university ou ON ((ou.id = mo.option_university_id)))
          WHERE (oq.fl_status IS TRUE)
        UNION ALL
         SELECT q.id AS question_id,
            opq.year,
            opq.version,
            opq.modality_option_id,
            ou.university_id,
            opq.created_at
           FROM (((odiseo.origin_parent_question opq
             JOIN odiseo.question q ON ((q.parent_id = opq.parent_id)))
             JOIN odiseo.modality_options mo ON ((mo.id = opq.modality_option_id)))
             JOIN odiseo.option_university ou ON ((ou.id = mo.option_university_id)))
          WHERE (opq.fl_status = true)
        ), questions_origin_with_names AS (
         SELECT apo.question_id,
            apo.year,
            apo.version,
            mo.id AS modality_option_id,
            ou.id AS option_id,
            ou.university_id,
            u.slug AS university_name,
            ou.name AS option_name,
            mo.name AS modality_name,
            row_number() OVER (PARTITION BY apo.question_id, apo.university_id ORDER BY apo.year DESC, apo.version DESC, apo.created_at DESC) AS absolute_version
           FROM (((all_possible_origins apo
             LEFT JOIN odiseo.modality_options mo ON ((mo.id = apo.modality_option_id)))
             LEFT JOIN odiseo.option_university ou ON ((ou.id = mo.option_university_id)))
             LEFT JOIN odiseo.origin_university u ON ((u.id = apo.university_id)))
          WHERE (mo.fl_allows_mark_frequent_topic = true)
        ), more_recent_questions_origin AS (
         SELECT qon.question_id,
            jsonb_build_array(jsonb_build_object('name', qon.university_name, 'type', 'university', 'id', qon.university_id), jsonb_build_object('name', qon.option_name, 'type', 'option', 'id', qon.option_id), jsonb_build_object('name', qon.modality_name, 'type', 'modality', 'id', qon.modality_option_id), jsonb_build_object('name', odiseo.fn_number_to_roman(qon.version), 'type', 'version', 'id', NULL::unknown), jsonb_build_object('name', qon.year, 'type', 'year', 'id', NULL::unknown)) AS question_origin,
            format(
                CASE
                    WHEN (qon.version IS NULL) THEN '%s %s %s'::text
                    ELSE '%s %s %s - %s'::text
                END, qon.option_name, qon.university_name, qon.year, odiseo.fn_number_to_roman(qon.version)) AS question_origin_text,
            qon.university_id,
            qon.option_id,
            qon.modality_option_id AS modality_id,
            qon.version,
            (qon.year)::character varying AS year
           FROM questions_origin_with_names qon
          WHERE (qon.absolute_version = 1)
        )
 SELECT question_id,
    question_origin,
    question_origin_text,
    university_id,
    option_id,
    modality_id,
    version,
    year
   FROM more_recent_questions_origin;


ALTER VIEW odiseo.v_all_question_origins_by_university OWNER TO postgres;

--

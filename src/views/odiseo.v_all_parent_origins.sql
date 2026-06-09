-- View: odiseo.v_all_parent_origins

--

CREATE VIEW odiseo.v_all_parent_origins AS
 WITH parent_origin_with_names AS (
         SELECT opq.parent_id,
            opq.year,
            opq.version,
            m.id AS modality_id,
            o.id AS option_id,
            o.university_id,
            u.slug AS university_name,
            o.name AS option_name,
            m.name AS modality_name,
            row_number() OVER (PARTITION BY opq.parent_id ORDER BY opq.year DESC, opq.version DESC, opq.created_at DESC) AS absolute_version
           FROM (((questions.origin_parent_question opq
             LEFT JOIN academic.origin_university u ON ((u.id = opq.university_id)))
             LEFT JOIN academic.modality_options m ON ((m.id = opq.modality_option_id)))
             LEFT JOIN academic.option_university o ON ((o.id = m.option_university_id)))
          WHERE (opq.fl_status = true)
        ), more_recent_parent_origin AS (
         SELECT pow.parent_id,
            jsonb_build_array(jsonb_build_object('name', pow.university_name, 'type', 'university', 'id', pow.university_id), jsonb_build_object('name', pow.option_name, 'type', 'option', 'id', pow.option_id), jsonb_build_object('name', pow.modality_name, 'type', 'modality', 'id', pow.modality_id), jsonb_build_object('name', common.fn_number_to_roman(pow.version), 'type', 'version', 'id', NULL::unknown), jsonb_build_object('name', pow.year, 'type', 'year', 'id', NULL::unknown)) AS question_origin,
            format(
                CASE
                    WHEN (pow.version IS NULL) THEN '%s %s %s'::text
                    ELSE '%s %s %s - %s'::text
                END, pow.option_name, pow.university_name, pow.year, common.fn_number_to_roman(pow.version)) AS question_origin_text,
            pow.university_id,
            pow.option_id,
            pow.modality_id,
            pow.version,
            (pow.year)::character varying AS year
           FROM parent_origin_with_names pow
          WHERE (pow.absolute_version = 1)
        )
 SELECT parent_id,
    question_origin,
    question_origin_text,
    university_id,
    option_id,
    modality_id,
    version,
    year
   FROM more_recent_parent_origin;


ALTER VIEW odiseo.v_all_parent_origins OWNER TO postgres;

--

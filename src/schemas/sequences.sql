-- Sequences

--

CREATE SEQUENCE audit.audit_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.audit_config_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE audit.audit_config_id_seq OWNED BY audit.audit_config.id;


--

--

CREATE SEQUENCE audit.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.audit_log_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE audit.audit_log_id_seq OWNED BY audit.audit_log.id;


--

--

CREATE SEQUENCE audit.function_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE audit.function_log_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE audit.function_log_id_seq OWNED BY audit.function_log.id;


--

--

CREATE SEQUENCE odiseo.advanced_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.advanced_settings_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.advanced_settings_id_seq OWNED BY odiseo.advanced_settings.id;


--

--

CREATE SEQUENCE odiseo.alternative_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.alternative_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.alternative_ia_images_id_seq OWNED BY odiseo.alternative_ia_images.id;


--

--

CREATE SEQUENCE odiseo.alternative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.alternative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.alternative_id_seq OWNED BY odiseo.alternative.id;


--

--

CREATE SEQUENCE odiseo.alternative_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.alternative_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.alternative_maths_id_seq OWNED BY odiseo.alternative_maths.id;


--

--

CREATE SEQUENCE odiseo.alternative_questions_ia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.alternative_questions_ia_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.alternative_questions_ia_id_seq OWNED BY odiseo.alternative_questions_ia.id;


--

--

CREATE SEQUENCE odiseo.area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.area_id_seq OWNED BY odiseo.area.id;


--

--

CREATE SEQUENCE odiseo.category_rejected_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.category_rejected_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.category_rejected_id_seq OWNED BY odiseo.category_rejected.id;


--

--

CREATE SEQUENCE odiseo.charge_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.charge_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.charge_id_seq OWNED BY odiseo.charge.id;


--

--

CREATE SEQUENCE odiseo.classroom_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.classroom_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.classroom_id_seq OWNED BY odiseo.classroom.id;


--

--

CREATE SEQUENCE odiseo.clientes_empresas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.clientes_empresas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.clientes_empresas_id_seq OWNED BY odiseo.clientes_empresas.id;


--

--

CREATE SEQUENCE odiseo.code_prospect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.code_prospect_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.code_prospect_id_seq OWNED BY odiseo.code_prospect.id;


--

--

CREATE SEQUENCE odiseo.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.companies_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.companies_id_seq OWNED BY odiseo.companies.id;


--

--

CREATE SEQUENCE odiseo.company_headquarters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.company_headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.company_headquarters_id_seq OWNED BY odiseo.company_headquarters.id;


--

--

CREATE SEQUENCE odiseo.company_legal_representatives_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.company_legal_representatives_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.company_legal_representatives_id_seq OWNED BY odiseo.company_legal_representatives.id;


--

--

CREATE SEQUENCE odiseo.company_universities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.company_universities_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.company_universities_id_seq OWNED BY odiseo.company_universities.id;


--

--

CREATE SEQUENCE odiseo.company_user_admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.company_user_admin_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.company_user_admin_id_seq OWNED BY odiseo.company_user_admin.id;


--

--

CREATE SEQUENCE odiseo.configuration_alternative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.configuration_alternative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.configuration_alternative_id_seq OWNED BY odiseo.configuration_alternative.id;


--

--

CREATE SEQUENCE odiseo.course_assigned_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_assigned_categories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_assigned_categories_id_seq OWNED BY odiseo.course_assigned_categories.id;


--

--

CREATE SEQUENCE odiseo.course_assigned_subcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_assigned_subcategories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_assigned_subcategories_id_seq OWNED BY odiseo.course_assigned_subcategories.id;


--

--

CREATE SEQUENCE odiseo.course_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_id_seq OWNED BY odiseo.course.id;


--

--

CREATE SEQUENCE odiseo.course_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_level_id_seq OWNED BY odiseo.course_level.id;


--

--

CREATE SEQUENCE odiseo.course_pseudo_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_pseudo_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_pseudo_course_id_seq OWNED BY odiseo.course_pseudo_course.id;


--

--

CREATE SEQUENCE odiseo.course_pseudo_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_pseudo_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_pseudo_courses_id_seq OWNED BY odiseo.course_pseudo_courses.id;


--

--

CREATE SEQUENCE odiseo.course_text_category_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.course_text_category_settings_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.course_text_category_settings_id_seq OWNED BY odiseo.course_text_category_settings.id;


--

--

CREATE SEQUENCE odiseo.cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.cycle_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.cycle_id_seq OWNED BY odiseo.cycle.id;


--

--

CREATE SEQUENCE odiseo.cycle_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.cycle_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.cycle_types_id_seq OWNED BY odiseo.cycle_types.id;


--

--

CREATE SEQUENCE odiseo.cycle_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.cycle_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.cycle_weeks_id_seq OWNED BY odiseo.cycle_weeks.id;


--

--

CREATE SEQUENCE odiseo.detail_level_syllabus_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.detail_level_syllabus_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.detail_level_syllabus_weeks_id_seq OWNED BY odiseo.detail_level_syllabus_weeks.id;


--

--

CREATE SEQUENCE odiseo.detail_level_syllabus_weeks_parents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.detail_level_syllabus_weeks_parents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.detail_level_syllabus_weeks_parents_id_seq OWNED BY odiseo.detail_level_syllabus_weeks_parents.id;


--

--

CREATE SEQUENCE odiseo.detail_week_type_mat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.detail_week_type_mat_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.detail_week_type_mat_id_seq OWNED BY odiseo.detail_week_type_mat.id;


--

--

CREATE SEQUENCE odiseo.didi_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.didi_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.didi_maths_id_seq OWNED BY odiseo.didi_maths.id;


--

--

CREATE SEQUENCE odiseo.districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.districts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.districts_id_seq OWNED BY odiseo.districts.id;


--

--

CREATE SEQUENCE odiseo.employee_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_course_id_seq OWNED BY odiseo.employee_course.id;


--

--

CREATE SEQUENCE odiseo.employee_didi_question_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_didi_question_field_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_didi_question_field_id_seq OWNED BY odiseo.employee_didi_question_field.id;


--

--

ALTER TABLE odiseo.employee_didi_question_field_image ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME odiseo.employee_didi_question_field_image_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--

--

CREATE SEQUENCE odiseo.employee_didi_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_didi_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_didi_question_id_seq OWNED BY odiseo.employee_didi_question.id;


--

--

CREATE SEQUENCE odiseo.employee_didi_question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_didi_question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_didi_question_image_id_seq OWNED BY odiseo.employee_didi_question_image.id;


--

--

CREATE SEQUENCE odiseo.employee_question_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_question_document_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_question_document_id_seq OWNED BY odiseo.employee_question_document.id;


--

--

CREATE SEQUENCE odiseo.employee_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_question_id_seq OWNED BY odiseo.employee_question.id;


--

--

CREATE SEQUENCE odiseo.employee_question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_question_image_id_seq OWNED BY odiseo.employee_question_image.id;


--

--

CREATE SEQUENCE odiseo.employee_question_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_question_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_question_maths_id_seq OWNED BY odiseo.employee_question_maths.id;


--

--

CREATE SEQUENCE odiseo.employee_university_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employee_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employee_university_id_seq OWNED BY odiseo.employee_university.id;


--

--

CREATE SEQUENCE odiseo.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.employees_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.employees_id_seq OWNED BY odiseo.employees.id;


--

--

CREATE SEQUENCE odiseo.essential_knowledge_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.essential_knowledge_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.essential_knowledge_image_id_seq OWNED BY odiseo.essential_knowledge_image.id;


--

--

CREATE SEQUENCE odiseo.essential_knowledge_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.essential_knowledge_questions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.essential_knowledge_questions_id_seq OWNED BY odiseo.essential_knowledge_questions.id;


--

--

CREATE SEQUENCE odiseo.essential_knowledges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.essential_knowledges_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.essential_knowledges_id_seq OWNED BY odiseo.essential_knowledges.id;


--

--

CREATE SEQUENCE odiseo.exam_area_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.exam_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.exam_area_id_seq OWNED BY odiseo.exam_area.id;


--

--

CREATE SEQUENCE odiseo.exam_material_config_area_course_levels_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.exam_material_config_area_course_levels_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.exam_material_config_area_course_levels_id_seq OWNED BY odiseo.exam_material_config_area_course_levels.id;


--

--

CREATE SEQUENCE odiseo.exam_material_config_area_courses_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.exam_material_config_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.exam_material_config_area_courses_id_seq OWNED BY odiseo.exam_material_config_area_courses.id;


--

--

CREATE SEQUENCE odiseo.exam_material_configurations_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.exam_material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.exam_material_configurations_id_seq OWNED BY odiseo.exam_material_configurations.id;


--

--

CREATE SEQUENCE odiseo.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.failed_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.failed_jobs_id_seq OWNED BY odiseo.failed_jobs.id;


--

--

CREATE SEQUENCE odiseo.field_diagrammed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.field_diagrammed_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.field_diagrammed_id_seq OWNED BY odiseo.field_diagrammed.id;


--

--

CREATE SEQUENCE odiseo.frequent_university_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.frequent_university_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.frequent_university_subtopic_id_seq OWNED BY odiseo.frequent_university_subtopic.id;


--

--

CREATE SEQUENCE odiseo.headquarters_classroom_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.headquarters_classroom_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.headquarters_classroom_id_seq OWNED BY odiseo.headquarters_classroom.id;


--

--

CREATE SEQUENCE odiseo.headquarters_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.headquarters_id_seq OWNED BY odiseo.headquarters.id;


--

--

CREATE SEQUENCE odiseo.history_digitalized_solution_question_pdf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.history_digitalized_solution_question_pdf_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.history_digitalized_solution_question_pdf_id_seq OWNED BY odiseo.history_digitalized_solution_question_pdf.id;


--

--

CREATE SEQUENCE odiseo.history_syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.history_syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.history_syllabus_id_seq OWNED BY odiseo.history_syllabus.id;


--

--

CREATE SEQUENCE odiseo.image_galery_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.image_galery_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.image_galery_topic_id_seq OWNED BY odiseo.image_galery_topic.id;


--

--

CREATE SEQUENCE odiseo.image_gallery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.image_gallery_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.image_gallery_id_seq OWNED BY odiseo.image_gallery.id;


--

--

CREATE SEQUENCE odiseo.importance_rejected_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.importance_rejected_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.importance_rejected_id_seq OWNED BY odiseo.importance_rejected.id;


--

--

CREATE SEQUENCE odiseo.individual_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.individual_notifications_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.individual_notifications_id_seq OWNED BY odiseo.individual_notifications.id;


--

--

CREATE SEQUENCE odiseo.institution_types_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.institution_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.institution_types_id_seq OWNED BY odiseo.institution_types.id;


--

--

CREATE SEQUENCE odiseo.level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.level_id_seq OWNED BY odiseo.level.id;


--

--

CREATE SEQUENCE odiseo.level_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.level_rates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.level_rates_id_seq OWNED BY odiseo.level_rates.id;


--

--

CREATE SEQUENCE odiseo.level_syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.level_syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.level_syllabus_id_seq OWNED BY odiseo.level_syllabus.id;


--

--

CREATE SEQUENCE odiseo.level_syllabus_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.level_syllabus_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.level_syllabus_weeks_id_seq OWNED BY odiseo.level_syllabus_weeks.id;


--

--

CREATE SEQUENCE odiseo.material_ballot_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_ballot_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_ballot_question_id_seq OWNED BY odiseo.material_ballot_question.id;


--

--

CREATE SEQUENCE odiseo.material_ballot_stats_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_ballot_stats_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_ballot_stats_area_courses_id_seq OWNED BY odiseo.material_ballot_stats_area_courses.id;


--

--

CREATE SEQUENCE odiseo.material_ballot_stats_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_ballot_stats_areas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_ballot_stats_areas_id_seq OWNED BY odiseo.material_ballot_stats_areas.id;


--

--

CREATE SEQUENCE odiseo.material_ballot_stats_global_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_ballot_stats_global_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_ballot_stats_global_id_seq OWNED BY odiseo.material_ballot_stats_global.id;


--

--

CREATE SEQUENCE odiseo.material_ballot_subquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_ballot_subquestions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_ballot_subquestions_id_seq OWNED BY odiseo.material_ballot_subquestions.id;


--

--

CREATE SEQUENCE odiseo.material_class_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_class_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_class_week_id_seq OWNED BY odiseo.material_class_week.id;


--

--

CREATE SEQUENCE odiseo.material_column_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_column_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_column_configurations_id_seq OWNED BY odiseo.material_column_configurations.id;


--

--

CREATE SEQUENCE odiseo.material_configuration_detail_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_configuration_detail_value_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_configuration_detail_value_id_seq OWNED BY odiseo.material_configuration_detail_value.id;


--

--

CREATE SEQUENCE odiseo.material_configuration_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_configuration_details_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_configuration_details_id_seq OWNED BY odiseo.material_configuration_details.id;


--

--

CREATE SEQUENCE odiseo.material_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_configurations_id_seq OWNED BY odiseo.material_configurations.id;


--

--

CREATE SEQUENCE odiseo.material_distribution_ballot_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_distribution_ballot_questions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_distribution_ballot_questions_id_seq OWNED BY odiseo.material_distribution_ballot_questions.id;


--

--

CREATE SEQUENCE odiseo.material_exam_area_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_area_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_area_week_id_seq OWNED BY odiseo.material_exam_area_week.id;


--

--

CREATE SEQUENCE odiseo.material_exam_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_parent_question_id_seq OWNED BY odiseo.material_exam_parent_question.id;


--

--

CREATE SEQUENCE odiseo.material_exam_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_question_id_seq OWNED BY odiseo.material_exam_question.id;


--

--

CREATE SEQUENCE odiseo.material_exam_stats_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_stats_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_stats_area_courses_id_seq OWNED BY odiseo.material_exam_stats_area_courses.id;


--

--

CREATE SEQUENCE odiseo.material_exam_stats_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_stats_areas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_stats_areas_id_seq OWNED BY odiseo.material_exam_stats_areas.id;


--

--

CREATE SEQUENCE odiseo.material_exam_stats_global_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_exam_stats_global_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_exam_stats_global_id_seq OWNED BY odiseo.material_exam_stats_global.id;


--

--

CREATE SEQUENCE odiseo.material_generation_notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_generation_notification_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_generation_notification_types_id_seq OWNED BY odiseo.material_generation_notification_types.id;


--

--

CREATE SEQUENCE odiseo.material_generation_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_generation_notifications_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_generation_notifications_id_seq OWNED BY odiseo.material_generation_notifications.id;


--

--

CREATE SEQUENCE odiseo.material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_id_seq OWNED BY odiseo.material.id;


--

--

CREATE SEQUENCE odiseo.material_missing_question_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_missing_question_detail_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_missing_question_detail_id_seq OWNED BY odiseo.material_missing_question_detail.id;


--

--

CREATE SEQUENCE odiseo.material_missing_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_missing_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_missing_question_id_seq OWNED BY odiseo.material_missing_question.id;


--

--

CREATE SEQUENCE odiseo.material_missing_question_tracking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_missing_question_tracking_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_missing_question_tracking_id_seq OWNED BY odiseo.material_missing_question_tracking.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_ballot_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_ballot_class_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_ballot_class_id_seq OWNED BY odiseo.material_per_period_ballot_class.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_ballot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_ballot_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_ballot_id_seq OWNED BY odiseo.material_per_period_ballot.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_ballot_url_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_ballot_url_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_ballot_url_id_seq OWNED BY odiseo.material_per_period_ballot_url.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_course_id_seq OWNED BY odiseo.material_per_period_course.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_exam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_exam_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_exam_id_seq OWNED BY odiseo.material_per_period_exam.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_id_seq OWNED BY odiseo.material_per_period.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_level_limit_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_level_limit_config_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_level_limit_config_id_seq OWNED BY odiseo.material_per_period_level_limit_config.id;


--

--

CREATE SEQUENCE odiseo.material_per_period_week_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_per_period_week_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_per_period_week_course_id_seq OWNED BY odiseo.material_per_period_week_course.id;


--

--

CREATE SEQUENCE odiseo.material_question_change_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_question_change_reason_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_question_change_reason_id_seq OWNED BY odiseo.material_question_change_reason.id;


--

--

CREATE SEQUENCE odiseo.material_revision_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_revision_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_revision_courses_id_seq OWNED BY odiseo.material_revision_courses.id;


--

--

CREATE SEQUENCE odiseo.material_revision_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_revision_histories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_revision_histories_id_seq OWNED BY odiseo.material_revision_histories.id;


--

--

CREATE SEQUENCE odiseo.material_revision_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_revision_items_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_revision_items_id_seq OWNED BY odiseo.material_revision_items.id;


--

--

CREATE SEQUENCE odiseo.material_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.material_revisions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.material_revisions_id_seq OWNED BY odiseo.material_revisions.id;


--

--

CREATE SEQUENCE odiseo.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.migrations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.migrations_id_seq OWNED BY odiseo.migrations.id;


--

--

CREATE SEQUENCE odiseo.modality_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.modality_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.modality_id_seq OWNED BY odiseo.modality.id;


--

--

CREATE SEQUENCE odiseo.modality_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.modality_options_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.modality_options_id_seq OWNED BY odiseo.modality_options.id;


--

--

CREATE SEQUENCE odiseo.network_course_topic_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.network_course_topic_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.network_course_topic_subtopic_id_seq OWNED BY odiseo.network_course_topic_subtopic.id;


--

--

CREATE SEQUENCE odiseo.nq_user_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.nq_user_request_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.nq_user_request_id_seq OWNED BY odiseo.nq_user_request.id;


--

--

CREATE SEQUENCE odiseo.nq_user_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.nq_user_token_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.nq_user_token_id_seq OWNED BY odiseo.nq_user_token.id;


--

--

CREATE SEQUENCE odiseo.option_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.option_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.option_id_seq OWNED BY odiseo.option.id;


--

--

CREATE SEQUENCE odiseo.option_university_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.option_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.option_university_id_seq OWNED BY odiseo.option_university.id;


--

--

CREATE SEQUENCE odiseo.origin_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.origin_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.origin_parent_question_id_seq OWNED BY odiseo.origin_parent_question.id;


--

--

CREATE SEQUENCE odiseo.origin_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.origin_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.origin_question_id_seq OWNED BY odiseo.origin_question.id;


--

--

CREATE SEQUENCE odiseo.origin_question_nq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.origin_question_nq_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.origin_question_nq_id_seq OWNED BY odiseo.origin_question_nq.id;


--

--

CREATE SEQUENCE odiseo.origin_university_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.origin_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.origin_university_id_seq OWNED BY odiseo.origin_university.id;


--

--

CREATE SEQUENCE odiseo.parent_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.parent_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.parent_image_id_seq OWNED BY odiseo.parent_image.id;


--

--

CREATE SEQUENCE odiseo.parent_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.parent_observation_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.parent_observation_id_seq OWNED BY odiseo.parent_observation.id;


--

--

CREATE SEQUENCE odiseo.parent_question_correlative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.parent_question_correlative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.parent_question_correlative_id_seq OWNED BY odiseo.parent_question_correlative.id;


--

--

CREATE SEQUENCE odiseo.parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.parent_question_id_seq OWNED BY odiseo.parent_question.id;


--

--

CREATE SEQUENCE odiseo.periodicity_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.periodicity_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.periodicity_id_seq OWNED BY odiseo.periodicity.id;


--

--

CREATE SEQUENCE odiseo.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.permissions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.permissions_id_seq OWNED BY odiseo.permissions.id;


--

--

CREATE SEQUENCE odiseo.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.personal_access_tokens_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.personal_access_tokens_id_seq OWNED BY odiseo.personal_access_tokens.id;


--

--

CREATE SEQUENCE odiseo.plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.plans_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.plans_id_seq OWNED BY odiseo.plans.id;


--

--

CREATE SEQUENCE odiseo.prospect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.prospect_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.prospect_id_seq OWNED BY odiseo.prospect.id;


--

--

CREATE SEQUENCE odiseo.provinces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.provinces_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.provinces_id_seq OWNED BY odiseo.provinces.id;


--

--

CREATE SEQUENCE odiseo.pseudo_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.pseudo_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.pseudo_course_id_seq OWNED BY odiseo.pseudo_course.id;


--

--

CREATE SEQUENCE odiseo.question_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_attributes_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_attributes_id_seq OWNED BY odiseo.question_attributes.id;


--

--

CREATE SEQUENCE odiseo.question_attributes_type_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_attributes_type_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_attributes_type_course_id_seq OWNED BY odiseo.question_attributes_type_course.id;


--

--

CREATE SEQUENCE odiseo.question_attributes_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_attributes_type_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_attributes_type_id_seq OWNED BY odiseo.question_attributes_type.id;


--

--

CREATE SEQUENCE odiseo.question_attributes_types_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_attributes_types_values_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_attributes_types_values_id_seq OWNED BY odiseo.question_attributes_types_values.id;


--

--

CREATE SEQUENCE odiseo.question_correlative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_correlative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_correlative_id_seq OWNED BY odiseo.question_correlative.id;


--

--

CREATE SEQUENCE odiseo.question_excluded_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_excluded_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_excluded_material_id_seq OWNED BY odiseo.question_excluded_material.id;


--

--

CREATE SEQUENCE odiseo.question_field_diagrammed_nq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_field_diagrammed_nq_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_field_diagrammed_nq_id_seq OWNED BY odiseo.question_field_diagrammed_nq.id;


--

--

CREATE SEQUENCE odiseo.question_history_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_history_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_history_course_id_seq OWNED BY odiseo.question_history_course.id;


--

--

CREATE SEQUENCE odiseo.question_history_cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_history_cycle_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_history_cycle_id_seq OWNED BY odiseo.question_history_cycle.id;


--

--

CREATE SEQUENCE odiseo.question_history_usage_exam_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_history_usage_exam_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_history_usage_exam_parent_question_id_seq OWNED BY odiseo.question_history_usage_exam_parent_question.id;


--

--

CREATE SEQUENCE odiseo.question_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_ia_images_id_seq OWNED BY odiseo.question_ia_images.id;


--

--

CREATE SEQUENCE odiseo.question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_id_seq OWNED BY odiseo.question.id;


--

--

CREATE SEQUENCE odiseo.question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_image_id_seq OWNED BY odiseo.question_image.id;


--

--

CREATE SEQUENCE odiseo.question_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_maths_id_seq OWNED BY odiseo.question_maths.id;


--

--

CREATE SEQUENCE odiseo.question_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_observation_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_observation_id_seq OWNED BY odiseo.question_observation.id;


--

--

CREATE SEQUENCE odiseo.question_pdf_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_pdf_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_pdf_jobs_id_seq OWNED BY odiseo.question_pdf_jobs.id;


--

--

CREATE SEQUENCE odiseo.question_refuzed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_refuzed_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_refuzed_id_seq OWNED BY odiseo.question_refuzed.id;


--

--

CREATE SEQUENCE odiseo.question_secondary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_secondary_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_secondary_id_seq OWNED BY odiseo.question_secondary.id;


--

--

CREATE SEQUENCE odiseo.question_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_shares_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_shares_id_seq OWNED BY odiseo.question_shares.id;


--

--

CREATE SEQUENCE odiseo.question_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_status_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_status_id_seq OWNED BY odiseo.question_status.id;


--

--

CREATE SEQUENCE odiseo.question_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_subtopic_id_seq OWNED BY odiseo.question_subtopic.id;


--

--

CREATE SEQUENCE odiseo.question_teacher_ia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_teacher_ia_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_teacher_ia_id_seq OWNED BY odiseo.question_teacher_ia.id;


--

--

CREATE SEQUENCE odiseo.question_temporary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.question_temporary_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.question_temporary_id_seq OWNED BY odiseo.question_temporary.id;


--

--

CREATE SEQUENCE odiseo.region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.region_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.region_id_seq OWNED BY odiseo.region.id;


--

--

CREATE SEQUENCE odiseo.remembered_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.remembered_sessions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.remembered_sessions_id_seq OWNED BY odiseo.remembered_sessions.id;


--

--

CREATE SEQUENCE odiseo.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.roles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.roles_id_seq OWNED BY odiseo.roles.id;


--

--

CREATE SEQUENCE odiseo.roles_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.roles_permissions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.roles_permissions_id_seq OWNED BY odiseo.roles_permissions.id;


--

--

CREATE SEQUENCE odiseo.separated_material_exam_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.separated_material_exam_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.separated_material_exam_week_id_seq OWNED BY odiseo.separated_material_exam_week.id;


--

--

CREATE SEQUENCE odiseo.separated_material_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.separated_material_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.separated_material_week_id_seq OWNED BY odiseo.separated_material_week.id;


--

--

CREATE SEQUENCE odiseo.setting_diagrammed_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.setting_diagrammed_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.setting_diagrammed_courses_id_seq OWNED BY odiseo.setting_diagrammed_courses.id;


--

--

CREATE SEQUENCE odiseo.solution_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.solution_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.solution_ia_images_id_seq OWNED BY odiseo.solution_ia_images.id;


--

--

CREATE SEQUENCE odiseo.subtopic_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.subtopic_history_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.subtopic_history_id_seq OWNED BY odiseo.subtopic_history.id;


--

--

CREATE SEQUENCE odiseo.subtopic_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.subtopic_id_seq OWNED BY odiseo.subtopic.id;


--

--

CREATE SEQUENCE odiseo.syllabus_detail_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_detail_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_detail_subtopic_id_seq OWNED BY odiseo.syllabus_detail_subtopic.id;


--

--

CREATE SEQUENCE odiseo.syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_id_seq OWNED BY odiseo.syllabus.id;


--

--

CREATE SEQUENCE odiseo.syllabus_subtopic_type_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_subtopic_type_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_subtopic_type_material_id_seq OWNED BY odiseo.syllabus_subtopic_type_material.id;


--

--

CREATE SEQUENCE odiseo.syllabus_template_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_template_id_seq OWNED BY odiseo.syllabus_template.id;


--

--

CREATE SEQUENCE odiseo.syllabus_template_topic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_template_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_template_topic_id_seq OWNED BY odiseo.syllabus_template_topic.id;


--

--

CREATE SEQUENCE odiseo.syllabus_template_topic_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_template_topic_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_template_topic_subtopic_id_seq OWNED BY odiseo.syllabus_template_topic_subtopic.id;


--

--

CREATE SEQUENCE odiseo.syllabus_text_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_text_content_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_text_content_id_seq OWNED BY odiseo.syllabus_text_content.id;


--

--

CREATE SEQUENCE odiseo.syllabus_text_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_text_detail_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_text_detail_id_seq OWNED BY odiseo.syllabus_text_detail.id;


--

--

CREATE SEQUENCE odiseo.syllabus_text_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_text_distributions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_text_distributions_id_seq OWNED BY odiseo.syllabus_text_distributions.id;


--

--

CREATE SEQUENCE odiseo.syllabus_text_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_text_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_text_weeks_id_seq OWNED BY odiseo.syllabus_text_weeks.id;


--

--

CREATE SEQUENCE odiseo.syllabus_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_texts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_texts_id_seq OWNED BY odiseo.syllabus_texts.id;


--

--

CREATE SEQUENCE odiseo.syllabus_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_topic_id_seq OWNED BY odiseo.syllabus_topic.id;


--

--

CREATE SEQUENCE odiseo.syllabus_topic_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_topic_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_topic_week_id_seq OWNED BY odiseo.syllabus_topic_week.id;


--

--

CREATE SEQUENCE odiseo.syllabus_type_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_type_text_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_type_text_id_seq OWNED BY odiseo.syllabus_type_text.id;


--

--

CREATE SEQUENCE odiseo.syllabus_week_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.syllabus_week_titles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.syllabus_week_titles_id_seq OWNED BY odiseo.syllabus_week_titles.id;


--

--

CREATE SEQUENCE odiseo.teachers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.teachers_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.teachers_id_seq OWNED BY odiseo.teachers.id;


--

--

CREATE SEQUENCE odiseo.template_type_material_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.template_type_material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.template_type_material_configurations_id_seq OWNED BY odiseo.template_type_material_configurations.id;


--

--

CREATE SEQUENCE odiseo.template_type_material_courses_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.template_type_material_courses_order_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.template_type_material_courses_order_id_seq OWNED BY odiseo.template_type_material_courses_order.id;


--

--

CREATE SEQUENCE odiseo.topic_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.topic_id_seq OWNED BY odiseo.topic.id;


--

--

CREATE SEQUENCE odiseo.type_archive_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_archive_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_archive_id_seq OWNED BY odiseo.type_archive.id;


--

--

CREATE SEQUENCE odiseo.type_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_documents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_documents_id_seq OWNED BY odiseo.type_documents.id;


--

--

CREATE SEQUENCE odiseo.type_exams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_exams_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_exams_id_seq OWNED BY odiseo.type_exams.id;


--

--

CREATE SEQUENCE odiseo.type_material_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_area_courses_id_seq OWNED BY odiseo.type_material_area_courses.id;


--

--

CREATE SEQUENCE odiseo.type_material_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_area_id_seq OWNED BY odiseo.type_material_area.id;


--

--

CREATE SEQUENCE odiseo.type_material_bound_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_bound_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_bound_id_seq OWNED BY odiseo.type_material_bound.id;


--

--

CREATE SEQUENCE odiseo.type_material_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_course_id_seq OWNED BY odiseo.type_material_course.id;


--

--

CREATE SEQUENCE odiseo.type_material_detail_course_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_detail_course_texts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_detail_course_texts_id_seq OWNED BY odiseo.type_material_detail_course_texts.id;


--

--

CREATE SEQUENCE odiseo.type_material_detail_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_detail_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_detail_courses_id_seq OWNED BY odiseo.type_material_detail_courses.id;


--

--

CREATE SEQUENCE odiseo.type_material_detail_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_detail_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_detail_template_id_seq OWNED BY odiseo.type_material_detail_template.id;


--

--

CREATE SEQUENCE odiseo.type_material_detail_text_subquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_detail_text_subquestions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_detail_text_subquestions_id_seq OWNED BY odiseo.type_material_detail_text_subquestions.id;


--

--

CREATE SEQUENCE odiseo.type_material_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_id_seq OWNED BY odiseo.type_material.id;


--

--

CREATE SEQUENCE odiseo.type_material_periodicity_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_periodicity_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_periodicity_id_seq OWNED BY odiseo.type_material_periodicity.id;


--

--

CREATE SEQUENCE odiseo.type_material_template_configuration_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_template_configuration_columns_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_template_configuration_columns_id_seq OWNED BY odiseo.type_material_template_configuration_columns.id;


--

--

CREATE SEQUENCE odiseo.type_material_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_material_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_material_template_id_seq OWNED BY odiseo.type_material_template.id;


--

--

CREATE SEQUENCE odiseo.type_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_templates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_templates_id_seq OWNED BY odiseo.type_templates.id;


--

--

CREATE SEQUENCE odiseo.type_text_exam_material_configuration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_exam_material_configuration_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_exam_material_configuration_id_seq OWNED BY odiseo.type_text_exam_material_configuration.id;


--

--

CREATE SEQUENCE odiseo.type_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_id_seq OWNED BY odiseo.type_text.id;


--

--

CREATE SEQUENCE odiseo.type_text_level_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_level_id_seq OWNED BY odiseo.type_text_level.id;


--

--

CREATE SEQUENCE odiseo.type_text_material_type_course_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_material_type_course_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_material_type_course_area_id_seq OWNED BY odiseo.type_text_material_type_course_area.id;


--

--

CREATE SEQUENCE odiseo.type_text_material_type_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_material_type_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_material_type_course_id_seq OWNED BY odiseo.type_text_material_type_course.id;


--

--

CREATE SEQUENCE odiseo.type_text_subcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_subcategories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_subcategories_id_seq OWNED BY odiseo.type_text_subcategories.id;


--

--

CREATE SEQUENCE odiseo.type_text_templates_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_templates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_templates_id_seq OWNED BY odiseo.type_text_templates.id;


--

--

CREATE SEQUENCE odiseo.type_text_to_subcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_text_to_subcategory_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_text_to_subcategory_id_seq OWNED BY odiseo.type_text_to_subcategory.id;


--

--

CREATE SEQUENCE odiseo.type_texts_subtopics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_texts_subtopics_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_texts_subtopics_id_seq OWNED BY odiseo.type_texts_subtopics.id;


--

--

CREATE SEQUENCE odiseo.type_texts_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_texts_topics_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_texts_topics_id_seq OWNED BY odiseo.type_texts_topics.id;


--

--

CREATE SEQUENCE odiseo.type_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.type_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.type_week_id_seq OWNED BY odiseo.type_week.id;


--

--

CREATE SEQUENCE odiseo.university_headquarters_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.university_headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.university_headquarters_id_seq OWNED BY odiseo.university_headquarters.id;


--

--

CREATE SEQUENCE odiseo.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.users_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.users_id_seq OWNED BY odiseo.users.id;


--

--

CREATE SEQUENCE odiseo.users_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.users_roles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.users_roles_id_seq OWNED BY odiseo.users_roles.id;


--

--

CREATE SEQUENCE odiseo.week_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE odiseo.week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE odiseo.week_id_seq OWNED BY odiseo.week.id;


--

--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--

--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--

--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--

--

CREATE SEQUENCE public.type_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_documents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE public.type_documents_id_seq OWNED BY public.type_documents.id;


--

--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--

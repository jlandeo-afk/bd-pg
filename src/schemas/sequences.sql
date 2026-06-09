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

CREATE SEQUENCE common.advanced_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.advanced_settings_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.advanced_settings_id_seq OWNED BY common.advanced_settings.id;


--

--

CREATE SEQUENCE questions.alternative_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.alternative_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.alternative_ia_images_id_seq OWNED BY questions.alternative_ia_images.id;


--

--

CREATE SEQUENCE questions.alternative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.alternative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.alternative_id_seq OWNED BY questions.alternative.id;


--

--

CREATE SEQUENCE questions.alternative_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.alternative_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.alternative_maths_id_seq OWNED BY questions.alternative_maths.id;


--

--

CREATE SEQUENCE questions.alternative_questions_ia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.alternative_questions_ia_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.alternative_questions_ia_id_seq OWNED BY questions.alternative_questions_ia.id;


--

--

CREATE SEQUENCE exams.area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE exams.area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE exams.area_id_seq OWNED BY exams.area.id;


--

--

CREATE SEQUENCE common.category_rejected_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.category_rejected_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.category_rejected_id_seq OWNED BY common.category_rejected.id;


--

--

CREATE SEQUENCE organization.charge_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.charge_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.charge_id_seq OWNED BY organization.charge.id;


--

--

CREATE SEQUENCE organization.classroom_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.classroom_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.classroom_id_seq OWNED BY organization.classroom.id;


--

--

CREATE SEQUENCE organization.clientes_empresas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.clientes_empresas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.clientes_empresas_id_seq OWNED BY organization.clientes_empresas.id;


--

--

CREATE SEQUENCE common.code_prospect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.code_prospect_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.code_prospect_id_seq OWNED BY common.code_prospect.id;


--

--

CREATE SEQUENCE organization.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.companies_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.companies_id_seq OWNED BY organization.companies.id;


--

--

CREATE SEQUENCE organization.company_headquarters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.company_headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.company_headquarters_id_seq OWNED BY organization.company_headquarters.id;


--

--

CREATE SEQUENCE organization.company_legal_representatives_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.company_legal_representatives_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.company_legal_representatives_id_seq OWNED BY organization.company_legal_representatives.id;


--

--

CREATE SEQUENCE organization.company_universities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.company_universities_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.company_universities_id_seq OWNED BY organization.company_universities.id;


--

--

CREATE SEQUENCE organization.company_user_admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.company_user_admin_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.company_user_admin_id_seq OWNED BY organization.company_user_admin.id;


--

--

CREATE SEQUENCE questions.configuration_alternative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.configuration_alternative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.configuration_alternative_id_seq OWNED BY questions.configuration_alternative.id;


--

--

CREATE SEQUENCE academic.course_assigned_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_assigned_categories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_assigned_categories_id_seq OWNED BY academic.course_assigned_categories.id;


--

--

CREATE SEQUENCE academic.course_assigned_subcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_assigned_subcategories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_assigned_subcategories_id_seq OWNED BY academic.course_assigned_subcategories.id;


--

--

CREATE SEQUENCE academic.course_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_id_seq OWNED BY academic.course.id;


--

--

CREATE SEQUENCE academic.course_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_level_id_seq OWNED BY academic.course_level.id;


--

--

CREATE SEQUENCE academic.course_pseudo_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_pseudo_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_pseudo_course_id_seq OWNED BY academic.course_pseudo_course.id;


--

--

CREATE SEQUENCE academic.course_pseudo_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_pseudo_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_pseudo_courses_id_seq OWNED BY academic.course_pseudo_courses.id;


--

--

CREATE SEQUENCE academic.course_text_category_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.course_text_category_settings_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.course_text_category_settings_id_seq OWNED BY academic.course_text_category_settings.id;


--

--

CREATE SEQUENCE academic.cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.cycle_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.cycle_id_seq OWNED BY academic.cycle.id;


--

--

CREATE SEQUENCE academic.cycle_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.cycle_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.cycle_types_id_seq OWNED BY academic.cycle_types.id;


--

--

CREATE SEQUENCE academic.cycle_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.cycle_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.cycle_weeks_id_seq OWNED BY academic.cycle_weeks.id;


--

--

CREATE SEQUENCE academic.detail_level_syllabus_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.detail_level_syllabus_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.detail_level_syllabus_weeks_id_seq OWNED BY academic.detail_level_syllabus_weeks.id;


--

--

CREATE SEQUENCE academic.detail_level_syllabus_weeks_parents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.detail_level_syllabus_weeks_parents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.detail_level_syllabus_weeks_parents_id_seq OWNED BY academic.detail_level_syllabus_weeks_parents.id;


--

--

CREATE SEQUENCE academic.detail_week_type_mat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.detail_week_type_mat_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.detail_week_type_mat_id_seq OWNED BY academic.detail_week_type_mat.id;


--

--

CREATE SEQUENCE questions.didi_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.didi_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.didi_maths_id_seq OWNED BY questions.didi_maths.id;


--

--

CREATE SEQUENCE organization.districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.districts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.districts_id_seq OWNED BY organization.districts.id;


--

--

CREATE SEQUENCE organization.employee_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.employee_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.employee_course_id_seq OWNED BY organization.employee_course.id;


--

--

CREATE SEQUENCE questions.employee_didi_question_field_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_didi_question_field_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_didi_question_field_id_seq OWNED BY questions.employee_didi_question_field.id;


--

--

ALTER TABLE questions.employee_didi_question_field_image ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME questions.employee_didi_question_field_image_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--

--

CREATE SEQUENCE questions.employee_didi_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_didi_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_didi_question_id_seq OWNED BY questions.employee_didi_question.id;


--

--

CREATE SEQUENCE questions.employee_didi_question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_didi_question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_didi_question_image_id_seq OWNED BY questions.employee_didi_question_image.id;


--

--

CREATE SEQUENCE questions.employee_question_document_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_question_document_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_question_document_id_seq OWNED BY questions.employee_question_document.id;


--

--

CREATE SEQUENCE questions.employee_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_question_id_seq OWNED BY questions.employee_question.id;


--

--

CREATE SEQUENCE questions.employee_question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_question_image_id_seq OWNED BY questions.employee_question_image.id;


--

--

CREATE SEQUENCE questions.employee_question_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.employee_question_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.employee_question_maths_id_seq OWNED BY questions.employee_question_maths.id;


--

--

CREATE SEQUENCE organization.employee_university_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.employee_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.employee_university_id_seq OWNED BY organization.employee_university.id;


--

--

CREATE SEQUENCE organization.employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.employees_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.employees_id_seq OWNED BY organization.employees.id;


--

--

CREATE SEQUENCE questions.essential_knowledge_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.essential_knowledge_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.essential_knowledge_image_id_seq OWNED BY questions.essential_knowledge_image.id;


--

--

CREATE SEQUENCE questions.essential_knowledge_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.essential_knowledge_questions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.essential_knowledge_questions_id_seq OWNED BY questions.essential_knowledge_questions.id;


--

--

CREATE SEQUENCE questions.essential_knowledges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.essential_knowledges_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.essential_knowledges_id_seq OWNED BY questions.essential_knowledges.id;


--

--

CREATE SEQUENCE exams.exam_area_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE exams.exam_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE exams.exam_area_id_seq OWNED BY exams.exam_area.id;


--

--

CREATE SEQUENCE materials.exam_material_config_area_course_levels_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.exam_material_config_area_course_levels_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.exam_material_config_area_course_levels_id_seq OWNED BY materials.exam_material_config_area_course_levels.id;


--

--

CREATE SEQUENCE materials.exam_material_config_area_courses_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.exam_material_config_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.exam_material_config_area_courses_id_seq OWNED BY materials.exam_material_config_area_courses.id;


--

--

CREATE SEQUENCE materials.exam_material_configurations_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.exam_material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.exam_material_configurations_id_seq OWNED BY materials.exam_material_configurations.id;


--

--

CREATE SEQUENCE common.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.failed_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.failed_jobs_id_seq OWNED BY common.failed_jobs.id;


--

--

CREATE SEQUENCE questions.field_diagrammed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.field_diagrammed_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.field_diagrammed_id_seq OWNED BY questions.field_diagrammed.id;


--

--

CREATE SEQUENCE academic.frequent_university_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.frequent_university_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.frequent_university_subtopic_id_seq OWNED BY academic.frequent_university_subtopic.id;


--

--

CREATE SEQUENCE organization.headquarters_classroom_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.headquarters_classroom_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.headquarters_classroom_id_seq OWNED BY organization.headquarters_classroom.id;


--

--

CREATE SEQUENCE organization.headquarters_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.headquarters_id_seq OWNED BY organization.headquarters.id;


--

--

CREATE SEQUENCE questions.history_digitalized_solution_question_pdf_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.history_digitalized_solution_question_pdf_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.history_digitalized_solution_question_pdf_id_seq OWNED BY questions.history_digitalized_solution_question_pdf.id;


--

--

CREATE SEQUENCE academic.history_syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.history_syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.history_syllabus_id_seq OWNED BY academic.history_syllabus.id;


--

--

CREATE SEQUENCE questions.image_galery_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.image_galery_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.image_galery_topic_id_seq OWNED BY questions.image_galery_topic.id;


--

--

CREATE SEQUENCE questions.image_gallery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.image_gallery_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.image_gallery_id_seq OWNED BY questions.image_gallery.id;


--

--

CREATE SEQUENCE common.importance_rejected_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.importance_rejected_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.importance_rejected_id_seq OWNED BY common.importance_rejected.id;


--

--

CREATE SEQUENCE common.individual_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.individual_notifications_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.individual_notifications_id_seq OWNED BY common.individual_notifications.id;


--

--

CREATE SEQUENCE academic.institution_types_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.institution_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.institution_types_id_seq OWNED BY academic.institution_types.id;


--

--

CREATE SEQUENCE academic.level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.level_id_seq OWNED BY academic.level.id;


--

--

CREATE SEQUENCE academic.level_rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.level_rates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.level_rates_id_seq OWNED BY academic.level_rates.id;


--

--

CREATE SEQUENCE academic.level_syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.level_syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.level_syllabus_id_seq OWNED BY academic.level_syllabus.id;


--

--

CREATE SEQUENCE academic.level_syllabus_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.level_syllabus_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.level_syllabus_weeks_id_seq OWNED BY academic.level_syllabus_weeks.id;


--

--

CREATE SEQUENCE materials.material_ballot_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_ballot_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_ballot_question_id_seq OWNED BY materials.material_ballot_question.id;


--

--

CREATE SEQUENCE materials.material_ballot_stats_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_ballot_stats_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_ballot_stats_area_courses_id_seq OWNED BY materials.material_ballot_stats_area_courses.id;


--

--

CREATE SEQUENCE materials.material_ballot_stats_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_ballot_stats_areas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_ballot_stats_areas_id_seq OWNED BY materials.material_ballot_stats_areas.id;


--

--

CREATE SEQUENCE materials.material_ballot_stats_global_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_ballot_stats_global_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_ballot_stats_global_id_seq OWNED BY materials.material_ballot_stats_global.id;


--

--

CREATE SEQUENCE materials.material_ballot_subquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_ballot_subquestions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_ballot_subquestions_id_seq OWNED BY materials.material_ballot_subquestions.id;


--

--

CREATE SEQUENCE materials.material_class_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_class_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_class_week_id_seq OWNED BY materials.material_class_week.id;


--

--

CREATE SEQUENCE materials.material_column_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_column_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_column_configurations_id_seq OWNED BY materials.material_column_configurations.id;


--

--

CREATE SEQUENCE materials.material_configuration_detail_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_configuration_detail_value_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_configuration_detail_value_id_seq OWNED BY materials.material_configuration_detail_value.id;


--

--

CREATE SEQUENCE materials.material_configuration_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_configuration_details_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_configuration_details_id_seq OWNED BY materials.material_configuration_details.id;


--

--

CREATE SEQUENCE materials.material_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_configurations_id_seq OWNED BY materials.material_configurations.id;


--

--

CREATE SEQUENCE materials.material_distribution_ballot_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_distribution_ballot_questions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_distribution_ballot_questions_id_seq OWNED BY materials.material_distribution_ballot_questions.id;


--

--

CREATE SEQUENCE materials.material_exam_area_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_area_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_area_week_id_seq OWNED BY materials.material_exam_area_week.id;


--

--

CREATE SEQUENCE materials.material_exam_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_parent_question_id_seq OWNED BY materials.material_exam_parent_question.id;


--

--

CREATE SEQUENCE materials.material_exam_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_question_id_seq OWNED BY materials.material_exam_question.id;


--

--

CREATE SEQUENCE materials.material_exam_stats_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_stats_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_stats_area_courses_id_seq OWNED BY materials.material_exam_stats_area_courses.id;


--

--

CREATE SEQUENCE materials.material_exam_stats_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_stats_areas_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_stats_areas_id_seq OWNED BY materials.material_exam_stats_areas.id;


--

--

CREATE SEQUENCE materials.material_exam_stats_global_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_exam_stats_global_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_exam_stats_global_id_seq OWNED BY materials.material_exam_stats_global.id;


--

--

CREATE SEQUENCE materials.material_generation_notification_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_generation_notification_types_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_generation_notification_types_id_seq OWNED BY materials.material_generation_notification_types.id;


--

--

CREATE SEQUENCE materials.material_generation_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_generation_notifications_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_generation_notifications_id_seq OWNED BY materials.material_generation_notifications.id;


--

--

CREATE SEQUENCE materials.material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_id_seq OWNED BY materials.material.id;


--

--

CREATE SEQUENCE materials.material_missing_question_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_missing_question_detail_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_missing_question_detail_id_seq OWNED BY materials.material_missing_question_detail.id;


--

--

CREATE SEQUENCE materials.material_missing_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_missing_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_missing_question_id_seq OWNED BY materials.material_missing_question.id;


--

--

CREATE SEQUENCE materials.material_missing_question_tracking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_missing_question_tracking_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_missing_question_tracking_id_seq OWNED BY materials.material_missing_question_tracking.id;


--

--

CREATE SEQUENCE materials.material_per_period_ballot_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_ballot_class_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_ballot_class_id_seq OWNED BY materials.material_per_period_ballot_class.id;


--

--

CREATE SEQUENCE materials.material_per_period_ballot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_ballot_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_ballot_id_seq OWNED BY materials.material_per_period_ballot.id;


--

--

CREATE SEQUENCE materials.material_per_period_ballot_url_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_ballot_url_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_ballot_url_id_seq OWNED BY materials.material_per_period_ballot_url.id;


--

--

CREATE SEQUENCE materials.material_per_period_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_course_id_seq OWNED BY materials.material_per_period_course.id;


--

--

CREATE SEQUENCE materials.material_per_period_exam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_exam_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_exam_id_seq OWNED BY materials.material_per_period_exam.id;


--

--

CREATE SEQUENCE materials.material_per_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_id_seq OWNED BY materials.material_per_period.id;


--

--

CREATE SEQUENCE materials.material_per_period_level_limit_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_level_limit_config_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_level_limit_config_id_seq OWNED BY materials.material_per_period_level_limit_config.id;


--

--

CREATE SEQUENCE materials.material_per_period_week_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_per_period_week_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_per_period_week_course_id_seq OWNED BY materials.material_per_period_week_course.id;


--

--

CREATE SEQUENCE materials.material_question_change_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_question_change_reason_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_question_change_reason_id_seq OWNED BY materials.material_question_change_reason.id;


--

--

CREATE SEQUENCE materials.material_revision_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_revision_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_revision_courses_id_seq OWNED BY materials.material_revision_courses.id;


--

--

CREATE SEQUENCE materials.material_revision_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_revision_histories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_revision_histories_id_seq OWNED BY materials.material_revision_histories.id;


--

--

CREATE SEQUENCE materials.material_revision_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_revision_items_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_revision_items_id_seq OWNED BY materials.material_revision_items.id;


--

--

CREATE SEQUENCE materials.material_revisions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.material_revisions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.material_revisions_id_seq OWNED BY materials.material_revisions.id;


--

--

CREATE SEQUENCE common.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.migrations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.migrations_id_seq OWNED BY common.migrations.id;


--

--

CREATE SEQUENCE academic.modality_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.modality_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.modality_id_seq OWNED BY academic.modality.id;


--

--

CREATE SEQUENCE academic.modality_options_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.modality_options_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.modality_options_id_seq OWNED BY academic.modality_options.id;


--

--

CREATE SEQUENCE academic.network_course_topic_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.network_course_topic_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.network_course_topic_subtopic_id_seq OWNED BY academic.network_course_topic_subtopic.id;


--

--

CREATE SEQUENCE auth.nq_user_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.nq_user_request_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.nq_user_request_id_seq OWNED BY auth.nq_user_request.id;


--

--

CREATE SEQUENCE auth.nq_user_token_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.nq_user_token_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.nq_user_token_id_seq OWNED BY auth.nq_user_token.id;


--

--

CREATE SEQUENCE academic.option_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.option_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.option_id_seq OWNED BY academic.option.id;


--

--

CREATE SEQUENCE academic.option_university_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.option_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.option_university_id_seq OWNED BY academic.option_university.id;


--

--

CREATE SEQUENCE questions.origin_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.origin_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.origin_parent_question_id_seq OWNED BY questions.origin_parent_question.id;


--

--

CREATE SEQUENCE questions.origin_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.origin_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.origin_question_id_seq OWNED BY questions.origin_question.id;


--

--

CREATE SEQUENCE questions.origin_question_nq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.origin_question_nq_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.origin_question_nq_id_seq OWNED BY questions.origin_question_nq.id;


--

--

CREATE SEQUENCE academic.origin_university_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.origin_university_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.origin_university_id_seq OWNED BY academic.origin_university.id;


--

--

CREATE SEQUENCE questions.parent_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.parent_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.parent_image_id_seq OWNED BY questions.parent_image.id;


--

--

CREATE SEQUENCE questions.parent_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.parent_observation_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.parent_observation_id_seq OWNED BY questions.parent_observation.id;


--

--

CREATE SEQUENCE questions.parent_question_correlative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.parent_question_correlative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.parent_question_correlative_id_seq OWNED BY questions.parent_question_correlative.id;


--

--

CREATE SEQUENCE questions.parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.parent_question_id_seq OWNED BY questions.parent_question.id;


--

--

CREATE SEQUENCE materials.periodicity_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.periodicity_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.periodicity_id_seq OWNED BY materials.periodicity.id;


--

--

CREATE SEQUENCE auth.permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.permissions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.permissions_id_seq OWNED BY auth.permissions.id;


--

--

CREATE SEQUENCE auth.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.personal_access_tokens_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.personal_access_tokens_id_seq OWNED BY auth.personal_access_tokens.id;


--

--

CREATE SEQUENCE common.plans_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.plans_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.plans_id_seq OWNED BY common.plans.id;


--

--

CREATE SEQUENCE common.prospect_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.prospect_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.prospect_id_seq OWNED BY common.prospect.id;


--

--

CREATE SEQUENCE organization.provinces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.provinces_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.provinces_id_seq OWNED BY organization.provinces.id;


--

--

CREATE SEQUENCE academic.pseudo_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.pseudo_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.pseudo_course_id_seq OWNED BY academic.pseudo_course.id;


--

--

CREATE SEQUENCE questions.question_attributes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_attributes_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_attributes_id_seq OWNED BY questions.question_attributes.id;


--

--

CREATE SEQUENCE questions.question_attributes_type_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_attributes_type_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_attributes_type_course_id_seq OWNED BY questions.question_attributes_type_course.id;


--

--

CREATE SEQUENCE questions.question_attributes_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_attributes_type_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_attributes_type_id_seq OWNED BY questions.question_attributes_type.id;


--

--

CREATE SEQUENCE questions.question_attributes_types_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_attributes_types_values_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_attributes_types_values_id_seq OWNED BY questions.question_attributes_types_values.id;


--

--

CREATE SEQUENCE questions.question_correlative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_correlative_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_correlative_id_seq OWNED BY questions.question_correlative.id;


--

--

CREATE SEQUENCE questions.question_excluded_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_excluded_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_excluded_material_id_seq OWNED BY questions.question_excluded_material.id;


--

--

CREATE SEQUENCE questions.question_field_diagrammed_nq_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_field_diagrammed_nq_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_field_diagrammed_nq_id_seq OWNED BY questions.question_field_diagrammed_nq.id;


--

--

CREATE SEQUENCE questions.question_history_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_history_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_history_course_id_seq OWNED BY questions.question_history_course.id;


--

--

CREATE SEQUENCE questions.question_history_cycle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_history_cycle_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_history_cycle_id_seq OWNED BY questions.question_history_cycle.id;


--

--

CREATE SEQUENCE questions.question_history_usage_exam_parent_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_history_usage_exam_parent_question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_history_usage_exam_parent_question_id_seq OWNED BY questions.question_history_usage_exam_parent_question.id;


--

--

CREATE SEQUENCE questions.question_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_ia_images_id_seq OWNED BY questions.question_ia_images.id;


--

--

CREATE SEQUENCE questions.question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_id_seq OWNED BY questions.question.id;


--

--

CREATE SEQUENCE questions.question_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_image_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_image_id_seq OWNED BY questions.question_image.id;


--

--

CREATE SEQUENCE questions.question_maths_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_maths_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_maths_id_seq OWNED BY questions.question_maths.id;


--

--

CREATE SEQUENCE questions.question_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_observation_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_observation_id_seq OWNED BY questions.question_observation.id;


--

--

CREATE SEQUENCE questions.question_pdf_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_pdf_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_pdf_jobs_id_seq OWNED BY questions.question_pdf_jobs.id;


--

--

CREATE SEQUENCE questions.question_refuzed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_refuzed_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_refuzed_id_seq OWNED BY questions.question_refuzed.id;


--

--

CREATE SEQUENCE questions.question_secondary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_secondary_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_secondary_id_seq OWNED BY questions.question_secondary.id;


--

--

CREATE SEQUENCE questions.question_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_shares_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_shares_id_seq OWNED BY questions.question_shares.id;


--

--

CREATE SEQUENCE questions.question_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_status_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_status_id_seq OWNED BY questions.question_status.id;


--

--

CREATE SEQUENCE questions.question_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_subtopic_id_seq OWNED BY questions.question_subtopic.id;


--

--

CREATE SEQUENCE questions.question_teacher_ia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_teacher_ia_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_teacher_ia_id_seq OWNED BY questions.question_teacher_ia.id;


--

--

CREATE SEQUENCE questions.question_temporary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.question_temporary_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.question_temporary_id_seq OWNED BY questions.question_temporary.id;


--

--

CREATE SEQUENCE organization.region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.region_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.region_id_seq OWNED BY organization.region.id;


--

--

CREATE SEQUENCE auth.remembered_sessions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.remembered_sessions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.remembered_sessions_id_seq OWNED BY auth.remembered_sessions.id;


--

--

CREATE SEQUENCE auth.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.roles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.roles_id_seq OWNED BY auth.roles.id;


--

--

CREATE SEQUENCE auth.roles_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.roles_permissions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.roles_permissions_id_seq OWNED BY auth.roles_permissions.id;


--

--

CREATE SEQUENCE materials.separated_material_exam_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.separated_material_exam_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.separated_material_exam_week_id_seq OWNED BY materials.separated_material_exam_week.id;


--

--

CREATE SEQUENCE materials.separated_material_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.separated_material_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.separated_material_week_id_seq OWNED BY materials.separated_material_week.id;


--

--

CREATE SEQUENCE academic.setting_diagrammed_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.setting_diagrammed_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.setting_diagrammed_courses_id_seq OWNED BY academic.setting_diagrammed_courses.id;


--

--

CREATE SEQUENCE questions.solution_ia_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE questions.solution_ia_images_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE questions.solution_ia_images_id_seq OWNED BY questions.solution_ia_images.id;


--

--

CREATE SEQUENCE academic.subtopic_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.subtopic_history_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.subtopic_history_id_seq OWNED BY academic.subtopic_history.id;


--

--

CREATE SEQUENCE academic.subtopic_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.subtopic_id_seq OWNED BY academic.subtopic.id;


--

--

CREATE SEQUENCE academic.syllabus_detail_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_detail_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_detail_subtopic_id_seq OWNED BY academic.syllabus_detail_subtopic.id;


--

--

CREATE SEQUENCE academic.syllabus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_id_seq OWNED BY academic.syllabus.id;


--

--

CREATE SEQUENCE academic.syllabus_subtopic_type_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_subtopic_type_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_subtopic_type_material_id_seq OWNED BY academic.syllabus_subtopic_type_material.id;


--

--

CREATE SEQUENCE academic.syllabus_template_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_template_id_seq OWNED BY academic.syllabus_template.id;


--

--

CREATE SEQUENCE academic.syllabus_template_topic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_template_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_template_topic_id_seq OWNED BY academic.syllabus_template_topic.id;


--

--

CREATE SEQUENCE academic.syllabus_template_topic_subtopic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_template_topic_subtopic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_template_topic_subtopic_id_seq OWNED BY academic.syllabus_template_topic_subtopic.id;


--

--

CREATE SEQUENCE academic.syllabus_text_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_text_content_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_text_content_id_seq OWNED BY academic.syllabus_text_content.id;


--

--

CREATE SEQUENCE academic.syllabus_text_detail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_text_detail_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_text_detail_id_seq OWNED BY academic.syllabus_text_detail.id;


--

--

CREATE SEQUENCE academic.syllabus_text_distributions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_text_distributions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_text_distributions_id_seq OWNED BY academic.syllabus_text_distributions.id;


--

--

CREATE SEQUENCE academic.syllabus_text_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_text_weeks_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_text_weeks_id_seq OWNED BY academic.syllabus_text_weeks.id;


--

--

CREATE SEQUENCE academic.syllabus_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_texts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_texts_id_seq OWNED BY academic.syllabus_texts.id;


--

--

CREATE SEQUENCE academic.syllabus_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_topic_id_seq OWNED BY academic.syllabus_topic.id;


--

--

CREATE SEQUENCE academic.syllabus_topic_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_topic_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_topic_week_id_seq OWNED BY academic.syllabus_topic_week.id;


--

--

CREATE SEQUENCE academic.syllabus_type_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_type_text_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_type_text_id_seq OWNED BY academic.syllabus_type_text.id;


--

--

CREATE SEQUENCE academic.syllabus_week_titles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.syllabus_week_titles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.syllabus_week_titles_id_seq OWNED BY academic.syllabus_week_titles.id;


--

--

CREATE SEQUENCE organization.teachers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE organization.teachers_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE organization.teachers_id_seq OWNED BY organization.teachers.id;


--

--

CREATE SEQUENCE materials.template_type_material_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.template_type_material_configurations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.template_type_material_configurations_id_seq OWNED BY materials.template_type_material_configurations.id;


--

--

CREATE SEQUENCE materials.template_type_material_courses_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.template_type_material_courses_order_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.template_type_material_courses_order_id_seq OWNED BY materials.template_type_material_courses_order.id;


--

--

CREATE SEQUENCE academic.topic_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.topic_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.topic_id_seq OWNED BY academic.topic.id;


--

--

CREATE SEQUENCE common.type_archive_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_archive_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_archive_id_seq OWNED BY common.type_archive.id;


--

--

CREATE SEQUENCE common.type_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_documents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_documents_id_seq OWNED BY common.type_documents.id;


--

--

CREATE SEQUENCE exams.type_exams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE exams.type_exams_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE exams.type_exams_id_seq OWNED BY exams.type_exams.id;


--

--

CREATE SEQUENCE materials.type_material_area_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_area_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_area_courses_id_seq OWNED BY materials.type_material_area_courses.id;


--

--

CREATE SEQUENCE materials.type_material_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_area_id_seq OWNED BY materials.type_material_area.id;


--

--

CREATE SEQUENCE materials.type_material_bound_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_bound_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_bound_id_seq OWNED BY materials.type_material_bound.id;


--

--

CREATE SEQUENCE materials.type_material_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_course_id_seq OWNED BY materials.type_material_course.id;


--

--

CREATE SEQUENCE materials.type_material_detail_course_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_detail_course_texts_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_detail_course_texts_id_seq OWNED BY materials.type_material_detail_course_texts.id;


--

--

CREATE SEQUENCE materials.type_material_detail_courses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_detail_courses_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_detail_courses_id_seq OWNED BY materials.type_material_detail_courses.id;


--

--

CREATE SEQUENCE materials.type_material_detail_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_detail_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_detail_template_id_seq OWNED BY materials.type_material_detail_template.id;


--

--

CREATE SEQUENCE materials.type_material_detail_text_subquestions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_detail_text_subquestions_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_detail_text_subquestions_id_seq OWNED BY materials.type_material_detail_text_subquestions.id;


--

--

CREATE SEQUENCE materials.type_material_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_id_seq OWNED BY materials.type_material.id;


--

--

CREATE SEQUENCE materials.type_material_periodicity_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_periodicity_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_periodicity_id_seq OWNED BY materials.type_material_periodicity.id;


--

--

CREATE SEQUENCE materials.type_material_template_configuration_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_template_configuration_columns_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_template_configuration_columns_id_seq OWNED BY materials.type_material_template_configuration_columns.id;


--

--

CREATE SEQUENCE materials.type_material_template_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_material_template_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_material_template_id_seq OWNED BY materials.type_material_template.id;


--

--

CREATE SEQUENCE common.type_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_templates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_templates_id_seq OWNED BY common.type_templates.id;


--

--

CREATE SEQUENCE materials.type_text_exam_material_configuration_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_text_exam_material_configuration_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_text_exam_material_configuration_id_seq OWNED BY materials.type_text_exam_material_configuration.id;


--

--

CREATE SEQUENCE common.type_text_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_text_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_text_id_seq OWNED BY common.type_text.id;


--

--

CREATE SEQUENCE common.type_text_level_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_text_level_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_text_level_id_seq OWNED BY common.type_text_level.id;


--

--

CREATE SEQUENCE materials.type_text_material_type_course_area_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_text_material_type_course_area_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_text_material_type_course_area_id_seq OWNED BY materials.type_text_material_type_course_area.id;


--

--

CREATE SEQUENCE materials.type_text_material_type_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE materials.type_text_material_type_course_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE materials.type_text_material_type_course_id_seq OWNED BY materials.type_text_material_type_course.id;


--

--

CREATE SEQUENCE common.type_text_subcategories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_text_subcategories_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_text_subcategories_id_seq OWNED BY common.type_text_subcategories.id;


--

--

CREATE SEQUENCE common.type_text_templates_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_text_templates_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_text_templates_id_seq OWNED BY common.type_text_templates.id;


--

--

CREATE SEQUENCE common.type_text_to_subcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_text_to_subcategory_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_text_to_subcategory_id_seq OWNED BY common.type_text_to_subcategory.id;


--

--

CREATE SEQUENCE common.type_texts_subtopics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_texts_subtopics_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_texts_subtopics_id_seq OWNED BY common.type_texts_subtopics.id;


--

--

CREATE SEQUENCE common.type_texts_topics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_texts_topics_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_texts_topics_id_seq OWNED BY common.type_texts_topics.id;


--

--

CREATE SEQUENCE academic.type_week_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.type_week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.type_week_id_seq OWNED BY academic.type_week.id;


--

--

CREATE SEQUENCE academic.university_headquarters_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.university_headquarters_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.university_headquarters_id_seq OWNED BY academic.university_headquarters.id;


--

--

CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.users_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;


--

--

CREATE SEQUENCE auth.users_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.users_roles_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.users_roles_id_seq OWNED BY auth.users_roles.id;


--

--

CREATE SEQUENCE academic.week_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE academic.week_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE academic.week_id_seq OWNED BY academic.week.id;


--

--

CREATE SEQUENCE common.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.failed_jobs_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.failed_jobs_id_seq OWNED BY common.failed_jobs.id;


--

--

CREATE SEQUENCE common.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.migrations_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.migrations_id_seq OWNED BY common.migrations.id;


--

--

CREATE SEQUENCE auth.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.personal_access_tokens_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.personal_access_tokens_id_seq OWNED BY auth.personal_access_tokens.id;


--

--

CREATE SEQUENCE common.type_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE common.type_documents_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE common.type_documents_id_seq OWNED BY common.type_documents.id;


--

--

CREATE SEQUENCE auth.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.users_id_seq OWNER TO postgres;

--

--

ALTER SEQUENCE auth.users_id_seq OWNED BY auth.users.id;


--

-- Table: materials.material_exam_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_question (
    id bigint NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id bigint NOT NULL,
    question_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    material_exam_area_week_id bigint,
    question_history_id bigint,
    "position" smallint,
    fl_is_manual boolean DEFAULT false NOT NULL,
    type character varying(20)
);


ALTER TABLE materials.material_exam_question OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT material_exam_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_material_exam_area_week_id_foreig FOREIGN KEY (material_exam_area_week_id) REFERENCES materials.material_exam_area_week(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_question_history_id_foreign FOREIGN KEY (question_history_id) REFERENCES questions.question_history_cycle(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE ONLY materials.material_exam_question
    ADD CONSTRAINT odiseo_material_exam_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

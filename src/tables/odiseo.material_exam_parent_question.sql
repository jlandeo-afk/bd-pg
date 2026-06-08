-- Table: odiseo.material_exam_parent_question
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_exam_parent_question (
    id bigint NOT NULL,
    material_exam_area_week_id bigint NOT NULL,
    course_id smallint NOT NULL,
    parent_question_id bigint,
    subquestion jsonb,
    question_history_id bigint,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    "position" smallint,
    random boolean,
    expected_level smallint,
    current_level smallint
);


ALTER TABLE odiseo.material_exam_parent_question OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT uq_parent_question_in_area UNIQUE (material_exam_area_week_id, course_id, parent_question_id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_current_level_foreign FOREIGN KEY (current_level) REFERENCES odiseo.type_text_level(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_expected_level_foreign FOREIGN KEY (expected_level) REFERENCES odiseo.type_text_level(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_material_exam_area_week_id_foreig FOREIGN KEY (material_exam_area_week_id) REFERENCES odiseo.material_exam_area_week(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_parent_question_id_foreign FOREIGN KEY (parent_question_id) REFERENCES odiseo.parent_question(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_question_history_id_foreign FOREIGN KEY (question_history_id) REFERENCES odiseo.question_history_cycle(id);


--

--

ALTER TABLE ONLY odiseo.material_exam_parent_question
    ADD CONSTRAINT material_exam_parent_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

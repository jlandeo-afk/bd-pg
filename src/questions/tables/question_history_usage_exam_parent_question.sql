-- Table: questions.question_history_usage_exam_parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.question_history_usage_exam_parent_question (
    id bigint NOT NULL,
    material_exam_area_week_id bigint NOT NULL,
    course_id bigint NOT NULL,
    parent_question_id bigint,
    question_id bigint NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    automatic boolean DEFAULT true NOT NULL
);


ALTER TABLE questions.question_history_usage_exam_parent_question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_material_exam_area_ FOREIGN KEY (material_exam_area_week_id) REFERENCES odiseo.material_exam_area_week(id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_parent_question_id_ FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT question_history_usage_exam_parent_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

-- Table: questions.question_history_usage_exam_parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.question_history_usage_exam_parent_question (
    id BIGINT NOT NULL,
    material_exam_area_week_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    parent_question_id BIGINT,
    question_id BIGINT NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    automatic BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE questions.question_history_usage_exam_parent_question OWNER TO postgres;

--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT pk_question_history_usage_exam_parent_question PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_material_exam_area_week FOREIGN KEY (material_exam_area_week_id) REFERENCES odiseo.material_exam_area_week(id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_parent_question FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_history_usage_exam_parent_question
    ADD CONSTRAINT fk_question_history_usage_exam_parent_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

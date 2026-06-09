-- Table: materials.material_exam_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_question (
    id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id BIGINT NOT NULL,
    question_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    material_exam_area_week_id BIGINT,
    question_history_id BIGINT,
    "position" smallint,
    fl_is_manual BOOLEAN DEFAULT false NOT NULL,
    type VARCHAR(20)
);


ALTER TABLE materials.material_exam_question OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT pk_material_exam_question PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_material_exam_area_week FOREIGN KEY (material_exam_area_week_id) REFERENCES materials.material_exam_area_week(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_question_history FOREIGN KEY (question_history_id) REFERENCES questions.question_history_cycle(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE materials.material_exam_question
    ADD CONSTRAINT fk_material_exam_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

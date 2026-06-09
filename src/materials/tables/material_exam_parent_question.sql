-- Table: materials.material_exam_parent_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_exam_parent_question (
    id BIGINT NOT NULL,
    material_exam_area_week_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    parent_question_id BIGINT,
    subquestion JSONB,
    question_history_id BIGINT,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    "position" smallint,
    random BOOLEAN,
    expected_level smallint,
    current_level smallint
);


ALTER TABLE materials.material_exam_parent_question OWNER TO postgres;

--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT pk_material_exam_parent_question PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT uq_parent_question_in_area UNIQUE (material_exam_area_week_id, course_id, parent_question_id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_current_level FOREIGN KEY (current_level) REFERENCES common.type_text_level(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_expected_level FOREIGN KEY (expected_level) REFERENCES common.type_text_level(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_material_exam_area_week FOREIGN KEY (material_exam_area_week_id) REFERENCES materials.material_exam_area_week(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_parent_question FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_question_history FOREIGN KEY (question_history_id) REFERENCES questions.question_history_cycle(id);


--

--

ALTER TABLE materials.material_exam_parent_question
    ADD CONSTRAINT fk_material_exam_parent_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

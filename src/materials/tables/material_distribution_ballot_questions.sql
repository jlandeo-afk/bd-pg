-- Table: materials.material_distribution_ballot_questions
-- Includes constraints and indexes

--

CREATE TABLE materials.material_distribution_ballot_questions (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    week_type_material_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    "position" smallint NOT NULL,
    position_initial smallint NOT NULL,
    subtopic_id BIGINT,
    topic_id smallint,
    level_id BIGINT NOT NULL,
    usage_level_id BIGINT,
    question_id BIGINT,
    type VARCHAR(255),
    usage_status BOOLEAN,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    absolute_position smallint,
    added_in_completion BOOLEAN DEFAULT false NOT NULL,
    removed_in_completion BOOLEAN DEFAULT false NOT NULL,
    parent_question_id INTEGER,
    subquestion JSONB,
    type_text_id BIGINT,
    type_text_subcategory_id BIGINT,
    expected_type VARCHAR(255),
    completed_subquestion BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT material_distribution_ballot_questions_type_check CHECK (((type)::TEXT = ANY (ARRAY[('T'::VARCHAR)::TEXT, ('D'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_distribution_ballot_questions OWNER TO postgres;

--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT pk_material_distribution_ballot_questions PRIMARY KEY (id);


--

--

CREATE INDEX idx_material_distribution_ballot_questions_material_id_week_ ON materials.material_distribution_ballot_questions USING btree (material_id, week, week_type_material_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_material_distribution_ballot_questions_material_id_week_ ON materials.material_distribution_ballot_questions USING btree (material_id, week, course_id) WHERE ((fl_status = true) AND (question_id IS NULL) AND (type_text_id IS NULL) AND (deleted_at IS NULL));


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_parent_question FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_type_text_subcategory FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_usage_level FOREIGN KEY (usage_level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE materials.material_distribution_ballot_questions
    ADD CONSTRAINT fk_material_distribution_ballot_questions_week_type_material FOREIGN KEY (week_type_material_id) REFERENCES academic.detail_week_type_mat(id);


--

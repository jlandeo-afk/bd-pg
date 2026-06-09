-- Table: materials.material_ballot_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_question (
    id BIGINT NOT NULL,
    week_type_material_id BIGINT NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id BIGINT NOT NULL,
    type VARCHAR(2),
    question_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    question_history_id BIGINT,
    "position" smallint,
    random BOOLEAN,
    fl_is_manual BOOLEAN DEFAULT false NOT NULL,
    parent_question_id BIGINT,
    type_text_id BIGINT,
    type_text_subcategory_id BIGINT,
    material_id BIGINT NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    position_initial smallint NOT NULL,
    absolute_position smallint,
    usage_level_id BIGINT,
    usage_status BOOLEAN DEFAULT true,
    added_in_completion BOOLEAN DEFAULT false,
    removed_in_completion BOOLEAN DEFAULT false,
    state VARCHAR(30) DEFAULT 'MISSING'::VARCHAR,
    completed_subquestion BOOLEAN DEFAULT false,
    expected_type character(2),
    entity_type VARCHAR(10) GENERATED ALWAYS AS (
CASE
    WHEN (type_text_id IS NOT NULL) THEN 'TEXT'::TEXT
    ELSE 'QUESTION'::TEXT
END) STORED,
    CONSTRAINT chk_mbq_entity_purity CHECK ((((type_text_id IS NOT NULL) AND (question_id IS NULL)) OR ((type_text_id IS NULL) AND (type_text_subcategory_id IS NULL) AND (parent_question_id IS NULL)))),
    CONSTRAINT chk_mbq_expected_type CHECK (((expected_type = ANY (ARRAY['D'::bpchar, 'T'::bpchar])) OR ((expected_type IS NULL) AND (type_text_id IS NOT NULL)))),
    CONSTRAINT chk_mbq_state_consistency CHECK (((((state)::TEXT = 'MISSING'::TEXT) AND (question_id IS NULL) AND (parent_question_id IS NULL) AND (removed_in_completion = false)) OR (((state)::TEXT = 'MANUAL_REMOVED'::TEXT) AND (question_id IS NULL) AND (parent_question_id IS NULL) AND (removed_in_completion = true)) OR (((state)::TEXT = 'GENERATED'::TEXT) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = false)) OR (((state)::TEXT = 'AUTO_COMPLETED'::TEXT) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = true) AND (fl_is_manual = false)) OR (((state)::TEXT = 'MANUAL_COMPLETED'::TEXT) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = true) AND (fl_is_manual = true)))),
    CONSTRAINT chk_mbq_type CHECK ((((type)::TEXT = ANY ((ARRAY['D'::VARCHAR, 'T'::VARCHAR])::TEXT[])) OR ((type IS NULL) AND (type_text_id IS NOT NULL))))
);


ALTER TABLE materials.material_ballot_question OWNER TO postgres;

--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT pk_material_ballot_question PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_material_ballot_question_week_type_material_id_COALESCEqu ON materials.material_ballot_question USING btree (week_type_material_id, COALESCE(question_id, (0)::BIGINT), COALESCE(parent_question_id, (0)::BIGINT)) WHERE ((fl_status = true) AND (deleted_at IS NULL) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)));


--

--

CREATE INDEX idx_material_ballot_question_week_type_material_id ON materials.material_ballot_question USING btree (week_type_material_id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_usage_level FOREIGN KEY (usage_level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_parent_question FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_type_text FOREIGN KEY (type_text_id) REFERENCES common.type_text(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_type_text_subcategory FOREIGN KEY (type_text_subcategory_id) REFERENCES common.type_text_subcategories(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_question_history FOREIGN KEY (question_history_id) REFERENCES questions.question_history_cycle(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_ballot_question
    ADD CONSTRAINT fk_material_ballot_question_week_type_material FOREIGN KEY (week_type_material_id) REFERENCES academic.detail_week_type_mat(id);


--

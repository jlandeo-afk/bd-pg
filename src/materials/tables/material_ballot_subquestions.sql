-- Table: materials.material_ballot_subquestions
-- Includes constraints and indexes

--

CREATE TABLE materials.material_ballot_subquestions (
    id BIGINT NOT NULL,
    material_ballot_question_id BIGINT NOT NULL,
    question_id BIGINT,
    "position" smallint NOT NULL,
    state VARCHAR(30) DEFAULT 'MISSING'::VARCHAR NOT NULL,
    course_id smallint,
    topic_id smallint,
    subtopic_id smallint,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    fl_is_manual BOOLEAN,
    added_in_completion BOOLEAN,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER,
    CONSTRAINT chk_mbs_state_consistency CHECK (((((state)::TEXT = 'MISSING'::TEXT) AND (question_id IS NULL)) OR (((state)::TEXT = 'MANUAL_REMOVED'::TEXT) AND (question_id IS NULL)) OR (((state)::TEXT = 'GENERATED'::TEXT) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = false)) OR (((state)::TEXT = 'AUTO_COMPLETED'::TEXT) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = true) AND (COALESCE(fl_is_manual, false) = false)) OR (((state)::TEXT = 'MANUAL_COMPLETED'::TEXT) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = true) AND (COALESCE(fl_is_manual, false) = true))))
);


ALTER TABLE materials.material_ballot_subquestions OWNER TO postgres;

--

--

ALTER TABLE materials.material_ballot_subquestions
    ADD CONSTRAINT pk_material_ballot_subquestions PRIMARY KEY (id);


--

--

CREATE INDEX idx_material_ballot_subquestions_material_ballot_question_id ON materials.material_ballot_subquestions USING btree (material_ballot_question_id);


--

--

ALTER TABLE materials.material_ballot_subquestions
    ADD CONSTRAINT fk_material_ballot_subquestions_material_ballot_question FOREIGN KEY (material_ballot_question_id) REFERENCES materials.material_ballot_question(id);


--

--

ALTER TABLE materials.material_ballot_subquestions
    ADD CONSTRAINT fk_material_ballot_subquestions_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

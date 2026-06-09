-- Table: materials.material_missing_question_detail
-- Includes constraints and indexes

--

CREATE TABLE materials.material_missing_question_detail (
    id BIGINT NOT NULL,
    material_missing_question_id BIGINT NOT NULL,
    material_ballot_question_id BIGINT NOT NULL,
    question_id BIGINT,
    employee_id BIGINT,
    status VARCHAR(20) DEFAULT 'pending'::VARCHAR NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    assignment_type VARCHAR(20),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_mmqd_assignment_type CHECK (((assignment_type)::TEXT = ANY (ARRAY[('auto'::VARCHAR)::TEXT, ('manual'::VARCHAR)::TEXT]))),
    CONSTRAINT chk_mmqd_status CHECK (((status)::TEXT = ANY (ARRAY[('pending'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT, ('assigned'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_missing_question_detail OWNER TO postgres;

--

--

ALTER TABLE materials.material_missing_question_detail
    ADD CONSTRAINT pk_material_missing_question_detail PRIMARY KEY (id);


--

--

CREATE INDEX idx_material_missing_question_detail_material_missing_questi ON materials.material_missing_question_detail USING btree (material_missing_question_id, material_ballot_question_id) WHERE (deleted_at IS NULL);


--

--

CREATE INDEX idx_material_missing_question_detail_material_missing_questi ON materials.material_missing_question_detail USING btree (material_missing_question_id, status) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE materials.material_missing_question_detail
    ADD CONSTRAINT fk_material_missing_question_detail_employee FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE materials.material_missing_question_detail
    ADD CONSTRAINT fk_material_missing_question_detail_material_ballot_question FOREIGN KEY (material_ballot_question_id) REFERENCES materials.material_ballot_question(id) ON DELETE CASCADE;


--

--

ALTER TABLE materials.material_missing_question_detail
    ADD CONSTRAINT fk_material_missing_question_detail_material_missing_question FOREIGN KEY (material_missing_question_id) REFERENCES materials.material_missing_question(id);


--

--

ALTER TABLE materials.material_missing_question_detail
    ADD CONSTRAINT fk_material_missing_question_detail_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

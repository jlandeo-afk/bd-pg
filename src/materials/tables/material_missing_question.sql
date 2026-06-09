-- Table: materials.material_missing_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_missing_question (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    week smallint NOT NULL,
    request_date TIMESTAMPTZ NOT NULL,
    expiration_date TIMESTAMPTZ GENERATED ALWAYS AS ((request_date + '3 days'::interval)) STORED NOT NULL,
    course_id smallint NOT NULL,
    status VARCHAR(20) DEFAULT 'pending'::VARCHAR NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_mmq_status CHECK (((status)::TEXT = ANY (ARRAY[('pending'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT, ('completed_late'::VARCHAR)::TEXT, ('expired'::VARCHAR)::TEXT, ('canceled'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_missing_question OWNER TO postgres;

--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT pk_material_missing_question PRIMARY KEY (id);


--

--

CREATE INDEX idx_material_missing_question_material_id_type_material_id_w ON materials.material_missing_question USING btree (material_id, type_material_id, week, course_id, status) WHERE (deleted_at IS NULL);


--

--

CREATE UNIQUE INDEX uq_material_missing_question_material_id_week_course_id_type ON materials.material_missing_question USING btree (material_id, week, course_id, type_material_id) WHERE ((status)::TEXT = 'pending'::TEXT);


--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT fk_material_missing_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT fk_material_missing_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT fk_material_missing_question_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT fk_material_missing_question_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.material_missing_question
    ADD CONSTRAINT fk_material_missing_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

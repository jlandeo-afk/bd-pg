-- Table: questions.employee_didi_question_field
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question_field (
    id BIGINT NOT NULL,
    employee_didi_question_id BIGINT NOT NULL,
    setting_diagrammed_course_id BIGINT NOT NULL,
    value TEXT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    migrated_updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    math_migration_status VARCHAR(255) DEFAULT 'NOT_MIGRATED'::VARCHAR NOT NULL,
    is_migrated BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT employee_didi_question_field_math_migration_status_new_check CHECK (((math_migration_status)::TEXT = ANY (ARRAY[('NOT_MIGRATED'::VARCHAR)::TEXT, ('TO_BE_MIGRATED'::VARCHAR)::TEXT, ('MIGRATING'::VARCHAR)::TEXT, ('MIGRATED'::VARCHAR)::TEXT, ('NOT_MIGRATABLE'::VARCHAR)::TEXT, ('MIGRATION_FAILURE'::VARCHAR)::TEXT])))
);


ALTER TABLE questions.employee_didi_question_field OWNER TO postgres;

--

--

ALTER TABLE questions.employee_didi_question_field
    ADD CONSTRAINT pk_employee_didi_question_field PRIMARY KEY (id);


--

--

CREATE INDEX idx_employee_didi_question_field_employee_didi_question_id ON questions.employee_didi_question_field USING btree (employee_didi_question_id);


--

--

ALTER TABLE questions.employee_didi_question_field
    ADD CONSTRAINT fk_employee_didi_question_field_employee_didi_question FOREIGN KEY (employee_didi_question_id) REFERENCES questions.employee_didi_question(id);


--

--

ALTER TABLE questions.employee_didi_question_field
    ADD CONSTRAINT fk_employee_didi_question_field_setting_diagrammed_course FOREIGN KEY (setting_diagrammed_course_id) REFERENCES academic.setting_diagrammed_courses(id);


--

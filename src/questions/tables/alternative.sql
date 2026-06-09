-- Table: questions.alternative
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative (
    id BIGINT NOT NULL,
    description TEXT NOT NULL,
    question_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    math_migration_status VARCHAR(255) DEFAULT 'NOT_MIGRATED'::VARCHAR NOT NULL,
    migrated_updated_at TIMESTAMPTZ,
    is_migrated BOOLEAN DEFAULT false NOT NULL,
    CONSTRAINT alternative_math_migration_status_check CHECK (((math_migration_status)::TEXT = ANY (ARRAY[('NOT_MIGRATED'::VARCHAR)::TEXT, ('MIGRATING'::VARCHAR)::TEXT, ('MIGRATED'::VARCHAR)::TEXT, ('NOT_MIGRATABLE'::VARCHAR)::TEXT, ('MIGRATION_FAILURE'::VARCHAR)::TEXT])))
);


ALTER TABLE questions.alternative OWNER TO postgres;

--

--

ALTER TABLE questions.alternative
    ADD CONSTRAINT pk_alternative PRIMARY KEY (id);


--

--

ALTER TABLE questions.alternative
    ADD CONSTRAINT fk_alternative_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative
    ADD CONSTRAINT fk_alternative_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative
    ADD CONSTRAINT fk_alternative_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.alternative
    ADD CONSTRAINT fk_alternative_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

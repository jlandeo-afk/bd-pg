-- Table: questions.question
-- Includes constraints and indexes

--

CREATE TABLE questions.question (
    id BIGINT NOT NULL,
    code VARCHAR(25),
    description TEXT NOT NULL,
    short_description TEXT NOT NULL,
    number_question VARCHAR(255),
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id smallint,
    teacher_id BIGINT,
    answer_id BIGINT,
    type VARCHAR(255),
    ter NUMERIC(10,2),
    status VARCHAR(5) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    number VARCHAR(255),
    parent_id BIGINT,
    year VARCHAR(4),
    authorship VARCHAR(255),
    fl_diagrammed BOOLEAN DEFAULT false NOT NULL,
    url_pdf VARCHAR(255),
    region VARCHAR(255),
    area VARCHAR(255),
    config_alternative_id BIGINT DEFAULT '1'::BIGINT NOT NULL,
    resv_to_veri_at TIMESTAMPTZ,
    columns smallint DEFAULT '2'::smallint NOT NULL,
    math_migration_status VARCHAR(255) DEFAULT 'NOT_MIGRATED'::VARCHAR NOT NULL,
    migrated_updated_at TIMESTAMPTZ,
    url_pdf_updated_at TIMESTAMPTZ,
    status_changed_at TIMESTAMPTZ,
    ia_generated BOOLEAN DEFAULT false NOT NULL,
    priority INTEGER,
    is_migrated BOOLEAN DEFAULT false NOT NULL,
    search_text TEXT GENERATED ALWAYS AS (lower(common.fn_immutable_unaccent((((COALESCE(code, ''::VARCHAR))::TEXT || ' '::TEXT) || COALESCE(short_description, ''::TEXT))))) STORED,
    CONSTRAINT question_math_migration_status_check CHECK (((math_migration_status)::TEXT = ANY (ARRAY[('NOT_MIGRATED'::VARCHAR)::TEXT, ('MIGRATING'::VARCHAR)::TEXT, ('MIGRATED'::VARCHAR)::TEXT, ('NOT_MIGRATABLE'::VARCHAR)::TEXT, ('MIGRATION_FAILURE'::VARCHAR)::TEXT]))),
    CONSTRAINT question_type_check CHECK (((type)::TEXT = ANY (ARRAY[('T'::VARCHAR)::TEXT, ('D'::VARCHAR)::TEXT])))
);


ALTER TABLE questions.question OWNER TO postgres;

--

--

ALTER TABLE questions.question
    ADD CONSTRAINT odiseo_question_code_unique UNIQUE (code);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT pk_question PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_search_text_trgm ON questions.question USING gin (search_text extensions.gin_trgm_ops);


--

--

CREATE INDEX idx_question_short_description_trgm ON questions.question USING gin (lower(common.fn_immutable_unaccent(short_description)) extensions.gin_trgm_ops);


--

--

CREATE INDEX idx_question_parent_id ON questions.question USING btree (parent_id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_config_alternative FOREIGN KEY (config_alternative_id) REFERENCES questions.configuration_alternative(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_parent FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_teacher FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE questions.question
    ADD CONSTRAINT fk_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

-- Table: questions.question
-- Includes constraints and indexes

--

CREATE TABLE questions.question (
    id bigint NOT NULL,
    code character varying(25),
    description text NOT NULL,
    short_description text NOT NULL,
    number_question character varying(255),
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id smallint,
    teacher_id bigint,
    answer_id bigint,
    type character varying(255),
    ter numeric(10,2),
    status character varying(5) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    number character varying(255),
    parent_id bigint,
    year character varying(4),
    authorship character varying(255),
    fl_diagrammed boolean DEFAULT false NOT NULL,
    url_pdf character varying(255),
    region character varying(255),
    area character varying(255),
    config_alternative_id bigint DEFAULT '1'::bigint NOT NULL,
    resv_to_veri_at timestamp(0) without time zone,
    columns smallint DEFAULT '2'::smallint NOT NULL,
    math_migration_status character varying(255) DEFAULT 'NOT_MIGRATED'::character varying NOT NULL,
    migrated_updated_at timestamp(0) without time zone,
    url_pdf_updated_at timestamp(0) without time zone,
    status_changed_at timestamp(0) without time zone,
    ia_generated boolean DEFAULT false NOT NULL,
    priority integer,
    is_migrated boolean DEFAULT false NOT NULL,
    search_text text GENERATED ALWAYS AS (lower(common.fn_immutable_unaccent((((COALESCE(code, ''::character varying))::text || ' '::text) || COALESCE(short_description, ''::text))))) STORED,
    CONSTRAINT question_math_migration_status_check CHECK (((math_migration_status)::text = ANY (ARRAY[('NOT_MIGRATED'::character varying)::text, ('MIGRATING'::character varying)::text, ('MIGRATED'::character varying)::text, ('NOT_MIGRATABLE'::character varying)::text, ('MIGRATION_FAILURE'::character varying)::text]))),
    CONSTRAINT question_type_check CHECK (((type)::text = ANY (ARRAY[('T'::character varying)::text, ('D'::character varying)::text])))
);


ALTER TABLE questions.question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_code_unique UNIQUE (code);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT question_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_search_text_trgm ON questions.question USING gin (search_text extensions.gin_trgm_ops);


--

--

CREATE INDEX idx_question_short_description_trgm ON questions.question USING gin (lower(common.fn_immutable_unaccent(short_description)) extensions.gin_trgm_ops);


--

--

CREATE INDEX question_parent_id_index ON questions.question USING btree (parent_id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_config_alternative_id_foreign FOREIGN KEY (config_alternative_id) REFERENCES questions.configuration_alternative(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_level_id_foreign FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_teacher_id_foreign FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE ONLY questions.question
    ADD CONSTRAINT odiseo_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

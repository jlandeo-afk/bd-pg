-- Table: questions.alternative
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative (
    id bigint NOT NULL,
    description text NOT NULL,
    question_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    math_migration_status character varying(255) DEFAULT 'NOT_MIGRATED'::character varying NOT NULL,
    migrated_updated_at timestamp(0) without time zone,
    is_migrated boolean DEFAULT false NOT NULL,
    CONSTRAINT alternative_math_migration_status_check CHECK (((math_migration_status)::text = ANY (ARRAY[('NOT_MIGRATED'::character varying)::text, ('MIGRATING'::character varying)::text, ('MIGRATED'::character varying)::text, ('NOT_MIGRATABLE'::character varying)::text, ('MIGRATION_FAILURE'::character varying)::text])))
);


ALTER TABLE questions.alternative OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.alternative
    ADD CONSTRAINT alternative_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.alternative
    ADD CONSTRAINT odiseo_alternative_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.alternative
    ADD CONSTRAINT odiseo_alternative_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.alternative
    ADD CONSTRAINT odiseo_alternative_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.alternative
    ADD CONSTRAINT odiseo_alternative_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

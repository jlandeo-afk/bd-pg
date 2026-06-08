-- Table: odiseo.alternative_questions_ia
-- Includes constraints and indexes

--

CREATE TABLE odiseo.alternative_questions_ia (
    id bigint NOT NULL,
    description text NOT NULL,
    option character varying(255) NOT NULL,
    question_ia_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.alternative_questions_ia OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.alternative_questions_ia
    ADD CONSTRAINT alternative_questions_ia_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.alternative_questions_ia
    ADD CONSTRAINT alternative_questions_ia_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.alternative_questions_ia
    ADD CONSTRAINT alternative_questions_ia_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.alternative_questions_ia
    ADD CONSTRAINT alternative_questions_ia_question_ia_id_foreign FOREIGN KEY (question_ia_id) REFERENCES odiseo.question_teacher_ia(id);


--

--

ALTER TABLE ONLY odiseo.alternative_questions_ia
    ADD CONSTRAINT alternative_questions_ia_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

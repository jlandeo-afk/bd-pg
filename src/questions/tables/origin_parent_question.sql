-- Table: questions.origin_parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.origin_parent_question (
    id bigint NOT NULL,
    parent_id bigint NOT NULL,
    year character varying(4) NOT NULL,
    region_id bigint NOT NULL,
    university_id smallint,
    option_id smallint,
    modality_id smallint,
    areas character varying(255),
    version smallint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    modality_option_id integer
);


ALTER TABLE questions.origin_parent_question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_modality_option FOREIGN KEY (modality_option_id) REFERENCES academic.modality_options(id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_modality_id_foreign FOREIGN KEY (modality_id) REFERENCES academic.modality(id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_option_id_foreign FOREIGN KEY (option_id) REFERENCES academic.option(id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE ONLY questions.origin_parent_question
    ADD CONSTRAINT origin_parent_question_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

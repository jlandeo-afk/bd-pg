-- Table: odiseo.origin_question
-- Includes constraints and indexes

--

CREATE TABLE odiseo.origin_question (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    year character varying(4) NOT NULL,
    region_id bigint NOT NULL,
    university_id smallint,
    option_id smallint,
    modality_id smallint,
    areas character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    version smallint,
    modality_option_id integer
);


ALTER TABLE odiseo.origin_question OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT fk_origin_question_modality_option FOREIGN KEY (modality_option_id) REFERENCES odiseo.modality_options(id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_modality_id_foreign FOREIGN KEY (modality_id) REFERENCES odiseo.modality(id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_option_id_foreign FOREIGN KEY (option_id) REFERENCES odiseo.option(id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE ONLY odiseo.origin_question
    ADD CONSTRAINT origin_question_university_id_foreign FOREIGN KEY (university_id) REFERENCES odiseo.origin_university(id);


--

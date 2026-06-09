-- Table: questions.origin_parent_question
-- Includes constraints and indexes

--

CREATE TABLE questions.origin_parent_question (
    id BIGINT NOT NULL,
    parent_id BIGINT NOT NULL,
    year VARCHAR(4) NOT NULL,
    region_id BIGINT NOT NULL,
    university_id smallint,
    option_id smallint,
    modality_id smallint,
    areas VARCHAR(255),
    version smallint,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    modality_option_id INTEGER
);


ALTER TABLE questions.origin_parent_question OWNER TO postgres;

--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT pk_origin_parent_question PRIMARY KEY (id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_modality_option FOREIGN KEY (modality_option_id) REFERENCES academic.modality_options(id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_modality FOREIGN KEY (modality_id) REFERENCES academic.modality(id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_option FOREIGN KEY (option_id) REFERENCES academic.option(id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_parent FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_region FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE questions.origin_parent_question
    ADD CONSTRAINT fk_origin_parent_question_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

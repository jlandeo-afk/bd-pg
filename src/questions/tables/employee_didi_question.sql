-- Table: questions.employee_didi_question
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question (
    id bigint NOT NULL,
    employee_id bigint,
    question_id bigint,
    week smallint,
    year smallint,
    diagrammed boolean DEFAULT false NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    theory_base text,
    data_unknown text,
    "development " text,
    answer text,
    url_file character varying(255),
    url_file_digitalized_solution character varying(255),
    url_file_digitalized_images text,
    url_file_digitalized_solution_updated_at timestamp(0) without time zone,
    version bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE questions.employee_didi_question OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT employee_didi_question_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX employee_didi_question_question_id_unique_active ON questions.employee_didi_question USING btree (question_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_didi_question_active ON questions.employee_didi_question USING btree (question_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_employee_didi_question_fl_status ON questions.employee_didi_question USING btree (fl_status);


--

--

CREATE INDEX idx_employee_didi_question_question_id ON questions.employee_didi_question USING btree (question_id);


--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT odiseo_employee_didi_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT odiseo_employee_didi_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT odiseo_employee_didi_question_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT odiseo_employee_didi_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.employee_didi_question
    ADD CONSTRAINT odiseo_employee_didi_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

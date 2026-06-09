-- Table: questions.employee_didi_question
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question (
    id BIGINT NOT NULL,
    employee_id BIGINT,
    question_id BIGINT,
    week smallint,
    year smallint,
    diagrammed BOOLEAN DEFAULT false NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    theory_base TEXT,
    data_unknown TEXT,
    "development " TEXT,
    answer TEXT,
    url_file VARCHAR(255),
    url_file_digitalized_solution VARCHAR(255),
    url_file_digitalized_images TEXT,
    url_file_digitalized_solution_updated_at TIMESTAMPTZ,
    version BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE questions.employee_didi_question OWNER TO postgres;

--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT pk_employee_didi_question PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_employee_didi_question_question_id ON questions.employee_didi_question USING btree (question_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_employee_didi_question_question_id ON questions.employee_didi_question USING btree (question_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_employee_didi_question_fl_status ON questions.employee_didi_question USING btree (fl_status);


--

--

CREATE INDEX idx_employee_didi_question_question_id ON questions.employee_didi_question USING btree (question_id);


--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT fk_employee_didi_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT fk_employee_didi_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT fk_employee_didi_question_employee FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT fk_employee_didi_question_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.employee_didi_question
    ADD CONSTRAINT fk_employee_didi_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

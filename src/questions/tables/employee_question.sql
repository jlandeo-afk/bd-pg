-- Table: questions.employee_question
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_question (
    id BIGINT NOT NULL,
    teacher_id BIGINT,
    question_id BIGINT,
    alternative_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type VARCHAR(255) DEFAULT 'MANUAL'::VARCHAR NOT NULL,
    document_solution TEXT,
    week INTEGER,
    year INTEGER,
    solved BOOLEAN DEFAULT false NOT NULL,
    url_pdf_question_solution VARCHAR(255),
    board_json TEXT,
    board_refuzed TEXT,
    fl_refuzed BOOLEAN DEFAULT false NOT NULL,
    editor_content TEXT,
    url_pdf_question_solution_updated_at TIMESTAMPTZ
);


ALTER TABLE questions.employee_question OWNER TO postgres;

--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT pk_employee_question PRIMARY KEY (id);


--

--

CREATE INDEX idx_employee_question_question_id ON questions.employee_question USING btree (question_id) WHERE (fl_status = true);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_alternative FOREIGN KEY (alternative_id) REFERENCES questions.alternative(id);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_teacher FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE questions.employee_question
    ADD CONSTRAINT fk_employee_question_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

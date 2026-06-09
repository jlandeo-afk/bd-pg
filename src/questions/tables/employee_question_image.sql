-- Table: questions.employee_question_image
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_question_image (
    id BIGINT NOT NULL,
    employee_question_id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,
    extension VARCHAR(6) NOT NULL,
    image TEXT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.employee_question_image OWNER TO postgres;

--

--

ALTER TABLE questions.employee_question_image
    ADD CONSTRAINT pk_employee_question_image PRIMARY KEY (id);


--

--

ALTER TABLE questions.employee_question_image
    ADD CONSTRAINT fk_employee_question_image_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question_image
    ADD CONSTRAINT fk_employee_question_image_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_question_image
    ADD CONSTRAINT fk_employee_question_image_employee_question FOREIGN KEY (employee_question_id) REFERENCES questions.employee_question(id);


--

--

ALTER TABLE questions.employee_question_image
    ADD CONSTRAINT fk_employee_question_image_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

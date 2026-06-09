-- Table: questions.employee_didi_question_field_image
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question_field_image (
    id BIGINT NOT NULL,
    employee_didi_question_id BIGINT NOT NULL,
    code VARCHAR NOT NULL,
    image VARCHAR NOT NULL,
    extension VARCHAR NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
)
PARTITION BY LIST (fl_status);


ALTER TABLE questions.employee_didi_question_field_image OWNER TO postgres;

--

--

ALTER TABLE questions.employee_didi_question_field_image
    ADD CONSTRAINT employee_didi_question_field_image_pkey1 PRIMARY KEY (id, fl_status);


--

--

ALTER TABLE questions.employee_didi_question_field_image
    ADD CONSTRAINT fk_employee_didi_question_field_image_employee_didi_question FOREIGN KEY (employee_didi_question_id) REFERENCES questions.employee_didi_question(id);


--

--

ALTER TABLE questions.employee_didi_question_field_image
    ADD CONSTRAINT fk_employee_didi_question_field_image_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_didi_question_field_image
    ADD CONSTRAINT fk_employee_didi_question_field_image_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.employee_didi_question_field_image
    ADD CONSTRAINT fk_employee_didi_question_field_image_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

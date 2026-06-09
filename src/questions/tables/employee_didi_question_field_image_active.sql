-- Table: questions.employee_didi_question_field_image_active
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question_field_image_active (
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
);


ALTER TABLE questions.employee_didi_question_field_image_active OWNER TO postgres;

--

--

ALTER TABLE questions.employee_didi_question_field_image_active
    ADD CONSTRAINT pk_employee_didi_question_field_image_active PRIMARY KEY (id, fl_status);


--

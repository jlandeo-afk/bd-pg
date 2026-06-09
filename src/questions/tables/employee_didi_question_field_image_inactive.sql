-- Table: questions.employee_didi_question_field_image_inactive
-- Includes constraints and indexes

--

CREATE TABLE questions.employee_didi_question_field_image_inactive (
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


ALTER TABLE questions.employee_didi_question_field_image_inactive OWNER TO postgres;

--

--

ALTER TABLE questions.employee_didi_question_field_image_inactive
    ADD CONSTRAINT pk_employee_didi_question_field_image_inactive PRIMARY KEY (id, fl_status);


--

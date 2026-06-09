-- Table: questions.field_diagrammed
-- Includes constraints and indexes

--

CREATE TABLE questions.field_diagrammed (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    name_nq VARCHAR(255)
);


ALTER TABLE questions.field_diagrammed OWNER TO postgres;

--

--

ALTER TABLE questions.field_diagrammed
    ADD CONSTRAINT pk_field_diagrammed PRIMARY KEY (id);


--

-- Table: exams.type_exams
-- Includes constraints and indexes

--

CREATE TABLE exams.type_exams (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE exams.type_exams OWNER TO postgres;

--

--

ALTER TABLE exams.type_exams
    ADD CONSTRAINT pk_type_exams PRIMARY KEY (id);


--

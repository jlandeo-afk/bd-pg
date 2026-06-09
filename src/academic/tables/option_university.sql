-- Table: academic.option_university
-- Includes constraints and indexes

--

CREATE TABLE academic.option_university (
    id BIGINT NOT NULL,
    name VARCHAR(255),
    university_id BIGINT,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT
);


ALTER TABLE academic.option_university OWNER TO postgres;

--

--

ALTER TABLE academic.option_university
    ADD CONSTRAINT pk_option_university PRIMARY KEY (id);


--

--

ALTER TABLE academic.option_university
    ADD CONSTRAINT fk_option_university_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

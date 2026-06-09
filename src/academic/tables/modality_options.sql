-- Table: academic.modality_options
-- Includes constraints and indexes

--

CREATE TABLE academic.modality_options (
    id BIGINT NOT NULL,
    name VARCHAR(255),
    option_university_id BIGINT NOT NULL,
    fl_allows_mark_frequent_topic BOOLEAN DEFAULT false NOT NULL,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_by BIGINT,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by BIGINT
);


ALTER TABLE academic.modality_options OWNER TO postgres;

--

--

ALTER TABLE academic.modality_options
    ADD CONSTRAINT pk_modality_options PRIMARY KEY (id);


--

--

ALTER TABLE academic.modality_options
    ADD CONSTRAINT fk_modality_options_option_university FOREIGN KEY (option_university_id) REFERENCES academic.option_university(id);


--

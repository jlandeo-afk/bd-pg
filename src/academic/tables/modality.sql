-- Table: academic.modality
-- Includes constraints and indexes

--

CREATE TABLE academic.modality (
    id smallint NOT NULL,
    name VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    option_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    university_ids INTEGER[] DEFAULT ARRAY[]::INTEGER[],
    fl_allows_mark_frequent_topic BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE academic.modality OWNER TO postgres;

--

--

ALTER TABLE academic.modality
    ADD CONSTRAINT pk_modality PRIMARY KEY (id);


--

--

ALTER TABLE academic.modality
    ADD CONSTRAINT fk_modality_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.modality
    ADD CONSTRAINT fk_modality_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.modality
    ADD CONSTRAINT fk_modality_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

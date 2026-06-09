-- Table: exams.area
-- Includes constraints and indexes

--

CREATE TABLE exams.area (
    id BIGINT NOT NULL,
    code VARCHAR(255) NOT NULL,
    slug VARCHAR(5),
    description VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    agreement_url VARCHAR(255),
    agreement_file_name VARCHAR(255)
);


ALTER TABLE exams.area OWNER TO postgres;

--

--

ALTER TABLE exams.area
    ADD CONSTRAINT pk_area PRIMARY KEY (id);


--

--

ALTER TABLE exams.area
    ADD CONSTRAINT fk_area_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE exams.area
    ADD CONSTRAINT fk_area_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE exams.area
    ADD CONSTRAINT fk_area_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

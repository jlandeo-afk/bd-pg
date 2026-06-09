-- Table: academic.pseudo_course
-- Includes constraints and indexes

--

CREATE TABLE academic.pseudo_course (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.pseudo_course OWNER TO postgres;

--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT pk_pseudo_course PRIMARY KEY (id);


--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT unique_code UNIQUE (code, fl_status);


--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT unique_name UNIQUE (name, fl_status);


--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT fk_pseudo_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT fk_pseudo_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.pseudo_course
    ADD CONSTRAINT fk_pseudo_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

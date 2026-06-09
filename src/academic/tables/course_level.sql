-- Table: academic.course_level
-- Includes constraints and indexes

--

CREATE TABLE academic.course_level (
    id BIGINT NOT NULL,
    code VARCHAR(20) NOT NULL,
    level_id BIGINT,
    course_id smallint,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    course_level_nq BOOLEAN DEFAULT false NOT NULL
);


ALTER TABLE academic.course_level OWNER TO postgres;

--

--

ALTER TABLE academic.course_level
    ADD CONSTRAINT pk_course_level PRIMARY KEY (id);


--

--

ALTER TABLE academic.course_level
    ADD CONSTRAINT fk_course_level_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_level
    ADD CONSTRAINT fk_course_level_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_level
    ADD CONSTRAINT fk_course_level_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

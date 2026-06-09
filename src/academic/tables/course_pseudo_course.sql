-- Table: academic.course_pseudo_course
-- Includes constraints and indexes

--

CREATE TABLE academic.course_pseudo_course (
    id BIGINT NOT NULL,
    course_id BIGINT,
    pseudo_course_id BIGINT,
    "order" INTEGER DEFAULT 1 NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.course_pseudo_course OWNER TO postgres;

--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT pk_course_pseudo_course PRIMARY KEY (id);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT unique_course_pseudo UNIQUE (course_id, pseudo_course_id, fl_status);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT fk_course_pseudo_course_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT fk_course_pseudo_course_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT fk_course_pseudo_course_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT fk_course_pseudo_course_pseudo_course FOREIGN KEY (pseudo_course_id) REFERENCES academic.pseudo_course(id);


--

--

ALTER TABLE academic.course_pseudo_course
    ADD CONSTRAINT fk_course_pseudo_course_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

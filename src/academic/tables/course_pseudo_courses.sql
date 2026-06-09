-- Table: academic.course_pseudo_courses
-- Includes constraints and indexes

--

CREATE TABLE academic.course_pseudo_courses (
    id BIGINT NOT NULL,
    pseudo_course_id smallint NOT NULL,
    course_id smallint NOT NULL,
    "order" INTEGER DEFAULT 1 NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.course_pseudo_courses OWNER TO postgres;

--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT pk_course_pseudo_courses PRIMARY KEY (id);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT unique_pseudo_courses UNIQUE (pseudo_course_id, course_id, fl_status);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT fk_course_pseudo_courses_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT fk_course_pseudo_courses_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT fk_course_pseudo_courses_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT fk_course_pseudo_courses_pseudo_course FOREIGN KEY (pseudo_course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.course_pseudo_courses
    ADD CONSTRAINT fk_course_pseudo_courses_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

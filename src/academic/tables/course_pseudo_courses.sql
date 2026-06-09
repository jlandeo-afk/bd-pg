-- Table: academic.course_pseudo_courses
-- Includes constraints and indexes

--

CREATE TABLE academic.course_pseudo_courses (
    id bigint NOT NULL,
    pseudo_course_id smallint NOT NULL,
    course_id smallint NOT NULL,
    "order" integer DEFAULT 1 NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE academic.course_pseudo_courses OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT course_pseudo_courses_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT unique_pseudo_courses UNIQUE (pseudo_course_id, course_id, fl_status);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT odiseo_course_pseudo_courses_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT odiseo_course_pseudo_courses_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT odiseo_course_pseudo_courses_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT odiseo_course_pseudo_courses_pseudo_course_id_foreign FOREIGN KEY (pseudo_course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY academic.course_pseudo_courses
    ADD CONSTRAINT odiseo_course_pseudo_courses_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

-- Table: odiseo.course_pseudo_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_pseudo_course (
    id bigint NOT NULL,
    course_id bigint,
    pseudo_course_id bigint,
    "order" integer DEFAULT 1 NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.course_pseudo_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT course_pseudo_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT unique_course_pseudo UNIQUE (course_id, pseudo_course_id, fl_status);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT odiseo_course_pseudo_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT odiseo_course_pseudo_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT odiseo_course_pseudo_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT odiseo_course_pseudo_course_pseudo_course_id_foreign FOREIGN KEY (pseudo_course_id) REFERENCES odiseo.pseudo_course(id);


--

--

ALTER TABLE ONLY odiseo.course_pseudo_course
    ADD CONSTRAINT odiseo_course_pseudo_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

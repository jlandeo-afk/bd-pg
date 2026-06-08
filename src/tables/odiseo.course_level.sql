-- Table: odiseo.course_level
-- Includes constraints and indexes

--

CREATE TABLE odiseo.course_level (
    id bigint NOT NULL,
    code character varying(20) NOT NULL,
    level_id bigint,
    course_id smallint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    course_level_nq boolean DEFAULT false NOT NULL
);


ALTER TABLE odiseo.course_level OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.course_level
    ADD CONSTRAINT course_level_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.course_level
    ADD CONSTRAINT odiseo_course_level_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_level
    ADD CONSTRAINT odiseo_course_level_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.course_level
    ADD CONSTRAINT odiseo_course_level_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

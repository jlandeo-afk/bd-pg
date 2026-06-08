-- Table: odiseo.pseudo_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.pseudo_course (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.pseudo_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT pseudo_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT unique_code UNIQUE (code, fl_status);


--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT unique_name UNIQUE (name, fl_status);


--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT odiseo_pseudo_course_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT odiseo_pseudo_course_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.pseudo_course
    ADD CONSTRAINT odiseo_pseudo_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

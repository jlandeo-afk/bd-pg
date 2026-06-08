-- Table: odiseo.exam_area
-- Includes constraints and indexes

--

CREATE TABLE odiseo.exam_area (
    id smallint NOT NULL,
    description character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    short_description character varying(255)
);


ALTER TABLE odiseo.exam_area OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.exam_area
    ADD CONSTRAINT exam_area_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.exam_area
    ADD CONSTRAINT odiseo_exam_area_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.exam_area
    ADD CONSTRAINT odiseo_exam_area_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.exam_area
    ADD CONSTRAINT odiseo_exam_area_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

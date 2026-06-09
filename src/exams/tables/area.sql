-- Table: exams.area
-- Includes constraints and indexes

--

CREATE TABLE exams.area (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    slug character varying(5),
    description character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    agreement_url character varying(255),
    agreement_file_name character varying(255)
);


ALTER TABLE exams.area OWNER TO postgres;

--

--

ALTER TABLE ONLY exams.area
    ADD CONSTRAINT area_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY exams.area
    ADD CONSTRAINT odiseo_area_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY exams.area
    ADD CONSTRAINT odiseo_area_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY exams.area
    ADD CONSTRAINT odiseo_area_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

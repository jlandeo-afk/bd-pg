-- Table: academic.origin_university
-- Includes constraints and indexes

--

CREATE TABLE academic.origin_university (
    id smallint NOT NULL,
    name character varying(255) NOT NULL,
    type smallint NOT NULL,
    fl_active boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    slug character varying(10),
    region_id smallint,
    areas text DEFAULT '[]'::text NOT NULL,
    code character varying(255),
    versions text DEFAULT '[]'::text NOT NULL
);


ALTER TABLE academic.origin_university OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.origin_university
    ADD CONSTRAINT origin_university_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.origin_university
    ADD CONSTRAINT odiseo_origin_university_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.origin_university
    ADD CONSTRAINT odiseo_origin_university_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.origin_university
    ADD CONSTRAINT odiseo_origin_university_region_id_foreign FOREIGN KEY (region_id) REFERENCES odiseo.region(id);


--

--

ALTER TABLE ONLY academic.origin_university
    ADD CONSTRAINT odiseo_origin_university_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

-- Table: academic.university_headquarters
-- Includes constraints and indexes

--

CREATE TABLE academic.university_headquarters (
    id smallint NOT NULL,
    university_id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    quantity_classroom integer NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE academic.university_headquarters OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT university_headquarters_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT odiseo_university_headquarters_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT odiseo_university_headquarters_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT odiseo_university_headquarters_headquarters_id_foreign FOREIGN KEY (headquarters_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT odiseo_university_headquarters_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY academic.university_headquarters
    ADD CONSTRAINT odiseo_university_headquarters_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

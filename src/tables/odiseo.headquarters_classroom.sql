-- Table: odiseo.headquarters_classroom
-- Includes constraints and indexes

--

CREATE TABLE odiseo.headquarters_classroom (
    id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    classroom_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.headquarters_classroom OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT headquarters_classroom_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT odiseo_headquarters_classroom_classroom_id_foreign FOREIGN KEY (classroom_id) REFERENCES odiseo.classroom(id);


--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT odiseo_headquarters_classroom_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT odiseo_headquarters_classroom_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT odiseo_headquarters_classroom_headquarters_id_foreign FOREIGN KEY (headquarters_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE ONLY odiseo.headquarters_classroom
    ADD CONSTRAINT odiseo_headquarters_classroom_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

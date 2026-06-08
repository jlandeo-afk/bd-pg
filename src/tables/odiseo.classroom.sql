-- Table: odiseo.classroom
-- Includes constraints and indexes

--

CREATE TABLE odiseo.classroom (
    id smallint NOT NULL,
    code character varying(4) NOT NULL,
    number character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.classroom OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.classroom
    ADD CONSTRAINT classroom_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.classroom
    ADD CONSTRAINT odiseo_classroom_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.classroom
    ADD CONSTRAINT odiseo_classroom_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.classroom
    ADD CONSTRAINT odiseo_classroom_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

-- Table: odiseo.parent_image
-- Includes constraints and indexes

--

CREATE TABLE odiseo.parent_image (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    extension character varying(10),
    image text NOT NULL,
    parent_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.parent_image OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.parent_image
    ADD CONSTRAINT parent_image_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.parent_image
    ADD CONSTRAINT odiseo_parent_image_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.parent_image
    ADD CONSTRAINT odiseo_parent_image_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.parent_image
    ADD CONSTRAINT odiseo_parent_image_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES odiseo.parent_question(id);


--

--

ALTER TABLE ONLY odiseo.parent_image
    ADD CONSTRAINT odiseo_parent_image_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

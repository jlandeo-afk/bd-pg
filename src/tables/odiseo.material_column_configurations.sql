-- Table: odiseo.material_column_configurations
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_column_configurations (
    id bigint NOT NULL,
    material_configuration_id bigint NOT NULL,
    course_id bigint,
    topic_id bigint,
    column_count bigint DEFAULT '2'::bigint NOT NULL,
    column_width numeric(5,2) DEFAULT '9'::numeric NOT NULL,
    column_spacing numeric(5,2) DEFAULT '1'::numeric NOT NULL,
    layout_format character varying(255),
    number_format character varying(255),
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.material_column_configurations OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT material_column_configurations_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_material_configuration_id FOREIGN KEY (material_configuration_id) REFERENCES odiseo.material_configurations(id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.material_column_configurations
    ADD CONSTRAINT odiseo_material_column_configurations_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

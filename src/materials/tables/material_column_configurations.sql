-- Table: materials.material_column_configurations
-- Includes constraints and indexes

--

CREATE TABLE materials.material_column_configurations (
    id BIGINT NOT NULL,
    material_configuration_id BIGINT NOT NULL,
    course_id BIGINT,
    topic_id BIGINT,
    column_count BIGINT DEFAULT '2'::BIGINT NOT NULL,
    column_width NUMERIC(5,2) DEFAULT '9'::NUMERIC NOT NULL,
    column_spacing NUMERIC(5,2) DEFAULT '1'::NUMERIC NOT NULL,
    layout_format VARCHAR(255),
    number_format VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.material_column_configurations OWNER TO postgres;

--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT pk_material_column_configurations PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_material_configuration FOREIGN KEY (material_configuration_id) REFERENCES materials.material_configurations(id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE materials.material_column_configurations
    ADD CONSTRAINT fk_material_column_configurations_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

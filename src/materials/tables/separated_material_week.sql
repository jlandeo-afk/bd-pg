-- Table: materials.separated_material_week
-- Includes constraints and indexes

--

CREATE TABLE materials.separated_material_week (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    type_material_id smallint NOT NULL,
    week smallint NOT NULL,
    fl_solution BOOLEAN NOT NULL,
    fl_quality BOOLEAN NOT NULL,
    week_type_material_ids VARCHAR(255),
    course_id smallint NOT NULL,
    fl_process_status smallint DEFAULT '1'::smallint NOT NULL,
    url_material VARCHAR(255),
    job_id VARCHAR(255),
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_course_active BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE materials.separated_material_week OWNER TO postgres;

--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT pk_separated_material_week PRIMARY KEY (id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_type_material FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE materials.separated_material_week
    ADD CONSTRAINT fk_separated_material_week_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

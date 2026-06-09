-- Table: materials.type_material_area_courses
-- Includes constraints and indexes

--

CREATE TABLE materials.type_material_area_courses (
    id BIGINT NOT NULL,
    type_material_course_id BIGINT NOT NULL,
    type_material_area_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.type_material_area_courses OWNER TO postgres;

--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT pk_type_material_area_courses PRIMARY KEY (id);


--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT fk_type_material_area_courses_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT fk_type_material_area_courses_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT fk_type_material_area_courses_type_material_area FOREIGN KEY (type_material_area_id) REFERENCES materials.type_material_area(id);


--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT fk_type_material_area_courses_type_material_course FOREIGN KEY (type_material_course_id) REFERENCES materials.type_material_course(id);


--

--

ALTER TABLE materials.type_material_area_courses
    ADD CONSTRAINT fk_type_material_area_courses_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

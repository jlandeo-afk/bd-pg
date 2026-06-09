-- Table: materials.material_per_period_exam
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_exam (
    id BIGINT NOT NULL,
    material_per_period_id BIGINT NOT NULL,
    exam_area_id BIGINT NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    questions_missing_url VARCHAR(255),
    courses_missing_url VARCHAR(255),
    text_missing_url VARCHAR(255),
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE materials.material_per_period_exam OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT pk_material_per_period_exam PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT fk_material_per_period_exam_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT fk_material_per_period_exam_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT fk_material_per_period_exam_exam_area FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT fk_material_per_period_exam_material_per_period FOREIGN KEY (material_per_period_id) REFERENCES materials.material_per_period(id);


--

--

ALTER TABLE materials.material_per_period_exam
    ADD CONSTRAINT fk_material_per_period_exam_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

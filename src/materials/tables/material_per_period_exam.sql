-- Table: materials.material_per_period_exam
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_exam (
    id bigint NOT NULL,
    material_per_period_id bigint NOT NULL,
    exam_area_id bigint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    questions_missing_url character varying(255),
    courses_missing_url character varying(255),
    text_missing_url character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE materials.material_per_period_exam OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_exam_area_id_foreign FOREIGN KEY (exam_area_id) REFERENCES odiseo.exam_area(id);


--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_material_per_period_id_foreign FOREIGN KEY (material_per_period_id) REFERENCES materials.material_per_period(id);


--

--

ALTER TABLE ONLY materials.material_per_period_exam
    ADD CONSTRAINT material_per_period_exam_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

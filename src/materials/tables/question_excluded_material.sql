-- Table: questions.question_excluded_material
-- Includes constraints and indexes

--

CREATE TABLE questions.question_excluded_material (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    question_id bigint NOT NULL,
    excluded_at timestamp(0) without time zone,
    created_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.question_excluded_material OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_excluded_material
    ADD CONSTRAINT question_excluded_material_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_excluded_material
    ADD CONSTRAINT question_excluded_material_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_excluded_material
    ADD CONSTRAINT question_excluded_material_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_excluded_material
    ADD CONSTRAINT question_excluded_material_material_id_foreign FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE ONLY questions.question_excluded_material
    ADD CONSTRAINT question_excluded_material_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

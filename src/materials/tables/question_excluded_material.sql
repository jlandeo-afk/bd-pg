-- Table: questions.question_excluded_material
-- Includes constraints and indexes

--

CREATE TABLE questions.question_excluded_material (
    id BIGINT NOT NULL,
    material_id BIGINT NOT NULL,
    question_id BIGINT NOT NULL,
    excluded_at TIMESTAMPTZ,
    created_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.question_excluded_material OWNER TO postgres;

--

--

ALTER TABLE questions.question_excluded_material
    ADD CONSTRAINT pk_question_excluded_material PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_excluded_material
    ADD CONSTRAINT fk_question_excluded_material_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_excluded_material
    ADD CONSTRAINT fk_question_excluded_material_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_excluded_material
    ADD CONSTRAINT fk_question_excluded_material_material FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE questions.question_excluded_material
    ADD CONSTRAINT fk_question_excluded_material_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

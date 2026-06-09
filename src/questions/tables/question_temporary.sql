-- Table: questions.question_temporary
-- Includes constraints and indexes

--

CREATE TABLE questions.question_temporary (
    id BIGINT NOT NULL,
    question_id INTEGER NOT NULL,
    cycle_id INTEGER,
    week_id smallint,
    type_material_id smallint,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    type_material_template_id smallint
);


ALTER TABLE questions.question_temporary OWNER TO postgres;

--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT pk_question_temporary PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_type_material FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_type_material_template FOREIGN KEY (type_material_template_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_temporary
    ADD CONSTRAINT fk_question_temporary_week FOREIGN KEY (week_id) REFERENCES academic.week(id);


--

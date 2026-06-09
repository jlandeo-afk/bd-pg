-- Table: questions.question_temporary
-- Includes constraints and indexes

--

CREATE TABLE questions.question_temporary (
    id bigint NOT NULL,
    question_id integer NOT NULL,
    cycle_id integer,
    week_id smallint,
    type_material_id smallint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    type_material_template_id smallint
);


ALTER TABLE questions.question_temporary OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT question_temporary_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_type_material_template_id_foreign FOREIGN KEY (type_material_template_id) REFERENCES odiseo.type_material_template(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_temporary
    ADD CONSTRAINT odiseo_question_temporary_week_id_foreign FOREIGN KEY (week_id) REFERENCES academic.week(id);


--

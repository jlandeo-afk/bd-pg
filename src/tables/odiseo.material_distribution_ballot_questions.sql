-- Table: odiseo.material_distribution_ballot_questions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_distribution_ballot_questions (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    week_type_material_id bigint NOT NULL,
    course_id smallint NOT NULL,
    "position" smallint NOT NULL,
    position_initial smallint NOT NULL,
    subtopic_id bigint,
    topic_id smallint,
    level_id bigint NOT NULL,
    usage_level_id bigint,
    question_id bigint,
    type character varying(255),
    usage_status boolean,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    absolute_position smallint,
    added_in_completion boolean DEFAULT false NOT NULL,
    removed_in_completion boolean DEFAULT false NOT NULL,
    parent_question_id integer,
    subquestion jsonb,
    type_text_id bigint,
    type_text_subcategory_id bigint,
    expected_type character varying(255),
    completed_subquestion boolean DEFAULT false NOT NULL,
    CONSTRAINT material_distribution_ballot_questions_type_check CHECK (((type)::text = ANY (ARRAY[('T'::character varying)::text, ('D'::character varying)::text])))
);


ALTER TABLE odiseo.material_distribution_ballot_questions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT material_distribution_ballot_questions_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_mdbq_course_lookup_status ON odiseo.material_distribution_ballot_questions USING btree (material_id, week, week_type_material_id) WHERE (fl_status = true);


--

--

CREATE INDEX idx_mdbq_upsert_lookup ON odiseo.material_distribution_ballot_questions USING btree (material_id, week, course_id) WHERE ((fl_status = true) AND (question_id IS NULL) AND (type_text_id IS NULL) AND (deleted_at IS NULL));


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT material_distribution_ballot_questions_parent_question_id_forei FOREIGN KEY (parent_question_id) REFERENCES odiseo.parent_question(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT material_distribution_ballot_questions_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT material_distribution_ballot_questions_type_text_subcategory_id FOREIGN KEY (type_text_subcategory_id) REFERENCES odiseo.type_text_subcategories(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_created_by_foreig FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_deleted_by_foreig FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_level_id_foreign FOREIGN KEY (level_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_material_id_forei FOREIGN KEY (material_id) REFERENCES odiseo.material(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_question_id_forei FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_subtopic_id_forei FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_type_material_id_ FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_updated_by_foreig FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_usage_level_id_fo FOREIGN KEY (usage_level_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.material_distribution_ballot_questions
    ADD CONSTRAINT odiseo_material_distribution_ballot_questions_week_type_materia FOREIGN KEY (week_type_material_id) REFERENCES odiseo.detail_week_type_mat(id);


--

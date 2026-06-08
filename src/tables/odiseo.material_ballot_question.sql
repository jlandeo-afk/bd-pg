-- Table: odiseo.material_ballot_question
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_ballot_question (
    id bigint NOT NULL,
    week_type_material_id bigint NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint,
    subtopic_id smallint,
    level_id bigint NOT NULL,
    type character varying(2),
    question_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    question_history_id bigint,
    "position" smallint,
    random boolean,
    fl_is_manual boolean DEFAULT false NOT NULL,
    parent_question_id bigint,
    type_text_id bigint,
    type_text_subcategory_id bigint,
    material_id bigint NOT NULL,
    week smallint NOT NULL,
    type_material_id smallint NOT NULL,
    position_initial smallint NOT NULL,
    absolute_position smallint,
    usage_level_id bigint,
    usage_status boolean DEFAULT true,
    added_in_completion boolean DEFAULT false,
    removed_in_completion boolean DEFAULT false,
    state character varying(30) DEFAULT 'MISSING'::character varying,
    completed_subquestion boolean DEFAULT false,
    expected_type character(2),
    entity_type character varying(10) GENERATED ALWAYS AS (
CASE
    WHEN (type_text_id IS NOT NULL) THEN 'TEXT'::text
    ELSE 'QUESTION'::text
END) STORED,
    CONSTRAINT chk_mbq_entity_purity CHECK ((((type_text_id IS NOT NULL) AND (question_id IS NULL)) OR ((type_text_id IS NULL) AND (type_text_subcategory_id IS NULL) AND (parent_question_id IS NULL)))),
    CONSTRAINT chk_mbq_expected_type CHECK (((expected_type = ANY (ARRAY['D'::bpchar, 'T'::bpchar])) OR ((expected_type IS NULL) AND (type_text_id IS NOT NULL)))),
    CONSTRAINT chk_mbq_state_consistency CHECK (((((state)::text = 'MISSING'::text) AND (question_id IS NULL) AND (parent_question_id IS NULL) AND (removed_in_completion = false)) OR (((state)::text = 'MANUAL_REMOVED'::text) AND (question_id IS NULL) AND (parent_question_id IS NULL) AND (removed_in_completion = true)) OR (((state)::text = 'GENERATED'::text) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = false)) OR (((state)::text = 'AUTO_COMPLETED'::text) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = true) AND (fl_is_manual = false)) OR (((state)::text = 'MANUAL_COMPLETED'::text) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)) AND (added_in_completion = true) AND (fl_is_manual = true)))),
    CONSTRAINT chk_mbq_type CHECK ((((type)::text = ANY ((ARRAY['D'::character varying, 'T'::character varying])::text[])) OR ((type IS NULL) AND (type_text_id IS NOT NULL))))
);


ALTER TABLE odiseo.material_ballot_question OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT material_ballot_question_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_mbq_unique_active_legacy ON odiseo.material_ballot_question USING btree (week_type_material_id, COALESCE(question_id, (0)::bigint), COALESCE(parent_question_id, (0)::bigint)) WHERE ((fl_status = true) AND (deleted_at IS NULL) AND ((question_id IS NOT NULL) OR (parent_question_id IS NOT NULL)));


--

--

CREATE INDEX idx_mbq_week_type_material_id ON odiseo.material_ballot_question USING btree (week_type_material_id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT fk_mbq_type_mat FOREIGN KEY (type_material_id) REFERENCES odiseo.type_material(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT fk_mbq_usage_level FOREIGN KEY (usage_level_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT material_ballot_question_parent_question_id_foreign FOREIGN KEY (parent_question_id) REFERENCES odiseo.parent_question(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT material_ballot_question_type_text_id_foreign FOREIGN KEY (type_text_id) REFERENCES odiseo.type_text(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT material_ballot_question_type_text_subcategory_id_foreign FOREIGN KEY (type_text_subcategory_id) REFERENCES odiseo.type_text_subcategories(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_level_id_foreign FOREIGN KEY (level_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_question_history_id_foreign FOREIGN KEY (question_history_id) REFERENCES odiseo.question_history_cycle(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_question
    ADD CONSTRAINT odiseo_material_ballot_question_week_type_material_id_foreign FOREIGN KEY (week_type_material_id) REFERENCES odiseo.detail_week_type_mat(id);


--

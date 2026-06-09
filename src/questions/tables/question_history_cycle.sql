-- Table: questions.question_history_cycle
-- Includes constraints and indexes

--

CREATE TABLE questions.question_history_cycle (
    id bigint NOT NULL,
    question_id bigint,
    cycle_id bigint NOT NULL,
    university_id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    automatic boolean DEFAULT true NOT NULL,
    parent_question_id bigint,
    subquestion jsonb
);


ALTER TABLE questions.question_history_cycle OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT question_history_cycle_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_qhc_covering_for_max_date ON questions.question_history_cycle USING btree (university_id, fl_status) INCLUDE (cycle_id, parent_question_id);


--

--

CREATE INDEX qhc_partial_active_idx ON questions.question_history_cycle USING btree (question_id, cycle_id, university_id, headquarters_id) WHERE (fl_status = true);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_headquarters_id_foreign FOREIGN KEY (headquarters_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_university_id_foreign FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT odiseo_question_history_cycle_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_history_cycle
    ADD CONSTRAINT question_history_cycle_parent_question_id_foreign FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

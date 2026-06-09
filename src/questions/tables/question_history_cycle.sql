-- Table: questions.question_history_cycle
-- Includes constraints and indexes

--

CREATE TABLE questions.question_history_cycle (
    id BIGINT NOT NULL,
    question_id BIGINT,
    cycle_id BIGINT NOT NULL,
    university_id smallint NOT NULL,
    headquarters_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    automatic BOOLEAN DEFAULT true NOT NULL,
    parent_question_id BIGINT,
    subquestion JSONB
);


ALTER TABLE questions.question_history_cycle OWNER TO postgres;

--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT pk_question_history_cycle PRIMARY KEY (id);


--

--

CREATE INDEX idx_question_history_cycle_university_id_fl_status ON questions.question_history_cycle USING btree (university_id, fl_status) INCLUDE (cycle_id, parent_question_id);


--

--

CREATE INDEX idx_question_history_cycle_question_id_cycle_id_university_i ON questions.question_history_cycle USING btree (question_id, cycle_id, university_id, headquarters_id) WHERE (fl_status = true);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_headquarters FOREIGN KEY (headquarters_id) REFERENCES odiseo.headquarters(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_question FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_university FOREIGN KEY (university_id) REFERENCES academic.origin_university(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_history_cycle
    ADD CONSTRAINT fk_question_history_cycle_parent_question FOREIGN KEY (parent_question_id) REFERENCES questions.parent_question(id);


--

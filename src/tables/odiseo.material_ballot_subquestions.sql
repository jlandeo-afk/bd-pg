-- Table: odiseo.material_ballot_subquestions
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_ballot_subquestions (
    id bigint NOT NULL,
    material_ballot_question_id bigint NOT NULL,
    question_id bigint,
    "position" smallint NOT NULL,
    state character varying(30) DEFAULT 'MISSING'::character varying NOT NULL,
    course_id smallint,
    topic_id smallint,
    subtopic_id smallint,
    fl_status boolean DEFAULT true NOT NULL,
    fl_is_manual boolean,
    added_in_completion boolean,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer,
    CONSTRAINT chk_mbs_state_consistency CHECK (((((state)::text = 'MISSING'::text) AND (question_id IS NULL)) OR (((state)::text = 'MANUAL_REMOVED'::text) AND (question_id IS NULL)) OR (((state)::text = 'GENERATED'::text) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = false)) OR (((state)::text = 'AUTO_COMPLETED'::text) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = true) AND (COALESCE(fl_is_manual, false) = false)) OR (((state)::text = 'MANUAL_COMPLETED'::text) AND (question_id IS NOT NULL) AND (COALESCE(added_in_completion, false) = true) AND (COALESCE(fl_is_manual, false) = true))))
);


ALTER TABLE odiseo.material_ballot_subquestions OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_ballot_subquestions
    ADD CONSTRAINT material_ballot_subquestions_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_mbs_parent_q ON odiseo.material_ballot_subquestions USING btree (material_ballot_question_id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_subquestions
    ADD CONSTRAINT fk_mbs_ballot_q FOREIGN KEY (material_ballot_question_id) REFERENCES odiseo.material_ballot_question(id);


--

--

ALTER TABLE ONLY odiseo.material_ballot_subquestions
    ADD CONSTRAINT fk_mbs_question FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

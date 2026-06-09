-- Table: materials.material_missing_question_detail
-- Includes constraints and indexes

--

CREATE TABLE materials.material_missing_question_detail (
    id bigint NOT NULL,
    material_missing_question_id bigint NOT NULL,
    material_ballot_question_id bigint NOT NULL,
    question_id bigint,
    employee_id bigint,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    assignment_type character varying(20),
    deleted_at timestamp(0) without time zone,
    CONSTRAINT chk_mmqd_assignment_type CHECK (((assignment_type)::text = ANY (ARRAY[('auto'::character varying)::text, ('manual'::character varying)::text]))),
    CONSTRAINT chk_mmqd_status CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('completed'::character varying)::text, ('canceled'::character varying)::text, ('assigned'::character varying)::text])))
);


ALTER TABLE materials.material_missing_question_detail OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_missing_question_detail
    ADD CONSTRAINT material_missing_question_detail_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_mmqd_parent_dist_lookup ON materials.material_missing_question_detail USING btree (material_missing_question_id, material_ballot_question_id) WHERE (deleted_at IS NULL);


--

--

CREATE INDEX idx_mmqd_parent_status_lookup ON materials.material_missing_question_detail USING btree (material_missing_question_id, status) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE ONLY materials.material_missing_question_detail
    ADD CONSTRAINT material_missing_question_detail_employee_id_foreign FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY materials.material_missing_question_detail
    ADD CONSTRAINT material_missing_question_detail_material_ballot_q FOREIGN KEY (material_ballot_question_id) REFERENCES materials.material_ballot_question(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY materials.material_missing_question_detail
    ADD CONSTRAINT material_missing_question_detail_material_missing_question_id_f FOREIGN KEY (material_missing_question_id) REFERENCES materials.material_missing_question(id);


--

--

ALTER TABLE ONLY materials.material_missing_question_detail
    ADD CONSTRAINT material_missing_question_detail_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

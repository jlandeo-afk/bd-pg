-- Table: materials.material_missing_question
-- Includes constraints and indexes

--

CREATE TABLE materials.material_missing_question (
    id bigint NOT NULL,
    material_id bigint NOT NULL,
    type_material_id smallint NOT NULL,
    week smallint NOT NULL,
    request_date timestamp(0) without time zone NOT NULL,
    expiration_date timestamp(0) without time zone GENERATED ALWAYS AS ((request_date + '3 days'::interval)) STORED NOT NULL,
    course_id smallint NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    CONSTRAINT chk_mmq_status CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('completed'::character varying)::text, ('completed_late'::character varying)::text, ('expired'::character varying)::text, ('canceled'::character varying)::text])))
);


ALTER TABLE materials.material_missing_question OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_mmq_active_lookup ON materials.material_missing_question USING btree (material_id, type_material_id, week, course_id, status) WHERE (deleted_at IS NULL);


--

--

CREATE UNIQUE INDEX uk_material_missing_question_pending_idx ON materials.material_missing_question USING btree (material_id, week, course_id, type_material_id) WHERE ((status)::text = 'pending'::text);


--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_course_id_foreign FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_material_id_foreign FOREIGN KEY (material_id) REFERENCES materials.material(id);


--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_type_material_id_foreign FOREIGN KEY (type_material_id) REFERENCES materials.type_material(id);


--

--

ALTER TABLE ONLY materials.material_missing_question
    ADD CONSTRAINT material_missing_question_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

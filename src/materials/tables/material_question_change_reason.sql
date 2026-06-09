-- Table: materials.material_question_change_reason
-- Includes constraints and indexes

--

CREATE TABLE materials.material_question_change_reason (
    id bigint NOT NULL,
    material_revision_course_id bigint NOT NULL,
    material_ballot_question_id bigint NOT NULL,
    old_question_id bigint NOT NULL,
    new_question_id bigint NOT NULL,
    reason text NOT NULL,
    created_by bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE materials.material_question_change_reason OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_question_change_reason
    ADD CONSTRAINT material_question_change_reason_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_question_change_reason
    ADD CONSTRAINT material_question_change_reason_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_question_change_reason
    ADD CONSTRAINT material_question_change_reason_material_ballot_question_id_for FOREIGN KEY (material_ballot_question_id) REFERENCES materials.material_ballot_question(id);


--

--

ALTER TABLE ONLY materials.material_question_change_reason
    ADD CONSTRAINT material_question_change_reason_material_revision_course_id_for FOREIGN KEY (material_revision_course_id) REFERENCES materials.material_revision_courses(id);


--

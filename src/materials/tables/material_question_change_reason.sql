-- Table: materials.material_question_change_reason
-- Includes constraints and indexes

--

CREATE TABLE materials.material_question_change_reason (
    id BIGINT NOT NULL,
    material_revision_course_id BIGINT NOT NULL,
    material_ballot_question_id BIGINT NOT NULL,
    old_question_id BIGINT NOT NULL,
    new_question_id BIGINT NOT NULL,
    reason TEXT NOT NULL,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE materials.material_question_change_reason OWNER TO postgres;

--

--

ALTER TABLE materials.material_question_change_reason
    ADD CONSTRAINT pk_material_question_change_reason PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_question_change_reason
    ADD CONSTRAINT fk_material_question_change_reason_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_question_change_reason
    ADD CONSTRAINT fk_material_question_change_reason_material_ballot_question FOREIGN KEY (material_ballot_question_id) REFERENCES materials.material_ballot_question(id);


--

--

ALTER TABLE materials.material_question_change_reason
    ADD CONSTRAINT fk_material_question_change_reason_material_revision_course FOREIGN KEY (material_revision_course_id) REFERENCES materials.material_revision_courses(id);


--

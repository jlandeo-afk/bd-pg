-- Table: materials.material_missing_question_tracking
-- Includes constraints and indexes

--

CREATE TABLE materials.material_missing_question_tracking (
    id BIGINT NOT NULL,
    material_missing_question_detail_id BIGINT NOT NULL,
    employee_id BIGINT,
    action VARCHAR(20) NOT NULL,
    assignment_type VARCHAR(20),
    created_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    CONSTRAINT chk_mmq_tracking_action CHECK (((action)::TEXT = ANY (ARRAY[('assigned'::VARCHAR)::TEXT, ('unassigned'::VARCHAR)::TEXT, ('reassigned'::VARCHAR)::TEXT, ('completed'::VARCHAR)::TEXT]))),
    CONSTRAINT chk_mmq_tracking_assignment_type CHECK (((assignment_type)::TEXT = ANY (ARRAY[('auto'::VARCHAR)::TEXT, ('manual'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_missing_question_tracking OWNER TO postgres;

--

--

ALTER TABLE materials.material_missing_question_tracking
    ADD CONSTRAINT pk_material_missing_question_tracking PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_missing_question_tracking
    ADD CONSTRAINT fk_material_missing_question_tracking_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_missing_question_tracking
    ADD CONSTRAINT fk_material_missing_question_tracking_material_missing_question_detail FOREIGN KEY (material_missing_question_detail_id) REFERENCES materials.material_missing_question_detail(id);


--

--

ALTER TABLE materials.material_missing_question_tracking
    ADD CONSTRAINT fk_material_missing_question_tracking_employee FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

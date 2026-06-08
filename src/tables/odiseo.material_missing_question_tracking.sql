-- Table: odiseo.material_missing_question_tracking
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_missing_question_tracking (
    id bigint NOT NULL,
    material_missing_question_detail_id bigint NOT NULL,
    employee_id bigint,
    action character varying(20) NOT NULL,
    assignment_type character varying(20),
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT chk_mmq_tracking_action CHECK (((action)::text = ANY (ARRAY[('assigned'::character varying)::text, ('unassigned'::character varying)::text, ('reassigned'::character varying)::text, ('completed'::character varying)::text]))),
    CONSTRAINT chk_mmq_tracking_assignment_type CHECK (((assignment_type)::text = ANY (ARRAY[('auto'::character varying)::text, ('manual'::character varying)::text])))
);


ALTER TABLE odiseo.material_missing_question_tracking OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_missing_question_tracking
    ADD CONSTRAINT material_missing_question_tracking_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.material_missing_question_tracking
    ADD CONSTRAINT fk_mmq_tracking_created_by FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_missing_question_tracking
    ADD CONSTRAINT fk_mmq_tracking_detail_id FOREIGN KEY (material_missing_question_detail_id) REFERENCES odiseo.material_missing_question_detail(id);


--

--

ALTER TABLE ONLY odiseo.material_missing_question_tracking
    ADD CONSTRAINT fk_mmq_tracking_employee_id FOREIGN KEY (employee_id) REFERENCES odiseo.employees(id);


--

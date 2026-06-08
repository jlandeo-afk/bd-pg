-- Table: odiseo.question_refuzed
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_refuzed (
    id bigint NOT NULL,
    category_rejected_id smallint NOT NULL,
    importance_rejected smallint NOT NULL,
    observation text NOT NULL,
    images text,
    question_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_active boolean DEFAULT true NOT NULL
);


ALTER TABLE odiseo.question_refuzed OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT question_refuzed_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_category_rejected_id_foreign FOREIGN KEY (category_rejected_id) REFERENCES odiseo.category_rejected(id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_importance_rejected_foreign FOREIGN KEY (importance_rejected) REFERENCES odiseo.importance_rejected(id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.question_refuzed
    ADD CONSTRAINT odiseo_question_refuzed_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

-- Table: odiseo.question_teacher_ia
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_teacher_ia (
    id bigint NOT NULL,
    description text NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    subtopic_id smallint NOT NULL,
    microtopic character varying(250),
    level_id bigint NOT NULL,
    answer_id bigint,
    theoretical_basis text,
    argumentation text,
    file character varying(255),
    format character varying(255),
    type character varying(50),
    category character varying(255),
    subcategory character varying(255),
    teacher_id bigint,
    status_revised boolean DEFAULT false NOT NULL,
    fl_parent boolean DEFAULT false NOT NULL,
    question_ia_id bigint,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    description_short text,
    answer_description text,
    version smallint DEFAULT '1'::smallint NOT NULL,
    chat_feedback_id bigint,
    nq_question_key uuid,
    level_old_id bigint,
    level_description text,
    content character varying(1000),
    verification_started_at timestamp(0) without time zone,
    verification_finished_at timestamp(0) without time zone
);


ALTER TABLE odiseo.question_teacher_ia OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_level_id_foreign FOREIGN KEY (level_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_level_old_id_foreign FOREIGN KEY (level_old_id) REFERENCES odiseo.level(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_teacher_id_foreign FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.question_teacher_ia
    ADD CONSTRAINT question_teacher_ia_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

-- Table: odiseo.question_history_course
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_history_course (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    code character varying(25),
    number character varying(25),
    course_id bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.question_history_course OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_history_course
    ADD CONSTRAINT question_history_course_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_history_course
    ADD CONSTRAINT odiseo_question_history_course_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.question_history_course
    ADD CONSTRAINT odiseo_question_history_course_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.question_history_course
    ADD CONSTRAINT odiseo_question_history_course_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

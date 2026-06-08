-- Table: odiseo.question_shares
-- Includes constraints and indexes

--

CREATE TABLE odiseo.question_shares (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    code character varying(255) NOT NULL,
    topic_id smallint NOT NULL,
    subtopic_id smallint NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer,
    course_id integer
);


ALTER TABLE odiseo.question_shares OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.question_shares
    ADD CONSTRAINT question_shares_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.question_shares
    ADD CONSTRAINT question_shares_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.question_shares
    ADD CONSTRAINT question_shares_question_id_foreign FOREIGN KEY (question_id) REFERENCES odiseo.question(id);


--

--

ALTER TABLE ONLY odiseo.question_shares
    ADD CONSTRAINT question_shares_subtopic_id_foreign FOREIGN KEY (subtopic_id) REFERENCES odiseo.subtopic(id);


--

--

ALTER TABLE ONLY odiseo.question_shares
    ADD CONSTRAINT question_shares_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

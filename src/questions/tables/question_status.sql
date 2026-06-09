-- Table: questions.question_status
-- Includes constraints and indexes

--

CREATE TABLE questions.question_status (
    id bigint NOT NULL,
    question_id bigint NOT NULL,
    status character varying(5) NOT NULL,
    process character varying(255) NOT NULL,
    description character varying(255),
    created_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    fl_active boolean DEFAULT true NOT NULL
);


ALTER TABLE questions.question_status OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_status
    ADD CONSTRAINT question_status_pkey PRIMARY KEY (id);


--

--

CREATE INDEX idx_qs_qid_status_created_perf ON questions.question_status USING btree (question_id, status, created_at);


--

--

CREATE INDEX idx_qstatus_qid_status_active ON questions.question_status USING btree (question_id, status) WHERE (fl_active = true);


--

--

ALTER TABLE ONLY questions.question_status
    ADD CONSTRAINT odiseo_question_status_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_status
    ADD CONSTRAINT odiseo_question_status_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

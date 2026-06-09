-- Table: questions.question_observation
-- Includes constraints and indexes

--

CREATE TABLE questions.question_observation (
    id bigint NOT NULL,
    description text NOT NULL,
    similitaries text DEFAULT '[]'::text NOT NULL,
    question_id bigint NOT NULL,
    type character varying(5) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    boards_observation text DEFAULT '[]'::text NOT NULL
);


ALTER TABLE questions.question_observation OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_observation
    ADD CONSTRAINT question_observation_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_observation
    ADD CONSTRAINT odiseo_question_observation_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_observation
    ADD CONSTRAINT odiseo_question_observation_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_observation
    ADD CONSTRAINT odiseo_question_observation_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_observation
    ADD CONSTRAINT odiseo_question_observation_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

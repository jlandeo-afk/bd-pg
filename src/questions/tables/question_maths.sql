-- Table: questions.question_maths
-- Includes constraints and indexes

--

CREATE TABLE questions.question_maths (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    question_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    properties json NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE questions.question_maths OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_maths
    ADD CONSTRAINT question_maths_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_maths
    ADD CONSTRAINT odiseo_question_maths_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_maths
    ADD CONSTRAINT odiseo_question_maths_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_maths
    ADD CONSTRAINT odiseo_question_maths_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_maths
    ADD CONSTRAINT odiseo_question_maths_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

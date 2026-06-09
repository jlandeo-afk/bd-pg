-- Table: questions.question_image
-- Includes constraints and indexes

--

CREATE TABLE questions.question_image (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    extension character varying(10),
    image text NOT NULL,
    question_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.question_image OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_image
    ADD CONSTRAINT question_image_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_image
    ADD CONSTRAINT odiseo_question_image_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_image
    ADD CONSTRAINT odiseo_question_image_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_image
    ADD CONSTRAINT odiseo_question_image_question_id_foreign FOREIGN KEY (question_id) REFERENCES questions.question(id);


--

--

ALTER TABLE ONLY questions.question_image
    ADD CONSTRAINT odiseo_question_image_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

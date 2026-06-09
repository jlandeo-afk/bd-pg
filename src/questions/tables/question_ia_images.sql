-- Table: questions.question_ia_images
-- Includes constraints and indexes

--

CREATE TABLE questions.question_ia_images (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    extension character varying(15) NOT NULL,
    image text NOT NULL,
    question_ia_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE questions.question_ia_images OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.question_ia_images
    ADD CONSTRAINT question_ia_images_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.question_ia_images
    ADD CONSTRAINT question_ia_images_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_ia_images
    ADD CONSTRAINT question_ia_images_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.question_ia_images
    ADD CONSTRAINT question_ia_images_question_ia_id_foreign FOREIGN KEY (question_ia_id) REFERENCES questions.question_teacher_ia(id);


--

--

ALTER TABLE ONLY questions.question_ia_images
    ADD CONSTRAINT question_ia_images_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

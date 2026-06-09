-- Table: questions.question_teacher_ia
-- Includes constraints and indexes

--

CREATE TABLE questions.question_teacher_ia (
    id BIGINT NOT NULL,
    description TEXT NOT NULL,
    course_id smallint NOT NULL,
    topic_id smallint NOT NULL,
    subtopic_id smallint NOT NULL,
    microtopic VARCHAR(250),
    level_id BIGINT NOT NULL,
    answer_id BIGINT,
    theoretical_basis TEXT,
    argumentation TEXT,
    file VARCHAR(255),
    format VARCHAR(255),
    type VARCHAR(50),
    category VARCHAR(255),
    subcategory VARCHAR(255),
    teacher_id BIGINT,
    status_revised BOOLEAN DEFAULT false NOT NULL,
    fl_parent BOOLEAN DEFAULT false NOT NULL,
    question_ia_id BIGINT,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    description_short TEXT,
    answer_description TEXT,
    version smallint DEFAULT '1'::smallint NOT NULL,
    chat_feedback_id BIGINT,
    nq_question_key UUID,
    level_old_id BIGINT,
    level_description TEXT,
    content VARCHAR(1000),
    verification_started_at TIMESTAMPTZ,
    verification_finished_at TIMESTAMPTZ
);


ALTER TABLE questions.question_teacher_ia OWNER TO postgres;

--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT pk_question_teacher_ia PRIMARY KEY (id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_level FOREIGN KEY (level_id) REFERENCES academic.level(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_level_old FOREIGN KEY (level_old_id) REFERENCES academic.level(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_subtopic FOREIGN KEY (subtopic_id) REFERENCES academic.subtopic(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_teacher FOREIGN KEY (teacher_id) REFERENCES odiseo.employees(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE questions.question_teacher_ia
    ADD CONSTRAINT fk_question_teacher_ia_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

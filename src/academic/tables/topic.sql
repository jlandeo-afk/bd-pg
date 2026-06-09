-- Table: academic.topic
-- Includes constraints and indexes

--

CREATE TABLE academic.topic (
    id smallint NOT NULL,
    code VARCHAR(3) NOT NULL,
    name VARCHAR(100) NOT NULL,
    course_id smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.topic OWNER TO postgres;

--

--

ALTER TABLE academic.topic
    ADD CONSTRAINT pk_topic PRIMARY KEY (id);


--

--

ALTER TABLE academic.topic
    ADD CONSTRAINT fk_topic_course FOREIGN KEY (course_id) REFERENCES academic.course(id);


--

--

ALTER TABLE academic.topic
    ADD CONSTRAINT fk_topic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.topic
    ADD CONSTRAINT fk_topic_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.topic
    ADD CONSTRAINT fk_topic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

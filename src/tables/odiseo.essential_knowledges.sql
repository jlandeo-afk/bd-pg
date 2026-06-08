-- Table: odiseo.essential_knowledges
-- Includes constraints and indexes

--

CREATE TABLE odiseo.essential_knowledges (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    course_id bigint NOT NULL,
    topic_id bigint NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    editor_content text NOT NULL,
    thumbnail text NOT NULL,
    created_by bigint NOT NULL,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.essential_knowledges OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.essential_knowledges
    ADD CONSTRAINT essential_knowledges_code_unique UNIQUE (code);


--

--

ALTER TABLE ONLY odiseo.essential_knowledges
    ADD CONSTRAINT essential_knowledges_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.essential_knowledges
    ADD CONSTRAINT essential_knowledges_course_id_foreign FOREIGN KEY (course_id) REFERENCES odiseo.course(id);


--

--

ALTER TABLE ONLY odiseo.essential_knowledges
    ADD CONSTRAINT essential_knowledges_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

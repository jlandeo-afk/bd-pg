-- Table: questions.image_galery_topic
-- Includes constraints and indexes

--

CREATE TABLE questions.image_galery_topic (
    id BIGINT NOT NULL,
    image_gallery_id BIGINT NOT NULL,
    topic_id BIGINT NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    fl_status BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE questions.image_galery_topic OWNER TO postgres;

--

--

ALTER TABLE questions.image_galery_topic
    ADD CONSTRAINT pk_image_galery_topic PRIMARY KEY (id);


--

--

ALTER TABLE questions.image_galery_topic
    ADD CONSTRAINT fk_image_galery_topic_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.image_galery_topic
    ADD CONSTRAINT fk_image_galery_topic_image_gallery FOREIGN KEY (image_gallery_id) REFERENCES questions.image_gallery(id);


--

--

ALTER TABLE questions.image_galery_topic
    ADD CONSTRAINT fk_image_galery_topic_topic FOREIGN KEY (topic_id) REFERENCES academic.topic(id);


--

--

ALTER TABLE questions.image_galery_topic
    ADD CONSTRAINT fk_image_galery_topic_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

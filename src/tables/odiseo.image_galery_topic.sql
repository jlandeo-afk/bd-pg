-- Table: odiseo.image_galery_topic
-- Includes constraints and indexes

--

CREATE TABLE odiseo.image_galery_topic (
    id bigint NOT NULL,
    image_gallery_id bigint NOT NULL,
    topic_id bigint NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    fl_status boolean DEFAULT true NOT NULL
);


ALTER TABLE odiseo.image_galery_topic OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.image_galery_topic
    ADD CONSTRAINT image_galery_topic_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.image_galery_topic
    ADD CONSTRAINT odiseo_image_galery_topic_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.image_galery_topic
    ADD CONSTRAINT odiseo_image_galery_topic_image_gallery_id_foreign FOREIGN KEY (image_gallery_id) REFERENCES odiseo.image_gallery(id);


--

--

ALTER TABLE ONLY odiseo.image_galery_topic
    ADD CONSTRAINT odiseo_image_galery_topic_topic_id_foreign FOREIGN KEY (topic_id) REFERENCES odiseo.topic(id);


--

--

ALTER TABLE ONLY odiseo.image_galery_topic
    ADD CONSTRAINT odiseo_image_galery_topic_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

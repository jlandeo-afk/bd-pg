-- Table: questions.image_gallery
-- Includes constraints and indexes

--

CREATE TABLE questions.image_gallery (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    image character varying(255) NOT NULL,
    width integer,
    height integer,
    extension character varying(255) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    path_full_version character varying(255),
    path_short_version character varying(255)
);


ALTER TABLE questions.image_gallery OWNER TO postgres;

--

--

ALTER TABLE ONLY questions.image_gallery
    ADD CONSTRAINT image_gallery_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY questions.image_gallery
    ADD CONSTRAINT odiseo_image_gallery_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.image_gallery
    ADD CONSTRAINT odiseo_image_gallery_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY questions.image_gallery
    ADD CONSTRAINT odiseo_image_gallery_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

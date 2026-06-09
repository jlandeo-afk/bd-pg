-- Table: questions.image_gallery
-- Includes constraints and indexes

--

CREATE TABLE questions.image_gallery (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    image VARCHAR(255) NOT NULL,
    width INTEGER,
    height INTEGER,
    extension VARCHAR(255) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    path_full_version VARCHAR(255),
    path_short_version VARCHAR(255)
);


ALTER TABLE questions.image_gallery OWNER TO postgres;

--

--

ALTER TABLE questions.image_gallery
    ADD CONSTRAINT pk_image_gallery PRIMARY KEY (id);


--

--

ALTER TABLE questions.image_gallery
    ADD CONSTRAINT fk_image_gallery_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.image_gallery
    ADD CONSTRAINT fk_image_gallery_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.image_gallery
    ADD CONSTRAINT fk_image_gallery_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

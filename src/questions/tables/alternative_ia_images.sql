-- Table: questions.alternative_ia_images
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative_ia_images (
    id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,
    extension VARCHAR(15) NOT NULL,
    image TEXT NOT NULL,
    alternative_ia_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.alternative_ia_images OWNER TO postgres;

--

--

ALTER TABLE questions.alternative_ia_images
    ADD CONSTRAINT pk_alternative_ia_images PRIMARY KEY (id);


--

--

ALTER TABLE questions.alternative_ia_images
    ADD CONSTRAINT fk_alternative_ia_images_alternative_ia FOREIGN KEY (alternative_ia_id) REFERENCES questions.alternative_questions_ia(id);


--

--

ALTER TABLE questions.alternative_ia_images
    ADD CONSTRAINT fk_alternative_ia_images_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_ia_images
    ADD CONSTRAINT fk_alternative_ia_images_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_ia_images
    ADD CONSTRAINT fk_alternative_ia_images_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

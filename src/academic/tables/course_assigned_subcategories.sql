-- Table: academic.course_assigned_subcategories
-- Includes constraints and indexes (Refactored to clean DB standards)

CREATE TABLE academic.course_assigned_subcategories (
    id BIGINT NOT NULL,
    course_assigned_category_id BIGINT NOT NULL,
    subcategory_id INTEGER NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,

    CONSTRAINT pk_course_assigned_subcategories PRIMARY KEY (id)
);

ALTER TABLE academic.course_assigned_subcategories OWNER TO postgres;

-- Indexes
CREATE UNIQUE INDEX uq_course_assigned_subcategories_active_mapping 
    ON academic.course_assigned_subcategories (course_assigned_category_id, subcategory_id) 
    WHERE (deleted_at IS NULL);

CREATE INDEX idx_course_assigned_subcategories_subcategory 
    ON academic.course_assigned_subcategories (subcategory_id);

-- FOREIGN KEY Constraints
ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_course_assigned_category FOREIGN KEY (course_assigned_category_id) REFERENCES academic.course_assigned_categories(id)
    ON DELETE CASCADE;

ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_subcategory FOREIGN KEY (subcategory_id) REFERENCES common.type_text_subcategories(id)
    ON DELETE RESTRICT;

ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id)
    ON DELETE RESTRICT;

ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id)
    ON DELETE RESTRICT;

ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id)
    ON DELETE RESTRICT;

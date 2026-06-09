-- Table: common.category_rejected
-- Includes constraints and indexes

--

CREATE TABLE common.category_rejected (
    id smallint NOT NULL,
    name character varying(100) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE common.category_rejected OWNER TO postgres;

--

--

ALTER TABLE ONLY common.category_rejected
    ADD CONSTRAINT category_rejected_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.category_rejected
    ADD CONSTRAINT odiseo_category_rejected_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.category_rejected
    ADD CONSTRAINT odiseo_category_rejected_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.category_rejected
    ADD CONSTRAINT odiseo_category_rejected_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

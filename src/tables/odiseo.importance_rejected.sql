-- Table: odiseo.importance_rejected
-- Includes constraints and indexes

--

CREATE TABLE odiseo.importance_rejected (
    id smallint NOT NULL,
    level smallint NOT NULL,
    name character varying(100) NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.importance_rejected OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.importance_rejected
    ADD CONSTRAINT importance_rejected_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.importance_rejected
    ADD CONSTRAINT odiseo_importance_rejected_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.importance_rejected
    ADD CONSTRAINT odiseo_importance_rejected_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.importance_rejected
    ADD CONSTRAINT odiseo_importance_rejected_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

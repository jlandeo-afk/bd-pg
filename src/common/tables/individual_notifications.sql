-- Table: common.individual_notifications
-- Includes constraints and indexes

--

CREATE TABLE common.individual_notifications (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    message character varying(255) NOT NULL,
    url_internal character varying(255),
    user_id bigint NOT NULL,
    type bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    fl_read boolean DEFAULT false NOT NULL,
    created_by bigint,
    updated_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE common.individual_notifications OWNER TO postgres;

--

--

ALTER TABLE ONLY common.individual_notifications
    ADD CONSTRAINT individual_notifications_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY common.individual_notifications
    ADD CONSTRAINT odiseo_individual_notifications_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.individual_notifications
    ADD CONSTRAINT odiseo_individual_notifications_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY common.individual_notifications
    ADD CONSTRAINT odiseo_individual_notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES auth.users(id);


--

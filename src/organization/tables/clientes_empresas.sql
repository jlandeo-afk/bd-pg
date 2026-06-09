-- Table: organization.clientes_empresas
-- Includes constraints and indexes

--

CREATE TABLE organization.clientes_empresas (
    id bigint NOT NULL,
    ruc character varying(255) NOT NULL,
    razon_social character varying(255) NOT NULL,
    tipo character varying(255) NOT NULL,
    nombre_comercial character varying(255) NOT NULL,
    direccion character varying(255) NOT NULL,
    departamento_id bigint NOT NULL,
    provincia_id bigint NOT NULL,
    distrito_id bigint NOT NULL,
    numero_estudiantes integer,
    numero_colaboradores integer,
    nivel_educativo character varying(255),
    correo_contacto_principal character varying(255) NOT NULL,
    correo_facturacion character varying(255),
    telefono character varying(255),
    pagina_web character varying(255),
    facebook character varying(255),
    instagram character varying(255),
    tiktok character varying(255),
    plan_contratado character varying(255) DEFAULT 'Free'::character varying NOT NULL,
    fecha_inicio date NOT NULL,
    modalidad_pago character varying(255),
    subdominio character varying(255) NOT NULL,
    estado character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    company_id integer
);


ALTER TABLE organization.clientes_empresas OWNER TO postgres;

--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_ruc_unique UNIQUE (ruc);


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_subdominio_unique UNIQUE (subdominio);


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_company_id_foreign FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_departamento_id_foreign FOREIGN KEY (departamento_id) REFERENCES organization.region(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_distrito_id_foreign FOREIGN KEY (distrito_id) REFERENCES organization.districts(id) ON DELETE SET NULL;


--

--

ALTER TABLE ONLY organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_provincia_id_foreign FOREIGN KEY (provincia_id) REFERENCES organization.provinces(id) ON DELETE SET NULL;


--

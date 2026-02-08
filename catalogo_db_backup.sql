--
-- PostgreSQL database dump
--

\restrict OjhYDTXCtX3NPrNVbPejHbZC6vl0QUR5wCS3wtplmS2P1eNObK5mtbHINAnJxbh

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: access_logs; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.access_logs (
    id integer NOT NULL,
    ip character varying(100),
    username character varying(100),
    path character varying(500) NOT NULL,
    method character varying(10) NOT NULL,
    user_agent character varying(500),
    referer character varying(500),
    "timestamp" timestamp without time zone
);


ALTER TABLE public.access_logs OWNER TO catalogo_user;

--
-- Name: access_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.access_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.access_logs_id_seq OWNER TO catalogo_user;

--
-- Name: access_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.access_logs_id_seq OWNED BY public.access_logs.id;


--
-- Name: comentarios_tickets; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.comentarios_tickets (
    id integer NOT NULL,
    ticket_id integer NOT NULL,
    ingeniero_id integer NOT NULL,
    contenido text NOT NULL,
    imagen_url character varying(500),
    fecha_creacion timestamp without time zone
);


ALTER TABLE public.comentarios_tickets OWNER TO catalogo_user;

--
-- Name: comentarios_tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.comentarios_tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comentarios_tickets_id_seq OWNER TO catalogo_user;

--
-- Name: comentarios_tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.comentarios_tickets_id_seq OWNED BY public.comentarios_tickets.id;


--
-- Name: historial_precios_proveedor; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.historial_precios_proveedor (
    id integer NOT NULL,
    producto_proveedor_id integer NOT NULL,
    precio double precision NOT NULL,
    fecha_precio date NOT NULL,
    notas text,
    fecha_creacion timestamp without time zone
);


ALTER TABLE public.historial_precios_proveedor OWNER TO catalogo_user;

--
-- Name: historial_precios_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.historial_precios_proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.historial_precios_proveedor_id_seq OWNER TO catalogo_user;

--
-- Name: historial_precios_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.historial_precios_proveedor_id_seq OWNED BY public.historial_precios_proveedor.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    module character varying(100) NOT NULL,
    action character varying(50) NOT NULL,
    descripcion character varying(255)
);


ALTER TABLE public.permissions OWNER TO catalogo_user;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_id_seq OWNER TO catalogo_user;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: producto_proveedor; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.producto_proveedor (
    id integer NOT NULL,
    producto_id integer NOT NULL,
    proveedor_id integer NOT NULL,
    precio_proveedor double precision NOT NULL,
    fecha_precio date,
    cantidad_minima integer,
    fecha_creacion timestamp without time zone
);


ALTER TABLE public.producto_proveedor OWNER TO catalogo_user;

--
-- Name: producto_proveedor_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.producto_proveedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.producto_proveedor_id_seq OWNER TO catalogo_user;

--
-- Name: producto_proveedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.producto_proveedor_id_seq OWNED BY public.producto_proveedor.id;


--
-- Name: productos; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.productos (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    descripcion text,
    precio double precision NOT NULL,
    cantidad integer,
    imagen_url character varying(500),
    categoria character varying(100),
    fecha_creacion timestamp without time zone,
    fecha_actualizacion timestamp without time zone
);


ALTER TABLE public.productos OWNER TO catalogo_user;

--
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.productos_id_seq OWNER TO catalogo_user;

--
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- Name: proveedores; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.proveedores (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    telefono character varying(20),
    rfc character varying(13),
    domicilio text,
    correo character varying(255),
    contacto character varying(255),
    notas text,
    fecha_creacion timestamp without time zone,
    fecha_actualizacion timestamp without time zone
);


ALTER TABLE public.proveedores OWNER TO catalogo_user;

--
-- Name: proveedores_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.proveedores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.proveedores_id_seq OWNER TO catalogo_user;

--
-- Name: proveedores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.proveedores_id_seq OWNED BY public.proveedores.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO catalogo_user;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(80) NOT NULL,
    descripcion character varying(255)
);


ALTER TABLE public.roles OWNER TO catalogo_user;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO catalogo_user;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.tickets (
    id integer NOT NULL,
    numero_ticket character varying(20) NOT NULL,
    titulo character varying(255) NOT NULL,
    descripcion text NOT NULL,
    nombre_solicitante character varying(100) NOT NULL,
    email_solicitante character varying(100),
    departamento character varying(100),
    ingeniero_id integer,
    estado character varying(20),
    prioridad character varying(20),
    categoria character varying(100),
    fecha_creacion timestamp without time zone,
    fecha_asignacion timestamp without time zone,
    fecha_resolucion timestamp without time zone,
    fecha_actualizacion timestamp without time zone
);


ALTER TABLE public.tickets OWNER TO catalogo_user;

--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.tickets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tickets_id_seq OWNER TO catalogo_user;

--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: catalogo_user
--

CREATE TABLE public.usuarios (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    correo character varying(255),
    es_admin boolean,
    activo boolean,
    fecha_creacion timestamp without time zone,
    fecha_actualizacion timestamp without time zone,
    role_id integer
);


ALTER TABLE public.usuarios OWNER TO catalogo_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE; Schema: public; Owner: catalogo_user
--

CREATE SEQUENCE public.usuarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuarios_id_seq OWNER TO catalogo_user;

--
-- Name: usuarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: catalogo_user
--

ALTER SEQUENCE public.usuarios_id_seq OWNED BY public.usuarios.id;


--
-- Name: access_logs id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.access_logs ALTER COLUMN id SET DEFAULT nextval('public.access_logs_id_seq'::regclass);


--
-- Name: comentarios_tickets id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.comentarios_tickets ALTER COLUMN id SET DEFAULT nextval('public.comentarios_tickets_id_seq'::regclass);


--
-- Name: historial_precios_proveedor id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.historial_precios_proveedor ALTER COLUMN id SET DEFAULT nextval('public.historial_precios_proveedor_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: producto_proveedor id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.producto_proveedor ALTER COLUMN id SET DEFAULT nextval('public.producto_proveedor_id_seq'::regclass);


--
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- Name: proveedores id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.proveedores ALTER COLUMN id SET DEFAULT nextval('public.proveedores_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: usuarios id; Type: DEFAULT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.usuarios ALTER COLUMN id SET DEFAULT nextval('public.usuarios_id_seq'::regclass);


--
-- Data for Name: access_logs; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.access_logs (id, ip, username, path, method, user_agent, referer, "timestamp") FROM stdin;
1	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:33:38.887403
2	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 01:34:37.887926
3	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:36:44.389051
4	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:38:06.768725
5	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:38:06.994935
6	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:07.119649
7	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:07.127634
8	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:07.126054
9	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:07.129206
10	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:15.553241
11	192.168.0.94	root	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:27.407092
12	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:27.437009
13	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:27.456375
14	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:38:32.068396
15	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:38:38.003487
16	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:38:38.230715
17	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:38.309929
18	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:38.309931
19	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:38.323623
20	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:38.32749
21	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:47.616569
22	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:38:55.477372
23	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:38:55.594213
24	192.168.0.94	admin	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:39:04.286493
25	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:39:04.320202
26	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:39:04.335931
27	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:39:20.818075
28	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 01:39:21.035502
29	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:39:21.109726
30	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:39:21.110496
31	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:39:21.126754
32	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:39:21.134721
33	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:39:46.075889
34	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:57:26.729156
35	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:26.894835
36	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:26.899388
37	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:26.899389
38	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:26.901884
39	192.168.0.94	root	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:29.147737
40	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 01:57:29.215726
41	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 01:57:29.216186
42	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:57:36.278734
43	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 01:57:53.833429
44	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:53.936511
45	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:53.942687
46	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:53.961239
48	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:58:00.576506
50	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:58:21.977701
2384	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 02:17:36.297648
2388	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 04:06:35.72422
2392	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 05:13:28.420988
2393	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 05:17:44.02258
2397	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:06:43.515212
2403	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-30 06:07:26.012837
3933	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 21:14:43.629533
3934	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 21:18:00.77977
3936	192.168.0.94	\N	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login_tickets	2025-12-16 21:24:13.463516
3951	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:29:57.969245
3963	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 23:30:22.040912
3964	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 00:04:47.902654
3965	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-17 00:13:38.441947
3967	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 00:30:27.722013
3968	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 01:04:59.881323
3970	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 02:05:23.198864
3971	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 02:30:30.657548
3974	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 04:05:53.444498
3975	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 04:30:35.069325
3985	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 09:30:38.626633
3988	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 11:06:14.23147
3992	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:30:46.343392
3997	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:58:04.981868
4004	192.168.0.105	admin	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 13:00:43.724441
4005	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:06:37.98755
4014	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:30:52.569234
4015	192.168.0.85	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:34:10.455128
4018	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:06:43.113414
4020	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:28:12.232406
47	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:57:53.963499
51	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:58:30.317374
54	192.168.0.94	root	/api/proveedores	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:58:38.885052
2385	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 03:06:33.923001
2386	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 03:13:21.809386
2389	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 04:13:25.970856
2391	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 05:06:31.817237
3935	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 21:23:59.128379
3938	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 21:24:13.818007
3943	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 21:24:45.726958
3944	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 21:24:45.752442
3950	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:29:10.270942
3953	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:51:16.413386
3955	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:12:59.885516
3956	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:28:25.478938
3958	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:30:16.111564
3962	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 23:28:34.6661
3969	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 01:30:28.798119
3973	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 03:30:33.72059
3980	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 07:06:00.835695
3984	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 09:06:08.324497
3990	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:06:14.389147
3994	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:42:28.690982
3995	192.168.0.105	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 12:58:00.98283
4009	192.168.0.142	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:36:32.626622
4011	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:06:39.402633
4012	192.168.0.224	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:11:40.730368
4013	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:28:12.55024
4016	192.168.0.142	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:36:22.320064
49	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:58:12.850092
2387	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 03:17:39.991085
2390	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 04:17:41.35538
2395	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:06:43.303434
2396	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:06:43.515212
2399	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:07:01.154254
2401	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-30 06:07:25.914349
2402	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-30 06:07:26.005974
3940	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 21:24:16.02155
3941	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 21:24:16.147304
3948	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/admin	2025-12-16 21:24:47.901807
3957	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:29:16.163936
3972	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 03:05:46.405548
3976	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 05:05:55.832348
3977	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 05:30:33.07713
3979	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 06:30:39.395492
3981	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 07:30:36.450137
3983	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 08:30:42.218288
3987	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 10:30:43.606716
3989	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 11:30:41.426404
3991	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:28:02.10316
3993	192.168.0.85	\N	/	GET	HomeNet/1.0	\N	2025-12-17 12:34:09.202168
3999	192.168.0.105	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 13:00:38.439425
4000	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 13:00:38.657685
4001	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 13:00:38.709137
4007	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:30:47.982373
4008	192.168.0.85	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:34:04.802417
4019	192.168.0.224	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:11:43.040869
52	192.168.0.94	root	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 01:58:32.048639
53	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:58:32.133991
55	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:58:39.457021
56	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:58:46.911729
57	192.168.0.94	root	/api/proveedores/3	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:59:00.098878
58	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 01:59:00.198252
59	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 01:59:01.491671
60	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 01:59:07.142972
61	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 02:12:31.247017
62	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 02:19:13.387589
63	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 02:19:13.465297
64	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 02:19:13.467227
65	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 02:19:13.480775
66	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 02:19:13.492168
67	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 02:38:57.741373
68	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 02:59:03.540022
69	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 03:15:48.429141
70	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 03:35:16.29235
71	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 03:39:15.16472
72	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 03:59:04.483487
73	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 04:15:54.64111
74	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 04:35:35.729524
75	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 04:39:13.934532
76	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 04:59:06.470096
77	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 05:21:47.017623
78	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 05:35:45.290017
79	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 05:59:08.098821
80	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 06:21:50.829223
81	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 06:35:49.2614
82	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 06:59:11.203543
83	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 07:21:56.475151
84	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 07:59:15.699211
85	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 08:22:03.765081
86	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 08:36:35.7793
87	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 08:59:13.794911
88	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 09:22:05.84262
89	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 09:37:12.271111
90	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 09:59:19.355194
91	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 10:23:28.134119
92	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 10:59:22.720622
93	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 10:59:30.463316
94	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 11:23:39.439625
95	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 11:37:46.479625
96	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 11:59:22.395782
97	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 11:59:37.882698
98	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:24:02.412565
99	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:37:49.102945
100	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:44:04.988965
101	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:48:34.060206
102	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:59:26.987228
103	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 12:59:38.942908
104	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:24:04.642882
105	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:00.82518
106	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:25:02.340361
107	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:02.433361
108	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:02.423191
109	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:02.428118
110	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:02.431943
111	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:11.953604
112	192.168.0.94	root	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:22.185147
113	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:25:22.24292
114	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:25:22.243827
115	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:25:23.467059
116	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:23.535064
117	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:23.543081
118	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:23.545337
119	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:23.540782
172	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:41:49.135021
120	192.168.0.94	root	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:24.270501
124	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:27.259122
2394	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 06:06:34.446742
2398	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:07:00.966289
2400	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 06:07:01.158989
2404	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-30 06:11:40.566641
4021	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:30:52.259658
4026	192.168.0.105	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 15:31:20.467915
4031	192.168.0.105	ing_maria	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:25.778865
4046	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:32:54.812218
121	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:25:24.320639
125	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:27.266727
2405	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-30 06:12:32.596059
2406	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-30 06:12:32.753166
2411	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:13:04.247988
2416	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:13:12.009873
2417	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:13:14.051975
2418	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:13:14.101656
2420	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 06:13:20.618419
4022	192.168.0.105	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 15:30:57.392288
4023	192.168.0.105	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 15:30:57.410667
4025	192.168.0.105	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 15:31:20.444018
4027	192.168.0.105	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 15:32:09.417131
4030	192.168.0.105	ing_maria	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:09.704976
4036	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:32:38.297074
4043	192.168.0.105	admin	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:53.067677
122	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:25:27.123746
126	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:27.264782
2407	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-30 06:12:32.756888
2408	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-30 06:12:56.71001
2409	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:12:56.863408
2412	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:13:04.267009
2413	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:13:11.626324
2414	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:13:11.865104
2415	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:13:12.009866
4024	192.168.0.105	\N	/tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 15:31:10.82354
4028	192.168.0.105	ing_maria	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 15:32:09.63405
4029	192.168.0.105	ing_maria	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:09.704976
4032	192.168.0.105	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:25.798615
4035	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 15:32:38.199934
4037	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:32:38.297074
4038	192.168.0.105	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:32:46.427721
4040	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:32:46.48716
4041	192.168.0.105	admin	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:32:53.035168
123	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:25:27.261252
127	192.168.0.94	root	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:26:09.482417
128	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:26:09.565569
129	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:26:10.801404
130	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:26:10.856211
131	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:26:10.861482
132	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:26:10.87192
133	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:26:10.870194
134	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:29:08.51249
135	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:34:48.664541
136	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 13:34:50.18111
137	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:34:50.270216
138	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:34:50.271577
139	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:34:50.291839
140	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:34:50.295917
141	192.168.0.94	root	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:27.925206
142	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:35:27.991862
143	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:35:27.998525
144	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:35:29.450644
145	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:29.514473
146	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:29.518772
147	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:29.520818
148	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:29.520481
149	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:32.544948
150	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:32.619808
151	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:32.621297
152	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:32.616502
153	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:32.624428
154	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:58.223191
155	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:35:58.223898
156	192.168.0.94	root	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:36:03.85653
157	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:36:03.931509
158	192.168.0.94	root	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:36:03.932449
159	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 13:36:05.720335
160	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:36:05.795007
161	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:36:05.796293
162	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:36:05.814523
163	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:36:05.817278
164	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:37:49.640403
165	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:14.270706
166	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:15.809669
167	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:15.885863
168	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:15.887637
169	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:15.900787
171	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:40:37.290696
170	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:40:15.910378
173	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:56.950765
174	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:58.516681
175	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:58.581228
177	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:58.595599
182	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:22.152793
187	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:28.171798
2410	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:12:56.869383
4033	192.168.0.105	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 15:32:32.337481
4034	192.168.0.105	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 15:32:37.965471
4039	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:32:46.487169
4042	192.168.0.105	admin	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:53.06768
4044	192.168.0.105	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:32:54.756177
4045	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:32:54.812213
176	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:58.584128
184	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 13:49:27.864238
2419	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:13:14.105941
4047	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:33:43.3002
4048	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:33:43.383763
4050	192.168.0.85	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:34:22.2415
4052	192.168.0.105	admin	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:45.487135
4056	192.168.0.105	admin	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:46.979432
4062	192.168.0.142	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:36:23.656861
4067	192.168.0.105	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:36:41.342226
4069	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:36:41.373455
4076	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:33.021353
4087	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:06:47.254079
4090	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:30:54.31155
4092	192.168.0.142	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:36:25.263164
178	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:44:58.610638
179	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:48:37.422254
180	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:08.965995
188	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:28.182715
2421	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:14:55.659607
2422	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:14:55.723231
2424	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-30 06:15:19.937994
2426	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:15:20.057453
2428	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:15:22.580178
2433	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:15:30.099473
4049	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:33:43.383776
4054	192.168.0.105	admin	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:46.913523
4057	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:48.033705
4059	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:34:48.079226
4065	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:36:40.156353
4080	192.168.0.105	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:39:37.18987
4081	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:39:37.230785
4082	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:39:38.740565
4084	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:38.769695
4086	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 15:58:54.365109
4088	192.168.0.224	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:11:40.793477
4091	192.168.0.85	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:34:19.609357
4093	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:58:55.555211
181	192.168.0.94	root	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:22.12714
183	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:22.16744
185	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 13:49:28.091992
186	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:28.16919
189	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:49:28.183925
190	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:55:33.621667
191	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:44.226811
192	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:52.472274
193	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:52.5839
194	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:52.593174
196	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:52.611162
195	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 13:58:52.611238
197	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 13:59:26.620981
198	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 14:09:56.840402
199	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 14:12:32.291364
200	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:24:07.605979
201	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:38:04.278847
202	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:40:37.969708
203	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:55:36.992874
204	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:59:30.013156
205	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 14:59:45.276769
206	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:24:09.801875
207	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 15:27:13.108837
208	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 15:27:16.458309
209	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 15:27:20.533234
210	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:38:05.73119
211	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:40:43.20517
212	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:55:37.945896
213	192.168.0.139	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	http://192.168.0.192/admin	2025-11-20 15:57:41.69159
214	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:59:32.412252
215	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 15:59:47.93822
216	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:36.680651
217	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:37.991978
218	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:38.127231
219	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:38.13883
220	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:38.155586
221	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:38.158598
222	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:38.893141
223	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:00:38.995545
224	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:00:39.006981
225	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:42.763062
226	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:00:42.844483
227	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:00:42.844479
228	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:00:46.036299
229	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:46.091826
230	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:46.093081
231	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:46.096194
232	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:00:46.100554
233	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 16:06:31.90125
234	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 16:06:33.157606
235	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:33.243489
240	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:40.750888
236	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:33.262693
237	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:34.24404
238	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:37.684688
239	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:06:37.685837
242	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:06:40.808726
243	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:00.904287
244	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:10:00.958875
245	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:10:00.958875
246	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:10:02.756421
247	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:02.81369
249	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:02.818695
250	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:02.843167
251	192.168.0.94	\N	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:51.517021
252	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:10:52.396213
254	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 16:10:56.869632
257	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:01.954646
259	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:01.959855
260	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:01.979365
261	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:04.9065
262	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:04.971362
263	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:04.973664
264	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:06.099176
265	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:06.16655
266	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:06.165102
268	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:06.169461
269	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:07.123177
270	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 16:11:07.198491
271	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 16:11:08.402211
273	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:08.53027
274	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:10.452046
275	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:10.522117
276	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:10.52391
278	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:10.530994
281	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:17.102778
2423	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:14:55.73131
2425	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:15:20.057561
2430	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:15:27.974142
2431	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:15:28.088951
4051	192.168.0.105	admin	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:34:45.449771
4053	192.168.0.105	admin	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:45.487136
4058	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:34:48.080278
241	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:06:40.808566
248	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:10:02.818162
253	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:10:52.412747
255	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 16:11:01.645154
256	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 16:11:01.871589
258	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:01.956784
267	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:06.167895
272	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:08.523679
277	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:10.53342
279	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:11:17.047457
280	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:11:17.101553
282	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:00.739498
283	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:14:00.797608
284	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:14:00.806146
285	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:14:02.634113
286	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:02.724436
287	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:02.73156
288	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:02.739036
289	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:02.750453
290	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:14:17.969981
291	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:17:00.584826
292	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:17:02.100087
293	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:17:02.185635
294	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:17:02.188775
295	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:17:02.191667
296	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:17:02.212459
297	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-20 16:17:11.496372
298	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-20 16:17:11.521359
299	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-20 16:17:17.172007
300	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-20 16:17:17.383719
301	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:17.52656
302	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:17.528323
303	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:17.547408
304	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:17.551999
305	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:19.208069
307	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-20 16:17:19.26266
306	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-20 16:17:19.26266
308	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-20 16:17:21.619159
309	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:21.675086
310	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:21.676839
752	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:36:15.182989
311	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:21.714436
2427	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:15:22.549672
2434	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:15:30.138424
4055	192.168.0.105	admin	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-17 15:34:46.978085
4061	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:34:50.681434
4064	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:36:40.069304
4068	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:36:41.374345
4070	192.168.0.105	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:36:49.256787
4071	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:36:49.299017
4074	192.168.0.105	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:39:32.987523
4075	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:33.021023
4077	192.168.0.105	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:34.939775
4079	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:39:34.980591
4085	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:39.57287
4089	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-17 16:28:21.539756
312	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:21.718658
313	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 16:17:41.535095
314	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:24:10.769318
315	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:38:19.351889
316	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:40:42.184649
317	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:32.844439
318	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:48:33.962967
319	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:34.051198
320	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:34.054614
321	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:34.063737
322	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:34.086029
323	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:36.151095
324	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:48:36.249376
325	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:48:36.251458
326	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 16:48:38.143456
327	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:48:38.198773
328	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 16:48:38.200635
329	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:48:53.60514
330	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:55:40.244643
331	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:59:35.949048
332	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 16:59:46.310163
333	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:30.185257
334	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:02:30.242986
335	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:02:30.243748
336	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:02:31.449481
337	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:31.52196
338	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:31.527006
339	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:31.528824
340	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:31.531615
341	192.168.0.94	admin	/api/productos	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:57.207098
342	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:02:57.305066
343	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:03:02.618959
344	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:02.693581
345	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:02.695617
346	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:02.698814
347	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:02.702452
348	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:04.63814
349	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:03:04.694542
350	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:03:04.6947
351	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:03:05.933417
352	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:06.025376
353	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:06.025718
354	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:06.030819
355	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:03:06.03031
356	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:07:07.208116
357	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:07:43.68633
358	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:07:43.748819
359	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:07:45.555145
361	192.168.0.94	admin	/api/proveedores	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:08:07.406327
362	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:08:07.979903
365	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:08.690244
377	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:30.331281
381	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:33.470305
382	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:33.531391
387	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:42.069743
389	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:44.288354
2429	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:15:27.747697
2432	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:15:28.089053
2435	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:15:30.138425
4060	192.168.0.105	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:34:50.625592
4063	192.168.0.105	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:36:36.621165
4066	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:36:40.157705
4072	192.168.0.105	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:39:30.769568
4073	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/proveedores	2025-12-17 15:39:30.814687
4078	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/	2025-12-17 15:39:34.980591
4083	192.168.0.105	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 15:39:38.769695
360	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:07:45.66799
368	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:15.131004
373	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:30.231195
376	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:30.303039
378	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:32.418841
380	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:32.491329
385	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:33.539374
388	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:44.214775
390	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:44.289761
391	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:46.507193
392	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:46.572429
2436	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:16:50.459756
2437	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:16:50.530461
363	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:08:08.631277
364	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:08.688776
367	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:08.715533
369	192.168.0.94	admin	/api/productos/upload-imagen	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:26.391841
375	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:30.301361
384	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:33.534612
386	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:42.069743
393	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:46.58483
2438	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:16:50.534118
2439	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 06:18:11.545853
366	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:08.692886
370	192.168.0.94	admin	/api/productos	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:26.428085
371	192.168.0.94	admin	/api/productos/36/proveedores	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:26.461951
372	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:26.560588
374	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:30.291219
379	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:08:32.488659
383	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:33.535291
394	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:46.585328
395	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:08:46.603023
396	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:10:30.900835
397	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:30.987161
398	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:30.9968
399	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:31.002206
400	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:31.038757
401	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:10:33.887088
402	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:33.95688
403	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:33.963472
404	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:33.971033
405	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:33.972375
406	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:35.264977
407	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:10:35.33708
408	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:10:35.334816
409	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:10:36.552386
410	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:36.622816
411	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:36.624943
412	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:36.622136
413	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:36.620739
414	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:39.028486
415	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:10:39.088224
416	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:10:42.201556
417	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:42.269815
418	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:42.272619
419	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:42.27517
420	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:10:42.281738
421	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 17:22:01.849761
422	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:01.946217
423	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:01.947421
424	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:01.943973
425	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:01.95577
426	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:03.619767
427	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:03.69202
428	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:03.696366
431	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:11.51167
809	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-21 01:24:46.366031
429	192.168.0.94	admin	/uploads/productos/20251120_170826_D_NQ_NP_2X_643781-CBT94701761258_102025-F-medidor-de-potencia-optica-noyafa-nf-8508-lan-probador-de-c.webp	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:03.839852
430	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:11.441234
433	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:11.527168
440	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:28.428215
442	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:31.922436
444	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:31.993099
448	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:34.053623
2440	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:18:41.471993
2441	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:18:41.524498
2447	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:19:11.346062
2451	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:19:21.922922
2454	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:19:24.155763
432	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:11.53086
439	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:28.352599
446	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:32.034424
449	192.168.0.94	admin	/api/productos/4/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:34.05408
452	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:49.338655
2442	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:18:41.529714
2452	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:19:24.093221
2453	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:19:24.155763
434	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:11.532479
435	192.168.0.94	admin	/api/productos/36	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:16.35636
436	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:16.429886
437	192.168.0.94	admin	/api/productos/35	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:21.186137
438	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:21.22495
443	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:31.990756
447	192.168.0.94	admin	/api/productos/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:33.949078
450	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:49.253289
451	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:49.333826
453	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:24:13.146635
2443	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-30 06:18:53.644209
2444	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:18:53.735047
441	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:22:28.429884
445	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:22:32.01925
454	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:36.305564
455	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:36.389145
456	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:36.394582
457	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:37.351093
458	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/4	2025-11-20 17:25:39.867024
459	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:39.931944
460	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:39.941347
461	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:41.135351
462	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/4	2025-11-20 17:25:50.864297
463	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:50.916384
464	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:25:50.91756
465	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:29:01.116618
466	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/4	2025-11-20 17:29:05.096455
467	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:29:05.14963
468	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:29:05.155119
469	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:30:10.611495
470	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/4	2025-11-20 17:30:14.984501
471	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:30:15.038364
472	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:30:15.050819
473	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:30:16.995879
474	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:30:17.082056
475	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:30:17.082029
476	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:30:17.101809
477	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:30:17.111458
478	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:42.195626
479	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:32:42.268302
480	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:32:42.265993
481	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:32:49.029632
482	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:49.11418
483	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:49.119078
484	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:49.122493
485	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:49.125259
486	192.168.0.94	admin	/api/productos/4	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:52.676621
487	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:52.712203
488	192.168.0.94	admin	/api/productos/5	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:54.451006
489	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:54.494919
490	192.168.0.94	admin	/api/productos/6	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:55.858444
491	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:55.886678
492	192.168.0.94	admin	/api/productos/7	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:57.190293
493	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:57.227904
494	192.168.0.94	admin	/api/productos/8	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:59.20348
810	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 01:39:13.392605
495	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:32:59.244214
497	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:00.928142
524	192.168.0.94	admin	/api/productos/23	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:28.373345
525	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:28.39942
527	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:29.834028
529	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:31.459426
2445	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:18:53.742045
2446	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:19:11.310536
2448	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:19:21.550404
2449	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:19:21.787897
2450	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:19:21.922915
496	192.168.0.94	admin	/api/productos/9	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:00.877326
499	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:02.213119
500	192.168.0.94	admin	/api/productos/11	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:03.962453
502	192.168.0.94	admin	/api/productos/12	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:05.49269
503	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:05.526579
504	192.168.0.94	admin	/api/productos/13	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:07.251845
505	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:07.284064
507	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:08.568173
508	192.168.0.94	admin	/api/productos/15	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:09.906675
509	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:09.93377
510	192.168.0.94	admin	/api/productos/16	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:12.044814
511	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:12.076468
513	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:14.792405
517	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:18.592859
519	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:21.716402
526	192.168.0.94	admin	/api/productos/24	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:29.810556
528	192.168.0.94	admin	/api/productos/25	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:31.42747
530	192.168.0.94	admin	/api/productos/26	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:33.128632
531	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:33.160729
2455	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:20:49.124634
2456	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:20:49.185001
2458	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-30 06:20:59.499903
2459	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:20:59.626007
2467	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:21:13.623362
2468	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:21:13.666871
498	192.168.0.94	admin	/api/productos/10	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:02.172766
501	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:03.99487
512	192.168.0.94	admin	/api/productos/17	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:14.755841
522	192.168.0.94	admin	/api/productos/22	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:26.313355
523	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:26.341434
2457	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:20:49.190955
2461	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:21:03.687263
2463	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:21:11.13379
2466	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:21:11.491416
506	192.168.0.94	admin	/api/productos/14	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:08.524013
514	192.168.0.94	admin	/api/productos/18	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:16.6031
515	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:16.634471
516	192.168.0.94	admin	/api/productos/19	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:18.562425
518	192.168.0.94	admin	/api/productos/20	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:21.69165
520	192.168.0.94	admin	/api/productos/21	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:24.650946
521	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:24.682919
532	192.168.0.94	admin	/api/productos/27	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:34.932354
533	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:34.964831
534	192.168.0.94	admin	/api/productos/28	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:36.417938
535	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:36.448717
536	192.168.0.94	admin	/api/productos/29	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:37.924543
537	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:37.958183
538	192.168.0.94	admin	/api/productos/30	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:40.059937
539	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:40.092161
540	192.168.0.94	admin	/api/productos/31	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:41.681717
541	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:41.714873
542	192.168.0.94	admin	/api/productos/32	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:42.84984
543	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:42.881398
544	192.168.0.94	admin	/api/productos/33	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:45.315884
545	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:45.34138
546	192.168.0.94	admin	/api/productos/34	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:48.064876
547	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:48.096611
548	192.168.0.94	admin	/api/productos/3	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:49.94678
549	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:33:50.006939
550	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:38:18.630334
551	192.168.0.139	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	http://192.168.0.192/admin	2025-11-20 17:39:28.909233
552	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:40:51.962667
553	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:44:09.243745
554	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:44:09.307765
555	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:44:09.309616
556	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:44:09.331512
557	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:44:09.334036
558	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:44:17.399808
559	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:44:17.454445
560	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:44:17.458824
561	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:45:07.9279
562	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:45:07.970401
563	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:45:07.973746
564	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:45:08.983669
565	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:45:09.043084
566	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:45:09.046647
567	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:45:09.047104
568	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:45:09.051236
569	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:47:15.969523
573	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:16.035917
574	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:47:55.566964
576	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:55.628197
583	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:48:12.915112
584	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:48:58.255195
585	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:49:17.934237
586	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:17.993531
591	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:43.72027
596	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:59:36.279871
600	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:01:16.49037
607	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:02:08.504072
614	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:49.280217
617	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:50.850315
621	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:12:10.829745
622	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:10.888761
630	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:21.009228
632	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:25.02421
2460	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:20:59.635402
570	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:16.025865
577	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:55.626281
579	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:48:12.81534
580	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:48:12.906589
588	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:18.005851
593	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:43.727842
597	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:59:45.98308
601	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:01:16.51415
603	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:02:08.378323
604	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:02:08.4855
608	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:02:39.150386
613	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:49.259894
615	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:49.283057
616	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:06:50.79113
620	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:50.86214
623	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:10.89091
625	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:10.91941
626	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:20.947629
628	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:21.005727
633	192.168.0.94	admin	/api/productos/1/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:25.027758
2462	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-30 06:21:03.726072
2464	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-30 06:21:11.362128
2465	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:21:11.491416
2469	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:21:13.666874
571	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:16.031157
578	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:55.629445
582	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:48:12.911144
587	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:17.999301
594	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:43.727879
598	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:01:16.398876
602	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:01:16.511858
606	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:02:08.500831
609	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:02:39.227093
619	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:50.859611
629	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:21.007222
2470	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-30 06:25:11.993983
2474	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 07:13:22.526136
2475	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 07:18:24.499367
2477	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 08:13:25.481031
2478	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 08:18:26.890851
2486	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 11:13:40.26633
2492	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 13:13:45.263476
2494	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 14:07:04.800942
2499	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 15:18:52.50988
2501	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 16:13:55.951857
2502	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 16:18:53.207245
2507	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 18:13:57.140914
2509	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 19:07:15.857752
2520	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 22:19:17.903117
2521	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 23:07:15.110255
2524	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 00:07:14.172656
2525	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 00:14:05.067072
2531	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 02:14:07.962209
2533	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 03:07:23.79106
2534	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 03:14:09.665464
2542	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 06:07:30.441942
2543	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 06:14:16.874714
2547	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 07:20:58.860103
2552	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 09:14:24.060862
2559	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 11:21:29.486087
2564	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 12:42:41.368001
2568	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 13:42:38.056738
2574	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:26:30.786317
2579	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:14:38.144102
2588	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:26:36.870969
2590	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:54:33.745767
572	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:16.039095
575	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:47:55.623878
581	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:48:12.911829
589	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:18.011247
590	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 17:49:43.663902
592	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 17:49:43.723383
595	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 17:55:40.565165
599	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:01:16.487194
605	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:02:08.488077
610	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:02:39.231303
611	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:06:49.175276
612	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:49.25021
618	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:06:50.858197
624	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:10.912736
627	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:21.003145
631	192.168.0.94	admin	/api/productos/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:12:24.915311
634	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:24:17.788123
635	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:50.984637
636	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:51.082474
637	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:51.092509
638	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:51.100776
639	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:51.116771
640	192.168.0.94	admin	/api/productos/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:54.117999
641	192.168.0.94	admin	/api/productos/1/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:54.233536
642	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:36:54.233216
643	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:37:00.022489
644	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:37:00.083405
645	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:37:00.085984
646	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:37:02.607878
647	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:38:49.471793
648	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:40:51.338934
649	192.168.0.94	admin	/producto/4	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:45:41.554559
650	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/4	2025-11-20 18:45:43.392748
651	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:45:43.456541
652	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:45:43.458391
653	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 18:45:46.174609
655	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:45:46.275391
654	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:45:46.275345
656	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:45:46.290766
657	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 18:45:46.290587
658	192.168.0.153	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:49:05.747637
659	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:56:00.81251
660	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:59:37.228017
661	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 18:59:47.910329
662	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:00.544339
663	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 19:16:00.650807
664	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 19:16:04.900566
665	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:05.001765
666	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:05.010929
678	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:26.683435
682	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:38.199309
683	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:38.258189
687	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:49.999881
688	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:54.823886
692	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:58.268757
2471	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:25:12.36184
2473	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 07:06:34.774562
2480	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 09:13:35.928928
2481	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 09:18:29.428965
2496	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 14:18:46.986391
2497	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 15:07:07.091108
2498	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 15:13:53.250613
2500	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 16:07:09.15033
2503	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 17:06:59.397295
2511	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 19:19:10.760196
2513	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 20:13:59.101629
2514	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 20:19:14.837769
2518	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 22:07:12.566161
2519	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 22:14:01.585396
2523	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 23:19:20.954069
2545	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 07:07:32.485792
2546	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 07:14:18.921127
2551	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 09:07:37.072659
2555	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 10:14:27.640924
2562	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 12:21:53.191308
2569	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 13:54:27.463515
2570	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:07:50.784955
2573	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:22:00.620083
2578	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:13:23.581926
2581	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:26:37.325743
2582	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:42:40.323653
2583	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:54:29.672099
2586	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:14:39.924744
667	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:05.020619
669	192.168.0.94	admin	/api/productos/upload-imagen	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:18.22434
672	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:18.366552
674	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:21.440163
681	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:26.7026
691	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/1	2025-11-20 19:16:58.217381
694	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:58.515332
699	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:17:04.687747
702	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:24:20.82933
2472	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-30 06:25:12.362321
2483	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 10:13:39.133186
2484	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 10:18:42.268794
2489	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 12:13:41.973338
2491	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 13:06:49.422768
2495	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 14:13:51.574011
2505	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 17:18:58.659321
2510	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 19:13:58.061319
2515	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 21:07:10.520591
2517	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 21:19:16.886229
2527	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 01:07:19.109818
2528	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 01:14:05.52473
2532	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 02:19:51.094661
2536	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 04:07:25.846553
2539	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 05:07:26.702907
2540	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 05:14:14.789811
2541	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 05:20:57.365846
2550	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 08:21:01.318782
2556	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 10:21:25.75542
2557	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 11:07:38.265175
2560	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 12:07:40.471999
2561	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 12:14:31.616753
2565	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 13:14:32.435324
2566	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 13:22:02.818147
2571	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:13:14.0989
2572	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:14:34.417631
2575	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:42:43.285755
2589	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:42:45.113827
668	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:05.023403
670	192.168.0.94	admin	/api/productos	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:18.260539
675	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:21.440674
676	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:21.685583
680	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:26.683997
684	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:38.258189
685	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:38.500379
686	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:41.288529
689	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:55.327733
696	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/29	2025-11-20 19:17:04.351321
698	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:17:04.419674
700	192.168.0.94	admin	/producto/162	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:17:19.256125
701	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/162	2025-11-20 19:17:19.336132
2476	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 08:06:35.565051
2479	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 09:06:44.465551
2482	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 10:06:37.251919
2485	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 11:06:45.418953
2487	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 11:18:42.970213
2488	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 12:06:50.595347
2490	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 12:18:42.026625
2493	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 13:18:46.371301
2504	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 17:13:56.81868
2506	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 18:07:13.724262
2508	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 18:19:02.356177
2512	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 20:07:18.255518
2516	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 21:14:01.586543
2522	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 23:14:04.520019
2526	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 00:19:23.918694
2529	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 01:19:47.605256
2530	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 02:07:21.716439
2535	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 03:19:53.500482
2537	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 04:14:13.574726
2538	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 04:19:56.184928
2544	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 06:20:57.974983
2548	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 08:07:33.611523
2549	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 08:14:20.889027
2553	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 09:21:08.210789
2554	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 10:07:36.878739
2558	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 11:14:30.401597
2563	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 12:26:33.659839
2567	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 13:26:41.033444
2576	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 14:54:23.166426
2577	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:07:52.924705
2580	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 15:22:11.459299
2584	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:07:59.694285
2585	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:13:28.192508
2587	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 16:22:17.896394
671	192.168.0.94	admin	/api/productos/162/proveedores	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:18.295622
673	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:21.36996
677	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:26.600405
679	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:16:26.681849
690	192.168.0.94	admin	/producto/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:56.633117
693	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:16:58.268537
695	192.168.0.94	admin	/producto/29	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:17:02.762749
697	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:17:04.418728
703	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:38:54.42989
704	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:40:51.111207
705	192.168.0.94	admin	/producto/162	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:17.309786
706	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/162	2025-11-20 19:41:17.416615
707	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/162	2025-11-20 19:41:21.346856
708	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:21.422255
709	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:21.432959
710	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:21.688951
711	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:28.46733
712	192.168.0.94	admin	/producto/162	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:29.983181
713	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/162	2025-11-20 19:41:30.051532
714	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/162	2025-11-20 19:41:31.820357
715	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:31.890968
716	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:31.893025
717	192.168.0.94	admin	/uploads/productos/20251120_191618_Captura_de_pantalla_2025-10-10_131734.png	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:32.221194
718	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 19:41:32.858059
719	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:32.931661
720	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:32.935268
721	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:32.954905
722	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:32.958712
723	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:38.092988
724	192.168.0.94	admin	/api/productos/162	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:41.255116
725	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:41.303475
726	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 19:41:43.505624
727	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 19:41:43.567155
728	192.168.0.94	admin	/api/proveedores/4	DELETE	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 19:41:46.858023
729	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 19:41:46.901776
730	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:56:06.931781
731	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:59:38.984483
732	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 19:59:50.254442
733	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:24:23.1643
734	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-20 20:27:49.623448
735	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:38:56.073336
736	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:40:54.874818
737	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:56:07.482859
738	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-20 20:58:29.951016
739	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 20:58:30.033651
740	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 20:58:30.03563
741	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:59:42.68724
742	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 20:59:51.36649
743	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:24:20.172021
744	192.168.0.94	admin	/producto/157	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:35:58.091007
745	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/producto/157	2025-11-20 21:35:59.896489
747	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:35:59.962947
748	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:36:01.013092
750	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:36:01.098713
2591	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:07:56.141182
2604	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:54:54.37196
2605	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:07:58.137473
2607	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:14:45.609396
2613	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:13:36.398806
2614	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:14:48.388305
2618	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:55:16.101993
2623	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:21:21.676174
2640	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:56:28.584445
2646	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 01:08:18.415259
2648	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 01:24:22.68338
2653	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 02:25:11.548777
2654	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 02:43:43.273045
2661	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 04:08:21.552006
2665	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 04:57:08.658469
2668	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 05:25:18.073716
2672	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 06:15:09.486775
2674	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 06:45:14.341853
2676	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 07:08:30.96765
2682	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 08:25:34.650718
2688	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 09:57:14.495783
2690	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 10:25:41.437793
2692	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 10:57:15.717767
2706	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 13:57:52.317417
2707	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:15:20.797849
2709	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:26:00.333123
2724	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-12-02 16:35:05.179525
2731	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:58:28.912886
2736	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:55:06.379169
2740	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:27:53.408533
2751	10.0.0.17	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 19:02:01.162662
2753	172.24.88.5	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 19:22:51.382627
2759	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:58:39.832662
2760	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:15:38.39912
2765	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:58:41.39926
2766	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:15:42.647413
2767	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:27:46.797534
2768	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:28:25.187981
2769	10.0.0.14	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 21:41:13.740915
2770	10.0.0.14	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 21:41:13.834115
2775	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 22:27:50.230834
2780	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:27:57.652766
2786	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 00:28:57.126569
2787	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 00:46:18.535381
2790	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 01:29:20.981077
2793	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 01:59:06.888769
2799	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 03:15:55.402382
2804	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 04:15:56.982684
2817	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 06:57:26.589268
2818	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 06:59:30.896222
2821	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 07:46:39.410465
2822	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 07:57:27.356964
2825	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 08:30:38.829922
2833	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 09:59:35.712828
2837	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 10:57:32.031117
2843	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 11:59:38.29613
2851	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:26:26.671347
2853	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:46:58.662941
2856	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:16:23.796835
2870	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:16:36.146171
2871	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:26:44.416882
2875	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:00:17.262221
2878	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:26:51.385084
2882	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:00:19.102119
2884	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:16:38.953278
2888	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:58:19.656647
2889	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:00:19.873355
2890	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:10:21.552451
2893	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:31:03.156279
746	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:35:59.960148
751	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:36:15.163391
2592	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:13:31.661722
2593	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:14:40.675297
2600	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:14:44.40913
2608	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:23:09.107626
2609	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:26:46.217696
2611	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:55:08.416371
2612	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:07:56.682067
2615	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:23:33.021311
2621	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:14:47.595086
2629	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:13:53.049792
2634	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:55:21.919214
2639	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:43:18.83082
2641	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 00:08:08.265494
2642	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 00:14:55.298099
2643	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 00:23:56.443235
2645	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 00:56:49.258193
2647	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 01:14:57.148546
2655	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 02:57:07.278229
2657	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 03:15:02.546633
2669	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 05:45:00.393625
2671	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 06:08:23.727874
2679	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 07:45:15.766755
2683	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 08:45:31.446049
2684	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 08:57:14.13818
2686	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 09:25:35.740712
2694	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 11:25:42.18325
2695	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 11:45:45.346011
2696	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 11:57:17.605997
2698	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 12:25:43.873695
2699	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 12:27:16.769583
2701	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 12:57:48.517492
2705	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 13:45:51.229981
2708	192.168.0.60	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:24:16.209243
2713	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 15:15:22.266576
2719	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 15:58:23.615351
2720	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:15:25.453142
2722	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-12-02 16:35:05.073904
2723	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-12-02 16:35:05.177592
2727	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-12-02 16:35:11.727234
2732	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:15:32.272483
2734	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:27:52.254711
2737	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:58:36.122735
2743	10.0.0.16	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:40:02.014169
2744	10.0.0.16	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:40:02.099865
2745	10.0.0.16	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:42:41.298724
2746	10.0.0.16	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:42:41.384471
2749	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:58:35.693588
2755	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:27:40.717921
2758	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:55:16.95698
2761	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:27:44.974721
2773	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:58:43.043986
2776	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 22:28:32.557085
2778	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 22:58:45.858619
2781	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:28:36.118848
2783	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:56:16.155636
2798	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 02:59:11.139028
2800	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 03:30:08.552234
2802	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 03:56:48.915227
2809	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 05:16:05.849492
2811	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 05:46:43.216331
2813	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 05:59:29.925542
2816	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 06:46:38.089954
2820	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 07:30:34.968661
2828	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 08:59:31.829928
2834	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 10:16:12.611291
2836	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 10:46:44.137484
2840	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 11:30:50.101378
2841	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 11:46:47.19521
2844	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 12:16:18.031192
2848	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 12:57:55.837855
2850	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:16:21.026203
2852	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:30:55.795968
2855	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:00:03.410118
2865	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:31:02.086054
2869	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:10:18.732016
2874	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:58:10.385681
2883	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:10:17.016817
2885	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:26:49.412266
2891	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:16:41.851908
2896	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:00:21.170554
2898	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:16:50.590382
749	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:36:01.099074
753	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:38:57.987208
754	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:39:33.148847
755	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:39:33.262374
756	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:39:33.267125
757	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:39:52.72219
758	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:39:52.761625
759	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:40:58.956255
760	192.168.0.94	admin	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:43:34.885414
761	192.168.0.94	admin	/admin/puerta	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin/puerta	2025-11-20 21:44:00.616704
762	192.168.0.94	admin	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:44:10.642414
763	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:44:17.275427
764	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:17.367866
765	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:17.370299
766	192.168.0.94	admin	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:18.959575
767	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:18.995349
768	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:19.016255
769	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 21:44:24.295881
770	192.168.0.94	root	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 21:44:24.521093
771	192.168.0.94	root	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:24.584369
772	192.168.0.94	root	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:44:24.586508
773	192.168.0.94	root	/admin/puerta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:44:30.234921
774	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:44:52.741554
775	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:44:52.768345
776	192.168.0.94	root	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:45:43.25792
777	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:45:43.284772
778	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:45:43.298867
779	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:51:39.011416
780	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-20 21:51:39.038603
781	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 21:51:44.742364
782	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-20 21:51:44.966173
783	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:45.037676
784	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:45.038509
785	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:48.465419
786	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:51:48.541615
787	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:51:48.550221
788	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-20 21:51:50.012701
789	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:50.073642
790	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:50.076272
791	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-20 21:51:55.108301
792	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:56:09.209693
793	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:59:43.2862
794	192.168.0.125	\N	/	GET	HomeNet/1.0	\N	2025-11-20 21:59:55.102679
795	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 22:24:43.645976
796	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 22:39:04.045006
797	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 22:40:58.952581
798	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 22:56:09.410925
799	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 22:59:52.051456
800	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-20 23:24:42.735181
801	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-20 23:39:07.910803
802	192.168.0.88	\N	/	GET	HomeNet/1.0	\N	2025-11-20 23:41:06.460322
803	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-20 23:56:08.704236
804	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-20 23:59:51.82501
805	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-21 00:24:42.329148
806	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 00:39:10.035704
807	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 00:56:19.624659
808	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 00:59:50.929582
811	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 01:56:20.779865
815	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 02:39:15.127156
819	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-21 03:51:24.907924
822	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-21 03:51:58.027975
825	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:51:58.35331
831	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:04.070655
832	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:07.779494
833	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-21 03:52:07.868013
835	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:13.944234
841	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 04:00:04.479854
857	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 09:56:42.351393
863	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 11:56:43.110664
867	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 12:56:59.61561
868	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 13:00:30.759109
880	192.168.0.139	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	http://192.168.0.192/admin	2025-11-21 15:04:57.937349
2594	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:22:21.361424
2596	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:42:59.039314
2598	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:07:57.126932
2599	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:13:30.454199
2601	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:22:45.248264
2606	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:13:34.064431
2617	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:43:15.946743
2622	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:16:44.955208
2626	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:43:17.53648
2628	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:08:07.902329
2630	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:14:52.656333
2632	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:26:57.782898
2633	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:43:19.257246
2635	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:08:06.693071
2636	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:13:49.34576
2638	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:23:53.393506
2644	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 00:43:19.722698
2651	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 02:08:18.884097
2656	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 03:08:20.148038
2658	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 03:25:15.015372
2660	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 03:57:05.292705
2662	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 04:15:04.508895
2664	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 04:44:13.525484
2666	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-02 05:08:22.556847
2673	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 06:25:19.69727
2675	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 06:57:10.969646
2681	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 08:15:12.36252
2687	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 09:45:33.391097
2689	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 10:15:14.165302
2703	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 13:25:59.546719
2704	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 13:27:28.089941
2710	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:27:29.729058
2712	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:58:23.066239
2714	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 15:27:35.99797
2716	192.168.0.84	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148	\N	2025-12-02 15:37:23.64771
2717	192.168.0.84	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148	\N	2025-12-02 15:37:23.9869
2718	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 15:45:57.657657
2721	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:27:37.839148
2733	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:27:37.787176
2735	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 17:45:56.27247
2739	192.168.0.103	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:27:42.432716
2741	10.0.0.16	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:38:45.04853
2742	10.0.0.16	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 18:38:45.181951
2750	10.0.0.17	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 19:02:01.073197
2757	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:46:07.723094
2763	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:46:09.680586
2771	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:46:10.235168
2774	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 22:15:43.531021
2777	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 22:55:17.450452
2785	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 00:15:47.972634
2788	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 00:59:06.575253
2794	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 02:15:54.070781
2795	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 02:29:44.695402
2796	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 02:46:34.993759
2801	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 03:46:35.992226
2803	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 03:59:24.440859
2805	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 04:30:12.656029
2807	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 04:57:15.347714
2808	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 04:59:25.642222
2810	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 05:30:14.454052
2814	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 06:16:07.778596
2827	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 08:57:28.110009
2830	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 09:30:41.410084
2838	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 10:59:33.775306
2839	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 11:16:13.900797
2845	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 12:26:22.780599
2847	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 12:46:48.191028
2854	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:58:03.419693
2858	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:30:56.975181
2859	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:46:53.49168
2860	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:58:09.968569
2862	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:10:17.495408
812	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 01:59:55.470997
813	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-21 02:14:28.230009
816	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 02:56:23.371739
842	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 04:48:33.284537
844	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 05:00:07.367437
846	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 05:56:39.762207
848	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 06:56:31.923055
856	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 09:00:12.82126
858	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 09:56:52.215455
864	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 11:56:57.785172
865	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 12:00:21.402954
869	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 13:49:21.20347
871	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 13:56:59.528692
875	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 14:56:52.546139
876	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 14:57:03.784808
877	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 15:00:35.114372
878	192.168.0.139	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	http://192.168.0.192/	2025-11-21 15:04:57.639811
879	192.168.0.139	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	http://192.168.0.192/admin	2025-11-21 15:04:57.937332
2595	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:26:45.241951
2597	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 17:54:36.522313
2602	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:26:40.022932
2603	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 18:43:02.513166
2610	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-01 19:43:14.548547
2616	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 20:26:52.801946
2619	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:08:05.551346
2620	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:13:43.666912
2624	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:23:52.76412
2625	192.168.0.240	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:26:55.322959
2627	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-01 21:55:19.430462
2631	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-01 22:23:52.818566
2637	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-01 23:14:52.958824
2649	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 01:43:20.302699
2650	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 01:56:51.482567
2652	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 02:15:00.621337
2659	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 03:44:12.820481
2663	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 04:25:17.367265
2667	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 05:15:06.451707
2670	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 05:57:08.984198
2677	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 07:15:11.416429
2678	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 07:25:33.896689
2680	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 07:57:13.097325
2685	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 09:15:13.431243
2691	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 10:45:37.666021
2693	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 11:15:17.418879
2697	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 12:15:18.364336
2700	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 12:45:50.185762
2702	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 13:15:22.187976
2711	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 14:45:52.738311
2715	192.168.0.84	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-12-02 15:35:01.647765
2725	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-12-02 16:35:11.687667
2726	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-12-02 16:35:11.727234
2728	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:45:59.229649
2729	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:54:46.351082
2730	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 16:55:04.350366
2738	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:15:36.413897
2747	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:46:07.821068
2748	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 18:55:10.682628
2752	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:15:37.694876
2754	172.24.88.5	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-12-02 19:22:51.431666
2756	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 19:28:12.951198
2762	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:28:23.369826
2764	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 20:55:15.002907
2772	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-02 21:55:13.372903
2779	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:15:48.651671
2782	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:46:35.527193
2784	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-02 23:58:49.858733
2789	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 01:15:52.735066
2791	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 01:46:32.049541
2792	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 01:56:17.809058
2797	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 02:56:22.242465
2806	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 04:46:43.281387
2812	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 05:57:25.506681
2815	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 06:30:30.984438
2819	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 07:16:10.551068
2823	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 07:59:31.722115
2824	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 08:16:10.08204
2826	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 08:46:47.873333
2829	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 09:16:11.188985
2831	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 09:46:43.980427
2832	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 09:57:31.294343
2835	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 10:30:49.609891
2842	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 11:57:33.9695
2846	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 12:30:54.726775
2849	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 13:00:00.158435
2857	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 14:26:38.898469
2861	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:00:12.050247
2866	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:46:56.443369
2867	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:58:10.873847
2868	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:00:16.196956
2879	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:31:02.491245
2880	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:47:04.719546
2886	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:31:06.300905
2895	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:58:23.02984
2900	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:31:13.401023
814	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-21 02:25:07.665412
817	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 03:00:00.197856
818	192.168.0.112	\N	/	GET	HomeNet/1.0	\N	2025-11-21 03:25:17.465144
821	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 03:51:47.559688
823	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-21 03:51:58.261961
824	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:51:58.35331
826	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:00.912991
827	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:00.982968
837	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:14.977204
838	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:15.049958
840	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 03:56:25.950707
847	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 06:00:10.689195
850	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 07:00:08.507934
852	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 07:56:42.398997
854	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 08:56:40.433375
860	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 10:56:42.304859
866	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 12:56:53.360318
870	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 13:56:51.423688
872	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 14:00:37.549985
874	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 14:49:30.076388
2863	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:16:33.872874
2864	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 15:26:39.31325
2872	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:31:01.76777
2873	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 16:47:04.470663
2876	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:10:21.686913
2877	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:16:37.630533
2881	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 17:58:14.163669
2887	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 18:47:10.080414
2892	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:26:52.313473
2894	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 19:47:00.909524
2897	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:10:22.475895
2899	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:27:02.808208
820	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 03:51:47.535514
828	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:00.984792
829	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:04.011594
830	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:04.068211
834	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/proveedores	2025-11-21 03:52:13.87785
836	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 03:52:13.94607
839	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 03:52:15.049937
843	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 04:56:28.529589
845	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 05:56:35.295941
849	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 06:56:42.743209
851	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 07:56:38.4455
853	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 08:00:09.7392
855	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 08:56:46.856501
859	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 10:00:18.66567
861	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 10:56:48.232546
862	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 11:00:19.871641
873	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 14:21:02.057548
881	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 15:20:58.797642
882	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 15:32:28.982732
883	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 15:32:29.094581
884	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 15:32:29.094581
885	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 15:39:32.442936
886	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 15:39:32.504132
887	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 15:39:32.504131
888	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 15:49:32.475744
889	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 15:56:56.570102
890	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 15:57:02.41502
891	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 16:00:39.841554
892	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 16:20:58.59078
893	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 16:55:15.786524
894	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 16:55:15.873008
895	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 16:55:15.873008
896	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 16:56:54.174901
897	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 16:57:04.638994
898	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 16:58:08.916428
899	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 16:58:08.93846
900	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 17:00:49.891588
901	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 17:06:55.393369
902	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 17:13:39.843593
903	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 17:13:39.908715
904	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 17:13:39.908659
905	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 17:21:05.435739
906	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 17:56:55.688337
907	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 17:57:04.392289
908	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:00:55.015767
909	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-21 18:05:13.02361
910	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 18:05:13.103701
911	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 18:05:13.105906
912	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:10:55.799664
913	192.168.0.114	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:13:03.098254
914	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:21:00.877457
915	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:57:00.36627
916	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 18:57:17.926214
917	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 19:01:03.399034
918	192.168.0.73	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-21 19:01:56.195849
919	192.168.0.73	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-21 19:01:56.221908
920	192.168.0.90	\N	/	GET	HomeNet/1.0	\N	2025-11-21 19:11:01.966108
921	192.168.0.114	\N	/	GET	HomeNet/1.0	\N	2025-11-21 19:13:05.334434
922	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 19:21:07.816873
923	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-21 20:03:04.823676
924	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 20:03:05.026931
925	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 20:03:05.046856
926	192.168.0.94	admin	/logout	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 20:03:07.614734
927	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 20:03:07.648116
930	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 21:29:58.65489
928	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-21 20:03:07.670708
929	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 20:56:35.20229
936	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 22:41:18.156299
942	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 23:56:41.388057
945	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 00:57:00.17253
948	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 01:57:02.29347
952	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 03:57:19.304572
953	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 03:59:40.716723
960	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 07:57:40.834079
967	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 11:28:51.576065
971	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 13:58:17.833759
975	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 15:58:24.478625
976	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 16:00:13.917656
981	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 18:59:08.272344
1010	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 10:00:27.505719
1011	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 10:01:04.623167
1017	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 14:00:48.703608
1019	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 15:00:55.965567
1021	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 16:01:03.320539
1024	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 17:46:57.323319
1027	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 19:01:15.314599
1031	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 21:58:07.169736
1033	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 23:01:29.152238
1039	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 02:20:06.494665
1042	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 05:01:42.701619
1044	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 06:01:42.575076
1049	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 09:01:59.481933
1053	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 11:07:28.16625
1061	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:35:36.493835
2901	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:47:07.56883
2902	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 20:58:27.159113
2908	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:47:14.460169
2913	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:27:15.197876
2917	192.168.0.228	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-12-03 22:56:53.010779
2929	192.168.0.228	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:04.255579
2936	192.168.0.228	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-12-03 22:57:12.780626
2946	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 00:31:31.002716
2948	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 01:16:59.315166
2950	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 01:48:04.409376
2953	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 02:31:41.266074
2954	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 02:48:13.730205
2958	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 03:48:16.446845
2961	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 04:31:52.933818
2967	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 06:00:45.797348
2968	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 06:17:18.258525
2981	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 09:31:59.914781
2989	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 11:32:29.134495
2990	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 11:48:32.753821
2994	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 12:32:32.386041
2996	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:00:58.068778
3000	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:36:57.58362
3001	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:48:31.573888
3008	192.168.0.238	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-12-04 15:17:56.387662
3009	192.168.0.238	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-12-04 15:17:56.430899
3012	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 15:32:50.1289
3022	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:18:23.530679
3024	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:32:52.81025
3026	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:48:41.550824
3036	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:32:54.636055
3038	192.168.0.238	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-12-04 19:43:56.011135
3047	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:48:45.14365
3055	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:18:35.173273
3057	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:33:10.326622
3059	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:48:47.623163
3060	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 23:01:20.93611
3061	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 23:18:50.933792
3063	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 23:37:38.670399
3068	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 00:49:03.223427
3070	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 01:19:37.688769
3074	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 02:19:54.852612
3078	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 03:19:58.096656
3079	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 03:34:05.582921
3083	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 04:34:09.181882
3084	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 04:49:10.931073
3087	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 05:34:15.015503
3088	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 05:49:21.103267
3089	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 06:02:07.729782
3096	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 07:49:18.842427
3097	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 08:02:10.449302
3102	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 09:20:07.983503
3108	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 10:50:08.00825
3126	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:25:08.719999
3133	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:34:45.05306
3138	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 16:34:50.618257
3140	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 16:50:24.932549
3146	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 18:23:34.018096
3155	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:50:28.764816
3156	192.168.0.196	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:56:35.07587
3158	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 20:25:30.5648
3162	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 21:35:09.25222
3171	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 23:40:19.880883
3172	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 23:40:49.44413
3176	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 01:40:50.353138
3181	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 04:35:45.885713
3185	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 06:35:57.079482
931	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 21:41:13.995256
933	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 21:56:37.954622
937	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-21 22:56:39.250018
946	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 00:59:23.046582
947	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-22 01:41:47.237488
949	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 01:59:23.272058
951	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 02:59:35.478307
954	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 04:57:21.553073
956	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 05:57:25.498113
964	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 09:57:44.794308
972	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 14:00:09.466869
979	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 17:58:36.120742
982	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 19:00:31.427211
991	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 23:59:48.726971
992	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 00:00:36.746427
993	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 00:59:57.832503
1001	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 05:00:13.757513
1002	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 05:32:21.564431
1008	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 09:00:25.795499
1009	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 09:01:02.584036
1013	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 11:01:08.69264
1025	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 18:01:07.38578
1030	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 21:01:23.793082
1032	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 22:01:27.78585
1034	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 23:35:42.742878
1035	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 00:01:33.324075
1036	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 00:35:46.244775
1037	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 01:01:35.753174
1045	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 06:31:33.724257
1048	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 08:28:49.543428
1051	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 10:02:00.877295
1052	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 11:02:08.984835
1055	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 12:07:33.377394
1056	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 12:21:19.625984
1057	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 12:35:21.937728
2903	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:00:24.537898
2909	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:58:26.742547
2910	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:00:29.394124
2912	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:16:53.529586
2919	192.168.0.228	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-12-03 22:56:55.890452
2920	192.168.0.228	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:56:55.949692
2933	192.168.0.228	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:10.79851
2938	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:00:31.089972
2941	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:27:22.080656
2944	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 00:00:32.711548
2945	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 00:16:57.281002
2947	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 01:00:34.022459
2965	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 05:31:54.686059
2969	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 06:31:55.507439
2973	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 07:31:58.206172
2975	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 08:00:49.687644
2988	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 11:17:31.3729
2991	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 12:00:55.566427
2993	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 12:26:29.541346
2997	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:17:36.444937
2998	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:26:27.15371
3003	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:17:39.581548
3006	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:37:02.679535
3007	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:48:34.828853
3015	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:01:05.167759
3016	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:18:21.548924
3027	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:01:08.857545
3034	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:18:28.038303
3037	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:37:31.350607
3039	192.168.0.238	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-12-04 19:43:56.028241
3043	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:18:29.973748
3046	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:37:31.410388
3048	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:01:18.29319
3050	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:27:01.577211
3053	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:48:49.058337
3058	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:37:36.434908
3066	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 00:19:12.232229
3072	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 01:49:04.062658
3077	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 03:02:04.021393
3086	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 05:19:59.85009
3091	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 06:34:16.338556
3093	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 07:02:10.9784
3100	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 08:49:22.879005
3101	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 09:02:17.899466
3107	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 10:34:28.982449
3111	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 11:34:28.384521
3115	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 12:25:04.705843
3117	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 12:50:12.15149
3122	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:38:21.550736
3137	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 16:25:15.01876
3141	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 17:23:24.803695
3143	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 17:34:48.732714
3144	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 17:39:25.685208
3147	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 18:25:21.404364
3150	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 18:50:25.230781
3152	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:25:25.228416
3154	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:40:13.26946
3159	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 20:35:06.547547
3161	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 21:25:31.482975
3166	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 22:25:39.020403
3169	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 22:40:46.610364
3173	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 00:35:21.162936
3178	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 02:40:54.324776
3179	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 03:35:43.851956
932	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 21:47:53.316456
935	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 22:30:08.41702
941	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-21 23:41:17.506358
944	192.168.0.139	\N	/	GET	HomeNet/1.0	\N	2025-11-22 00:41:30.066025
950	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 02:57:03.693254
957	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 05:59:50.437596
958	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 06:57:31.181168
966	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 10:57:52.94138
968	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 11:57:59.047551
969	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 12:58:06.767501
970	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 13:00:09.211022
973	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 14:58:21.13472
980	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 18:00:25.720341
983	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 19:59:21.462092
988	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 22:00:33.927018
990	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 23:00:38.057888
996	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 02:00:46.008763
997	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 03:00:09.731932
1000	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 04:00:50.411402
1003	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 06:00:17.54095
1006	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 07:32:29.990231
1007	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 08:00:20.621794
1023	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 17:01:05.704406
1026	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 18:47:00.48399
1029	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 20:21:42.951161
1038	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 02:01:36.564165
1040	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 03:01:37.797716
1046	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 07:01:47.362363
1050	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 09:28:51.796065
1054	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 11:13:54.48287
1058	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 12:40:46.550909
1059	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 12:41:02.179633
2904	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:10:26.128156
2906	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:27:05.073788
2907	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:31:27.432571
2914	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:31:29.260798
2915	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:47:17.238972
2916	192.168.0.228	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-12-03 22:56:52.946782
2918	192.168.0.228	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-12-03 22:56:55.644423
2922	192.168.0.228	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:56:57.895244
2925	192.168.0.228	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-12-03 22:56:59.456649
2927	192.168.0.228	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-12-03 22:57:03.859383
2928	192.168.0.228	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-12-03 22:57:04.182044
2930	192.168.0.228	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:04.255579
2931	192.168.0.228	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:10.761273
2932	192.168.0.228	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:10.797462
2934	192.168.0.228	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:57:12.71
2935	192.168.0.228	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-12-03 22:57:12.780626
2937	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:58:32.15739
2940	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:16:55.386191
2942	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:31:28.939
2943	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:47:22.389345
2955	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 03:00:42.368877
2959	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 04:00:43.302574
2962	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 04:48:19.186222
2963	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 05:00:41.953171
2964	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 05:17:18.626818
2966	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 05:48:21.616235
2970	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 06:48:19.743468
2972	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 07:17:22.01625
2974	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 07:48:18.482374
2976	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 08:17:20.802895
2978	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 08:48:27.940094
2982	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 09:48:26.801596
2984	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 10:17:29.279054
2987	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 11:00:54.221147
2992	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 12:17:32.607131
2995	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 12:48:32.548212
3004	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:26:35.096206
3010	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 15:18:19.541899
3011	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 15:26:39.532087
3014	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 15:48:41.853597
3017	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:26:46.693934
3018	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:32:51.988819
3020	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:48:42.805422
3023	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:26:48.388304
3029	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:26:49.916781
3030	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:32:55.798473
3041	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:48:48.83269
3042	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:01:18.32955
3044	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:26:49.737357
3049	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:18:31.849572
3052	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:37:33.351457
934	192.168.0.234	\N	/	GET	HomeNet/1.0	\N	2025-11-21 22:13:18.893664
938	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 22:57:11.854694
939	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-11-21 23:28:16.545775
940	192.168.0.187	\N	/	GET	HomeNet/1.0	\N	2025-11-21 23:30:08.919681
943	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-21 23:57:14.836238
955	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 04:59:45.524638
959	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 07:27:59.094643
961	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 08:28:20.068905
962	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 08:57:43.298922
963	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 09:28:44.563337
965	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 10:28:50.390972
974	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 15:00:12.31277
977	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 16:58:25.61886
978	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 17:00:22.891693
984	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 20:00:32.660215
985	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 20:59:22.280721
986	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-22 21:00:32.226842
987	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 21:59:37.988782
989	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-22 22:59:45.359614
994	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 01:00:42.1645
995	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 01:59:59.425677
998	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 03:00:49.506996
999	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 04:00:12.552661
1004	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 06:32:27.433614
1005	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 07:00:18.509562
1012	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 11:00:29.248936
1014	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 12:00:32.882196
1015	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 12:32:51.167957
1016	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 13:00:47.896067
1018	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 14:32:55.304384
1020	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 15:46:41.177218
1022	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-23 16:46:58.549968
1028	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-23 20:01:20.698602
1041	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 04:01:39.596486
1043	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-11-24 05:07:56.424994
1047	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 08:01:52.788381
1060	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:07:33.321815
1062	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:40:58.858355
1063	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:41:45.813844
1064	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:55:47.863
1065	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 13:55:59.66726
1066	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 14:07:44.747071
1067	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 14:35:45.647949
1068	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 14:41:01.992056
1069	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 14:42:11.154657
1070	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 14:55:59.21546
1071	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:07:35.259154
1072	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:07:47.279417
1073	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:35:48.790343
1074	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:41:01.571141
1075	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:42:04.419096
1076	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 15:55:58.915394
1077	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:07:40.550948
1078	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:07:53.991191
1079	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:35:51.109816
1080	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:41:12.345535
1081	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:42:09.790139
1082	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 16:55:57.529828
1083	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:07:41.110036
1084	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:07:56.254757
1085	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:35:53.305703
1086	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:41:13.740177
1087	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:42:12.227339
1088	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 17:55:59.97409
1089	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 18:07:42.919606
1090	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 18:07:57.524699
1091	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 18:35:47.502974
1092	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 18:42:16.384185
1093	192.168.0.123	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-24 18:50:24.992089
1094	192.168.0.123	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-24 18:50:25.01448
1095	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 18:56:07.089234
1096	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:07:53.898843
1097	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:07:59.06607
1098	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:35:46.331869
1099	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:41:17.02169
1100	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:42:21.220659
1101	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 19:56:07.665417
1102	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:07:57.579901
1103	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:07:59.831498
1104	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:35:54.712085
1105	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:41:18.06574
1106	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:42:18.011037
1107	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 20:56:09.175079
1108	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:08:00.927408
1109	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:08:01.538079
1110	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:35:52.478934
1111	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:41:25.22142
1112	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:42:26.646422
1113	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 21:56:13.233154
1114	10.0.0.16	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-24 22:03:27.1085
1115	10.0.0.16	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36	\N	2025-11-24 22:03:27.239261
1116	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 22:08:02.884691
1117	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 22:08:04.589374
1118	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 22:36:01.109978
1119	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 22:42:28.286286
1120	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-11-24 22:56:13.230547
1121	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-24 23:08:04.08249
1122	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-24 23:08:07.542016
1123	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-24 23:35:56.354909
1124	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-24 23:42:22.806015
1125	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 00:08:08.711668
1126	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 00:08:10.786605
1127	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 00:36:03.40435
1128	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 01:08:10.04173
1144	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 06:08:30.987648
1145	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 06:36:25.219925
1150	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 08:08:36.102147
1160	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 11:37:06.44534
1161	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 12:08:42.534363
1162	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 12:08:42.962363
1164	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 12:37:07.701278
1167	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:22:48.593289
1172	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 14:08:51.755986
1173	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 14:22:49.053837
1179	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:37:12.55405
1180	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:43:28.713705
1181	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:46:01.791017
1184	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:23:11.354343
1185	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:37:12.982858
1188	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:09:00.212289
1193	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:46:07.671748
1199	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:46:07.296953
1200	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:09:03.281162
1201	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:09:03.936548
1207	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 20:09:07.199332
1210	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 20:46:14.033208
1218	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:09:07.873562
2905	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-03 21:16:50.141311
2911	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 22:10:29.245986
2921	192.168.0.228	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-12-03 22:56:55.950358
2923	192.168.0.228	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-12-03 22:56:57.957696
2924	192.168.0.228	admin	/logout	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-12-03 22:56:59.39645
2926	192.168.0.228	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-12-03 22:56:59.490778
2939	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-03 23:10:31.626846
2949	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 01:31:35.170453
2951	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 02:00:37.432128
2952	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 02:17:02.331962
2956	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 03:17:10.502222
2957	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 03:31:49.709743
2960	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 04:17:11.445365
2971	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 07:00:47.761349
2977	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 08:31:59.081263
2979	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 09:00:50.790982
2980	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 09:17:21.952517
2983	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 10:00:52.287585
2985	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 10:32:25.195141
2986	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 10:48:29.439605
2999	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 13:32:35.799266
3002	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:01:01.286909
3005	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 14:32:39.829358
3013	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 15:37:11.149241
3019	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 16:37:15.805209
3021	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:01:04.558516
3025	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 17:37:21.063471
3028	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:18:25.38762
3031	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:37:29.943114
3032	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 18:48:42.72881
3033	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:01:13.370551
3035	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 19:26:47.911223
3040	192.168.0.238	\N	/login	GET	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0	\N	2025-12-04 19:43:56.031511
3045	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 20:32:58.290072
3051	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 21:32:59.903546
3056	192.168.0.97	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:27:06.575169
3062	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-04 23:33:10.826928
3071	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 01:33:17.202723
3080	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 03:49:11.937283
3082	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 04:19:58.94567
3090	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 06:20:01.674533
3092	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 06:49:21.706133
3094	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 07:20:02.365669
3095	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 07:34:19.553015
3106	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 10:20:10.681636
3112	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 11:50:09.161965
3116	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 12:34:30.36369
3118	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:02:35.080028
3120	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:25:09.097545
3121	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:34:43.957549
3123	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:50:18.557778
3124	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:02:35.526681
3129	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:50:19.440209
3130	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:02:42.001826
3131	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:23:03.448877
3135	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:50:18.561625
3145	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 17:50:24.075387
3148	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 18:34:58.747947
3149	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 18:39:17.136133
3164	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 21:40:47.37242
3168	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 22:40:16.231358
3170	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 23:35:19.258415
3175	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 01:35:28.67629
3182	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 04:41:00.432274
3186	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 06:41:05.925049
3188	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 07:41:03.248269
3191	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 09:36:18.723489
3193	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 10:36:24.682093
3196	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 11:41:16.407402
3197	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 12:36:38.758263
3201	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 14:36:53.503265
1129	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 01:08:12.435235
1133	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 02:36:05.185527
1135	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 03:08:24.222595
1136	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 03:36:06.435894
1137	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 04:08:25.173761
1142	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 05:36:20.043727
1143	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 06:08:28.557875
1146	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 07:08:33.650989
1147	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 07:08:33.978164
1151	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 08:36:40.272222
1152	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 09:08:37.375583
1153	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 09:08:37.874201
1158	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 11:08:39.237784
1166	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:08:50.334725
1169	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:43:32.296959
1174	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 14:37:09.119063
1175	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 14:45:59.045825
1182	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:08:57.115354
1190	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:23:11.382519
1191	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:37:14.282048
1192	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:43:32.102527
1198	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:43:34.570225
1202	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:23:17.447944
1208	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 20:23:19.284903
1211	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:09:05.845706
1212	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:09:05.993914
1213	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:23:20.128185
3054	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-04 22:01:16.192625
3064	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-04 23:48:59.001752
3065	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 00:01:23.517354
3067	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 00:33:10.690634
3069	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 01:01:30.67623
3073	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 02:01:40.495205
3075	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 02:33:43.67716
3076	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 02:49:07.507496
3081	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 04:02:03.991975
3085	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 05:02:06.549287
3098	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 08:20:03.909004
3099	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 08:34:20.412143
3103	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 09:34:27.298776
3104	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 09:49:30.850076
3105	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 10:02:18.520086
3109	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 11:02:20.443954
3110	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 11:20:16.019596
3113	192.168.0.227	\N	/	GET	HomeNet/1.0	\N	2025-12-05 12:02:21.371169
3114	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 12:21:26.914553
3119	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 13:21:53.685922
3125	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:21:56.327594
3127	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:34:45.614477
3128	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 14:38:20.869425
3132	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:25:12.792274
3134	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 15:38:29.345553
3136	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 16:23:17.518232
3139	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 16:38:29.17209
3142	192.168.0.215	\N	/	GET	HomeNet/1.0	\N	2025-12-05 17:25:19.561243
3151	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:23:45.482679
3153	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 19:35:04.348105
3157	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-05 20:24:16.772334
3160	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 20:40:13.426437
3163	192.168.0.167	\N	/	GET	HomeNet/1.0	\N	2025-12-05 21:40:17.916388
3165	192.168.0.122	\N	/	GET	HomeNet/1.0	\N	2025-12-05 21:50:34.686787
3167	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-05 22:35:07.151382
3174	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 00:40:49.406206
3177	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 02:35:42.339768
3183	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 05:35:47.123567
3189	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 08:36:09.206706
3194	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 10:41:11.157106
3198	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 12:41:20.161966
3200	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 13:41:21.858234
3204	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 15:41:29.276374
3205	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 16:36:55.632451
3208	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 17:41:32.358611
3211	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 19:37:41.950852
3214	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 20:41:48.809934
3216	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 21:41:57.617378
3218	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 22:41:59.690475
3222	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 00:42:02.925471
3225	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 02:38:43.787258
3230	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 04:42:02.653521
1130	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 01:36:05.935459
1132	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 02:08:20.721087
1134	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 03:08:22.796438
1154	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 09:36:46.899246
1155	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 10:08:37.620529
1156	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 10:08:39.426446
1165	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:08:49.907068
1168	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:37:08.098937
1171	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 14:08:51.347422
1177	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:08:53.173369
1183	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:08:59.607287
1189	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 17:09:01.745491
1195	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:09:02.822198
1196	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:23:15.423862
1203	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:37:19.739264
1205	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:46:12.226392
1209	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 20:37:21.568786
1215	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:37:19.149384
1217	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:09:06.996218
3180	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 03:41:00.434065
3184	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 05:41:02.444617
3190	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 08:41:07.613922
3192	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 09:41:14.100837
3195	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 11:36:26.768492
3202	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 14:41:27.962963
3203	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 15:36:54.145544
3206	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 16:41:30.928399
3220	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 23:42:01.76308
3228	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 03:42:01.629784
3231	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 05:38:51.33121
3233	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 06:38:56.825449
3234	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 06:42:04.765254
3235	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 07:38:59.046975
3237	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 08:39:08.055677
1131	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 02:08:19.239181
1138	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 04:08:25.658609
1139	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 04:36:15.754684
1140	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 05:08:26.563766
1141	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 05:08:27.903879
1148	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 07:36:31.905611
1149	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 08:08:35.696465
1157	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 10:36:55.41353
1159	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 11:08:40.180508
1163	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 12:22:43.649835
1170	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 13:45:56.732595
1176	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:08:51.147016
1178	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 15:23:08.751685
1186	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:43:28.595187
1187	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 16:46:05.8098
1194	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:09:00.737952
1197	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 18:37:19.012805
1204	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 19:43:42.578155
1206	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 20:09:01.856095
1214	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:31:30.258647
1216	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 21:46:17.002027
1219	192.168.0.207	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:23:20.93162
1220	192.168.0.179	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:31:28.53977
1221	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:37:21.308825
1222	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 22:46:13.283062
1223	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-25 23:09:09.48502
1224	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-25 23:09:11.1484
1225	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-25 23:37:34.934797
1226	192.168.0.131	\N	/	GET	HomeNet/1.0	\N	2025-11-25 23:46:21.73758
1227	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 00:09:11.249004
1228	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 00:09:14.869172
1229	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 00:37:32.715256
1230	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 01:09:13.090856
1231	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 01:09:16.723099
1232	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 01:37:37.529088
1233	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 02:09:15.889473
1234	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 02:09:17.414056
1235	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 02:37:40.728311
1236	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 03:09:17.278168
1237	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 03:09:19.246045
1238	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 03:37:45.430689
1239	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 04:09:18.30939
1240	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 04:09:20.487296
1241	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 04:37:48.020014
1242	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 05:09:20.609396
1243	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 05:09:21.17016
1244	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 05:37:43.863283
1245	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 06:09:21.836112
1246	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 06:09:22.245783
1247	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 06:37:46.037241
1248	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 07:09:23.094545
1249	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 07:09:23.529619
1250	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 07:37:51.181353
1251	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 08:09:22.573
1252	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 08:09:24.29521
1253	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 08:37:57.752261
1254	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 09:09:32.383214
1255	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 09:09:32.9417
1256	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 09:38:16.9107
1257	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 10:09:33.011845
1258	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 10:09:34.993726
1259	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 10:38:29.296154
1260	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 11:09:36.043412
1261	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 11:09:38.489513
1262	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 11:38:41.99041
1263	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 12:09:39.119912
1264	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 12:09:39.454302
1265	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 12:18:53.629051
1266	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 12:38:44.649824
1267	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 13:09:46.978596
1268	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 13:09:50.363035
1269	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 13:19:12.727648
1270	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 13:38:47.18461
1271	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 13:49:10.242096
1272	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:09:49.20397
1273	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:09:50.185669
1274	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:19:14.546252
1275	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:38:50.010786
1276	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:43:05.981401
1277	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 14:49:12.357069
1278	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 15:09:51.202517
1279	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 15:09:51.73887
1280	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 15:19:18.346256
1281	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 15:38:53.93395
1282	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 15:49:18.503095
1283	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:09:52.927581
1284	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:09:53.314896
1285	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:19:21.318512
1286	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:31:10.163319
1287	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:38:53.78543
1288	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 16:49:15.750154
1289	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 17:09:55.216196
1290	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 17:09:56.582272
1291	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 17:19:23.515266
1292	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 17:31:19.980317
1293	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 17:49:19.277635
1294	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:09:59.042485
1295	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:09:59.465616
1296	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:19:25.825818
1297	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:31:20.442617
1298	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:39:04.873082
1299	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 18:49:18.971686
1300	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:10:00.621236
1301	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:10:01.603218
1302	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:19:26.389618
1303	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:31:27.374696
1304	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:39:14.110981
1305	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 19:49:24.024254
1307	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:10:03.450936
1318	192.168.0.94	\N	/	GET	Mozilla/5.0	\N	2025-11-26 21:53:24.866202
1321	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 22:10:07.995433
1324	192.168.0.237	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-26 22:17:12.080543
1325	192.168.0.237	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-26 22:17:25.948551
1333	192.168.0.237	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-26 22:18:21.999441
1334	192.168.0.237	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-26 22:18:22.08252
1338	192.168.0.237	\N	/apple-touch-icon-120x120-precomposed.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:36.666673
1339	192.168.0.237	\N	/apple-touch-icon-120x120.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:36.886986
1345	192.168.0.237	admin	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-26 22:18:52.452923
1351	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 22:19:40.867739
1357	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 23:49:30.42236
1359	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 00:10:18.92933
1361	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 01:10:20.510958
1362	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 01:17:18.194673
1363	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 01:17:18.239298
1364	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-27 01:17:26.23963
1365	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-27 01:17:26.495185
3187	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 07:36:06.88241
3199	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 13:36:50.587897
3209	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 18:37:17.238491
3212	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 19:41:41.245329
3215	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 21:38:28.899059
3217	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 22:38:29.680422
3219	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 23:38:31.138823
3223	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 01:38:40.613819
3224	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 01:41:59.633713
3227	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 03:38:45.073233
3240	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 09:42:10.395479
1306	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:10:02.995353
1309	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:31:28.82199
1312	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:10:04.53116
1313	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:10:05.278501
1314	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:19:32.94615
1316	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:39:21.759772
1327	192.168.0.237	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-26 22:17:39.274025
1329	192.168.0.237	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-26 22:17:39.401902
1335	192.168.0.237	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-26 22:18:22.08396
1336	192.168.0.237	admin	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-26 22:18:26.551274
1340	192.168.0.237	\N	/apple-touch-icon.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:36.904185
1343	192.168.0.237	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-26 22:18:48.500893
1347	192.168.0.237	\N	/apple-touch-icon-120x120-precomposed.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:57.649253
1348	192.168.0.237	\N	/apple-touch-icon-120x120.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:57.767516
1350	192.168.0.237	\N	/apple-touch-icon.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:57.816375
1354	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-26 23:10:10.450716
1355	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 23:10:12.492867
1360	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 01:10:19.480271
1370	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-27 01:26:40.219514
3207	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 17:37:00.494328
3210	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-06 18:41:39.336859
3213	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-06 20:38:05.579895
3221	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 00:38:35.120587
3226	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 02:42:02.839952
3229	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 04:38:49.368921
3232	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 05:42:03.76337
3236	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 07:42:05.690834
3238	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 08:42:07.163041
3239	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 09:39:10.587278
3241	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 10:39:10.335745
1308	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:19:28.214163
1315	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:31:31.672651
1323	192.168.0.237	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-26 22:17:12.042085
1326	192.168.0.237	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-26 22:17:38.778152
1328	192.168.0.237	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-26 22:17:39.401902
1331	192.168.0.237	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-26 22:17:54.41414
1341	192.168.0.237	\N	/apple-touch-icon.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:36.91883
1342	192.168.0.237	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-26 22:18:48.425652
1349	192.168.0.237	\N	/apple-touch-icon.png	GET	SafariViewService/8621.2.5.10.10 CFNetwork/3826.500.131 Darwin/24.5.0	\N	2025-11-26 22:18:57.784787
1352	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 22:31:29.475974
1353	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 22:49:29.1537
1367	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 01:17:26.61263
1369	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/	2025-11-27 01:26:40.216183
3242	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 10:42:08.073557
3243	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 11:39:11.545127
3245	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 12:39:10.732107
3251	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 15:39:22.851496
3253	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 16:39:27.043598
3254	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 16:42:31.223158
3264	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 21:42:36.114945
3270	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 00:42:41.585444
3272	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 01:42:42.897305
3274	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 02:42:44.20305
3278	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 04:42:46.689483
3279	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 05:40:03.154729
3280	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 05:42:50.091727
3281	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 06:40:04.986433
3286	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 08:42:51.252259
3290	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 10:42:53.246229
3299	192.168.0.99	\N	/	GET	HomeNet/1.0	\N	2025-12-08 13:36:09.790789
3301	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 13:43:01.036298
3302	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:02:12.537127
3309	192.168.0.130	\N	/	GET	HomeNet/1.0	\N	2025-12-08 15:22:51.277802
3312	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 15:43:04.915428
3317	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 17:02:28.14462
3318	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 17:33:07.029314
3338	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 20:43:17.471307
3339	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:02:11.652204
3341	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:33:12.563575
3342	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:41:00.209237
3343	192.168.0.149	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:42:46.939243
3344	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:43:18.535529
3351	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 23:41:47.146747
3353	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 00:42:10.825581
3357	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 02:42:57.5779
3361	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 04:43:06.887946
3365	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 06:43:15.041745
3369	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 08:43:19.073823
3377	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 12:30:33.9382
3385	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 14:43:37.739506
3386	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 14:43:48.390225
3392	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:44:02.359479
3393	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:48:49.133589
3398	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:44:03.522978
3400	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:02:40.195544
3406	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:43:55.292598
3408	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:02:43.391969
3409	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:05:47.857679
3416	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:30:49.163433
3422	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:30:48.925258
3426	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:02:48.31055
3429	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:44:02.748176
3433	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 22:05:58.064432
3440	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 00:44:06.790543
3447	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 07:44:44.081228
3449	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 09:44:53.192183
3456	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 13:34:02.053475
3458	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 13:50:34.075896
3461	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 14:50:36.256887
3466	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 15:50:35.856792
3473	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 17:21:40.465301
3474	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 17:27:46.507163
3475	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 17:35:00.17199
3477	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 17:54:35.503088
3482	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 18:54:34.530053
3484	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:27:52.614741
3486	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-12-10 19:50:11.338444
3487	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:50:13.638029
3493	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-10 20:50:48.059864
3495	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 21:21:52.751001
3498	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-10 21:51:11.423842
3504	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 22:54:46.998376
3513	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 00:37:28.494131
3518	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 01:37:28.146805
3521	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 02:22:16.309236
3523	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 02:39:15.388732
3528	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 03:53:33.122827
3530	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 04:37:44.279704
3540	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 06:54:43.466075
3543	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 07:55:06.890082
3545	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 08:27:11.268447
1310	192.168.0.190	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:39:20.489707
1311	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 20:49:26.611313
1317	192.168.0.213	\N	/	GET	HomeNet/1.0	\N	2025-11-26 21:49:29.686778
1319	192.168.0.94	\N	/login	GET	Mozilla/5.0	\N	2025-11-26 21:53:24.88598
1320	192.168.0.94	\N	/nice ports,/Trinity.txt.bak	GET	\N	\N	2025-11-26 21:53:25.205739
1322	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-26 22:10:09.996384
1330	192.168.0.237	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-26 22:17:54.35015
1332	192.168.0.237	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-26 22:17:54.41462
1337	192.168.0.237	admin	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-26 22:18:26.555868
1344	192.168.0.237	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-26 22:18:48.500893
1346	192.168.0.237	admin	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-26 22:18:52.45356
1356	192.168.0.55	\N	/	GET	HomeNet/1.0	\N	2025-11-26 23:31:34.180385
1358	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 00:10:17.511596
1366	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 01:17:26.609199
1368	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 01:26:40.09135
1371	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-27 01:29:15.730584
1372	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 01:29:15.918453
1373	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 01:29:15.921942
1374	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-27 01:40:22.414105
1375	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 01:40:22.529952
1376	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 01:40:22.538686
1377	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-27 02:08:22.15095
1378	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 02:08:22.23263
1379	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 02:08:22.242593
1380	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:08:42.556948
1381	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:08:42.588647
1382	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:09:00.766542
1383	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:09:00.99269
1385	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:09:01.140789
1384	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Mobile Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:09:01.140788
1386	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 02:10:25.594466
1387	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 02:10:27.01239
1388	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:13:33.781457
1389	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:13:33.841234
1390	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:13:33.846605
1391	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:14:06.307733
1392	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:17:45.425024
1393	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:17:45.518846
1394	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:17:45.525337
1395	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:17:54.348694
1396	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:17:54.421809
1728	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 19:52:16.985059
1397	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:17:54.421811
1398	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:22:25.36073
1400	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:22:25.442089
3244	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 11:42:11.593899
3247	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 13:39:14.422663
3249	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 14:39:17.612598
3250	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 14:42:18.943485
3255	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 17:39:28.396223
3256	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 17:42:29.262585
3257	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 18:39:34.386583
3260	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 19:42:31.241298
3266	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 22:42:38.817888
3268	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 23:42:40.148936
3282	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 06:42:51.068131
3285	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 08:40:17.398503
3289	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 10:40:27.492815
3292	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 11:42:54.337778
3298	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 13:32:53.13903
3300	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 13:40:44.490955
3303	192.168.0.130	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:22:47.720266
3307	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:43:01.803126
3310	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 15:32:59.308806
3311	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 15:40:50.589184
3314	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 16:33:00.881821
3316	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 16:43:05.405795
3319	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 17:40:52.951869
3320	192.168.0.149	\N	/	GET	HomeNet/1.0	\N	2025-12-08 17:42:26.671095
3321	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 17:43:06.226006
3328	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:02:10.49201
3332	192.168.0.149	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:42:39.974456
3334	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 20:02:11.398555
3336	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 20:40:59.41377
3345	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 22:02:24.132543
3348	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 22:43:22.393555
3349	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 23:02:41.894288
3352	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 23:43:17.169225
3356	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 01:43:25.649426
3362	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 04:43:38.205603
3366	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 06:43:34.438189
3371	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 09:43:21.159376
3372	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 09:43:37.735005
3380	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 13:30:34.519747
3384	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 14:30:33.357213
3396	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:30:38.299136
3397	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:43:51.733271
3401	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:05:47.876697
3402	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-12-09 17:15:08.531602
3403	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-12-09 17:15:08.555896
3411	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:43:56.827492
3412	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:43:57.489515
3417	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:43:57.089904
3418	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:43:58.579407
3420	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:02:47.151778
3423	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:44:00.153963
3427	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:06:02.069017
3428	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:30:50.978655
3434	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 22:44:03.582679
3436	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 23:02:51.35142
3439	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 23:44:15.544419
3441	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 01:44:07.205514
3442	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 02:44:11.123684
3443	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 03:44:14.465355
3444	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 04:44:33.184576
3454	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 12:45:24.699043
3457	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 13:45:48.00256
3459	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 14:27:22.334801
3462	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 14:54:31.12864
3463	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 15:21:35.969861
3465	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 15:34:07.952169
3468	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 16:21:36.542156
3469	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 16:27:36.413104
3471	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 16:50:34.364647
3476	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 17:50:38.591177
3479	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 18:27:51.476401
3483	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:21:45.785599
3485	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:35:34.938709
3488	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:50:46.787836
3499	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 21:54:47.052511
3506	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:33:23.382721
3520	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 01:52:46.196705
3522	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 02:37:31.172393
3524	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 02:53:09.718493
3525	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 03:22:27.189999
3534	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 05:37:49.37157
3538	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 06:22:32.279531
3541	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 07:16:23.957759
3544	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 08:16:36.512227
3546	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 08:37:57.517929
3548	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 08:55:30.432829
3549	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 09:16:39.818101
3552	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 10:21:52.730646
3554	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 10:56:17.477607
3563	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:38:08.165382
3564	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:42:43.303252
3568	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:30:43.959061
3570	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:42:44.724852
3572	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:54:51.383632
3575	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 15:42:42.490381
1399	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:22:25.439171
1401	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:23:22.502392
1402	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:22.580589
1403	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:22.585601
1404	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:23:25.325727
1405	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:25.386864
1406	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:25.386131
1407	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:23:33.484381
1408	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:23:33.524583
1409	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:23:38.465505
1410	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:23:38.699776
1411	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:38.804601
1412	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:38.80529
1413	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:23:53.322495
1414	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:23:53.386506
1415	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:23:53.389141
1416	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:23:58.702592
1417	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:23:58.7498
1418	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:23:58.750183
1419	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:01.270619
1420	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:01.313326
1421	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:01.314342
1422	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:03.151509
1423	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:03.191043
1424	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:03.193126
1425	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/	2025-11-27 02:24:09.545353
1426	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/proveedores	2025-11-27 02:24:09.63841
1427	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 02:27:37.361998
1428	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 02:27:37.392543
1429	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-27 02:27:46.03081
1430	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-27 02:27:46.255635
1431	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 02:27:46.325303
1432	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 02:27:46.325303
1433	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:29:36.324146
1434	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 02:29:36.352652
1435	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:29:42.793886
1439	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:29:49.435979
1453	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 05:10:30.641545
1454	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 05:10:30.760426
1463	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 10:10:39.823997
1474	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 12:43:18.387657
1485	192.168.0.84	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:44:23.040078
1488	192.168.0.84	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:44:36.753787
1489	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 12:44:43.433763
1490	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 13:10:46.756684
1494	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 14:02:13.762008
1501	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:10:53.652321
1502	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:22:44.779044
1504	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:45:02.48853
3246	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 12:42:12.98028
3248	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 13:42:14.069946
3259	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 19:39:38.74581
3263	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 21:39:44.330406
3267	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 23:39:50.358784
3269	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 00:39:51.696559
3273	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 02:40:00.502802
3276	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 03:42:45.517914
3277	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 04:40:03.751869
3284	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 07:42:50.10157
3287	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 09:40:26.771438
3293	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 12:33:04.120222
3295	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 12:40:41.809586
3297	192.168.0.130	\N	/	GET	HomeNet/1.0	\N	2025-12-08 13:22:44.883419
3304	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:32:57.450762
3306	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:40:51.11878
3315	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 16:40:53.76128
3322	192.168.0.128	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:02:15.180568
3323	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:02:30.232737
3324	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:33:04.076659
3325	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:40:53.153476
3327	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:43:10.641027
3329	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:02:30.139924
3330	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:33:04.908088
3337	192.168.0.149	\N	/	GET	HomeNet/1.0	\N	2025-12-08 20:42:42.047625
3340	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 21:03:18.226995
3346	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 22:03:11.489745
3350	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 23:03:16.864919
3355	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 01:42:34.240802
3358	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 02:43:28.099177
3360	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 03:43:31.619169
3367	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 07:43:16.724293
3370	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 08:43:39.982367
3374	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 10:43:38.701744
3376	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 11:43:39.679285
3378	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 12:43:34.947255
3379	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 12:43:53.861899
3381	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 13:43:34.019705
3387	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 14:48:49.238259
3394	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:02:42.142941
3399	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:48:54.647577
3404	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:30:40.857123
3405	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:43:52.234487
3410	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:30:44.820274
3414	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:02:44.089896
3419	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:48:56.358326
3425	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:49:03.207408
3435	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 22:44:11.10531
3446	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 06:44:43.523338
3450	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 10:45:01.262236
3451	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 11:45:19.832373
3464	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 15:27:31.495724
3478	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 18:21:41.464271
3481	192.168.0.74	\N	/	GET	HomeNet/1.0	\N	2025-12-10 18:50:40.882656
3489	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 19:54:40.951739
3494	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 20:54:48.64142
3497	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 21:35:39.852674
3500	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 22:21:58.537394
3501	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 22:37:46.87469
3502	192.168.0.144	\N	/	GET	HomeNet/1.0	\N	2025-12-10 22:45:18.52705
3505	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:21:59.660769
3508	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:37:47.230472
3511	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:54:55.141108
3512	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 00:22:01.252977
3514	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 00:37:50.162545
3515	192.168.0.144	\N	/	GET	HomeNet/1.0	\N	2025-12-11 00:45:27.219216
3519	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 01:37:50.366442
3527	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 03:39:21.416767
3535	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 05:40:11.825209
3536	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 05:54:19.9979
3539	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 06:37:54.235613
3550	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 09:38:02.246731
3551	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 09:55:53.96288
3558	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 12:30:45.024474
3561	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 12:57:04.481703
3562	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:30:42.786208
3569	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:38:13.36474
3574	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 15:30:51.503081
3576	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 15:45:39.541885
3578	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 15:58:09.96757
3581	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:42:47.030996
3584	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:58:38.164888
1436	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:29:49.128375
1437	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:29:49.33881
1438	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:29:49.434683
1445	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:31:44.027948
1446	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:31:44.255043
1448	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:31:44.299952
1449	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 03:10:27.173241
1450	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 03:10:28.552941
1451	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 04:10:29.465904
1452	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 04:10:29.894956
1455	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 06:10:30.685642
1456	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 06:10:32.440276
1459	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 08:10:33.813977
1461	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 09:10:37.264993
1462	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 09:10:37.295324
1468	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 12:10:43.971442
1472	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:43:10.293582
1476	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 12:43:28.483935
1477	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 12:43:28.536237
1483	192.168.0.84	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 12:44:22.871617
1484	192.168.0.84	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:44:23.032047
1492	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 13:31:10.568669
1495	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 14:10:47.613498
1505	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:02:21.486019
1507	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:10:55.660177
1508	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:22:47.195276
1510	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:45:08.60535
3252	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 15:42:21.948086
3258	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 18:42:30.909067
3261	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 20:39:42.952066
3262	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-07 20:42:32.993049
3265	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-07 22:39:46.499323
3271	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 01:39:59.229329
3275	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 03:40:02.44476
3283	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 07:40:15.176332
3288	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 09:42:52.318958
3291	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 11:40:31.762791
3294	192.168.0.99	\N	/	GET	HomeNet/1.0	\N	2025-12-08 12:36:05.682214
3296	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 12:43:00.409151
3305	192.168.0.99	\N	/	GET	HomeNet/1.0	\N	2025-12-08 14:36:25.957314
3308	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 15:02:20.557839
3313	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-08 16:02:29.05357
3326	192.168.0.149	\N	/	GET	HomeNet/1.0	\N	2025-12-08 18:42:41.142993
3331	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:40:57.585331
3333	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-08 19:43:14.167672
3335	192.168.0.203	\N	/	GET	HomeNet/1.0	\N	2025-12-08 20:33:09.259876
3347	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-08 22:41:19.42047
3354	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 00:43:36.78968
3359	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 03:42:58.896244
3363	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 05:43:08.749949
3364	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 05:43:39.085322
3368	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 07:43:36.786222
3373	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 10:43:24.134022
3375	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 11:43:29.265101
3382	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 13:43:42.101309
3383	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 14:05:46.762824
3388	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:02:35.736112
3389	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:05:42.396412
3390	192.168.0.72	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:30:35.15599
3391	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 15:43:51.553635
3395	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 16:05:46.389212
3407	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 17:48:53.88668
3413	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 18:49:00.082956
3415	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 19:05:53.072937
3421	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:05:54.640781
3424	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 20:44:07.79039
3430	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:44:12.688303
3431	192.168.0.163	\N	/	GET	HomeNet/1.0	\N	2025-12-09 21:49:00.128986
3432	192.168.0.205	\N	/	GET	HomeNet/1.0	\N	2025-12-09 22:02:46.794876
3437	192.168.0.123	\N	/	GET	HomeNet/1.0	\N	2025-12-09 23:06:02.42277
3438	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-09 23:44:07.29059
3445	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 05:44:36.007403
3448	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 08:44:46.303392
3452	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 12:27:15.573001
3453	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 12:33:58.511422
3455	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 13:27:20.469232
3460	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 14:34:06.200862
3467	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 15:54:29.990871
3470	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 16:34:50.093806
3472	192.168.0.225	\N	/	GET	HomeNet/1.0	\N	2025-12-10 16:54:32.661386
3480	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 18:35:11.803437
3490	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-10 20:21:49.120531
1440	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:30:07.031962
1442	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:30:07.106741
1443	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:31:38.462038
1444	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 02:31:38.487774
1457	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 07:10:32.715018
1460	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 08:10:37.900424
1464	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 10:10:40.540682
1465	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 11:10:41.796429
1466	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 11:10:41.973189
1470	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 12:43:10.221547
1471	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:43:10.290859
1475	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 12:43:18.388009
1478	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 12:43:28.536238
1479	192.168.0.84	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 12:44:01.08142
1481	192.168.0.84	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 12:44:10.263257
1487	192.168.0.84	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 12:44:36.75146
1493	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 13:45:01.460953
1499	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:02:18.343396
1500	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:10:49.492647
1503	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 15:31:43.041769
3491	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 20:27:52.380058
3492	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-10 20:35:37.826801
3496	192.168.0.91	\N	/	GET	HomeNet/1.0	\N	2025-12-10 21:27:57.55907
3503	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-10 22:51:16.96077
3507	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:37:28.153506
3509	192.168.0.144	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:45:19.956585
3510	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-10 23:51:18.005014
3516	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 00:51:29.478206
3517	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 01:22:03.459714
3526	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 03:37:36.109648
3529	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 04:22:29.796828
3531	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 04:40:05.866711
3532	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 04:53:56.574032
3533	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-11 05:22:30.24591
3537	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 06:14:36.809082
3542	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 07:37:54.598173
3547	192.168.0.172	\N	/	GET	HomeNet/1.0	\N	2025-12-11 08:46:53.885936
3553	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 10:38:04.274206
3555	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 11:26:01.195776
3556	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 11:38:05.121034
3557	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 11:56:20.793247
3559	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 12:38:09.005101
3560	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 12:42:30.425495
3566	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:54:55.937113
3567	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:57:27.886492
3571	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:45:38.476362
3582	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:45:43.457456
3590	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:59:39.463887
3594	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 18:45:45.737744
3598	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 19:42:50.963409
3601	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 20:31:10.431128
3602	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 20:38:27.222904
3608	192.168.0.53	\N	/	GET	HomeNet/1.0	\N	2025-12-11 21:51:04.308709
3613	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 23:55:31.79888
3615	192.168.0.96	\N	/	GET	HomeNet/1.0	\N	2025-12-12 13:31:00.929727
1441	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:30:07.105069
1447	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 02:31:44.299998
1458	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 07:10:34.256724
1467	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 12:10:43.82109
1469	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 12:31:06.630402
1473	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 12:43:18.310103
1480	192.168.0.84	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 12:44:01.139126
1482	192.168.0.84	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 12:44:22.631314
1486	192.168.0.84	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 12:44:36.710165
1491	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 13:10:47.464928
1496	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 14:10:51.995425
1497	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 14:31:40.857493
1498	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 14:45:01.431779
1506	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:10:50.303683
1509	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 16:32:12.896497
1511	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:02:20.694574
1512	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:05:18.079978
1513	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:05:18.188041
1514	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:05:18.199147
1515	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:05:21.286097
1516	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:05:21.370505
1517	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:05:21.375024
1518	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-27 17:05:27.496564
1520	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 17:05:27.608819
1519	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 17:05:27.608877
1521	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 17:05:40.870766
1523	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 17:05:41.124057
1522	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-27 17:05:41.124057
1524	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/login	2025-11-27 17:06:32.147923
1525	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 17:06:32.209289
1526	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/admin	2025-11-27 17:06:32.209121
1527	192.168.0.102	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:07:39.080003
1528	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:07:39.186277
1529	192.168.0.102	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:07:44.390857
1530	192.168.0.102	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:07:44.785171
1531	192.168.0.102	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:07:44.918895
1532	192.168.0.102	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:07:44.920707
1533	192.168.0.102	\N	/admin	GET	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0	\N	2025-11-27 17:07:56.159016
1534	192.168.0.102	\N	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:07:56.158767
1535	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 17:07:56.165259
1536	192.168.0.102	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 17:07:56.171017
1537	192.168.0.102	\N	/login	GET	Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0	\N	2025-11-27 17:07:56.186997
1538	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:07:56.187307
1544	192.168.0.102	\N	/apple-touch-icon-120x120.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.556197
1545	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.577356
1547	192.168.0.102	\N	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:07:59.982709
1549	192.168.0.102	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:08:02.70333
1556	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:08:47.931036
1559	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:10:52.522707
1562	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:32:18.49029
3565	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 13:45:42.453973
3573	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-11 14:57:51.350618
3580	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:38:15.797344
3595	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 18:55:07.896339
3596	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 19:31:07.380609
3600	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 19:55:07.895666
3612	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 22:55:21.077666
3614	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 12:53:05.847378
1539	192.168.0.102	\N	/apple-touch-icon-120x120-precomposed.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.246551
1551	192.168.0.102	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:08:03.243676
1553	192.168.0.102	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:08:06.68979
1557	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 17:09:17.117787
1561	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:22:48.999889
3577	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 15:54:56.756129
3579	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:30:49.976848
3583	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 16:54:59.418084
3587	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:42:50.190335
3588	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:45:42.539942
3589	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:55:00.262294
3597	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 19:38:22.342007
3599	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-12-11 19:45:45.887277
3605	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 21:31:17.448473
3606	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 21:38:35.470961
3607	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 21:42:58.833462
3609	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 21:55:19.643768
3610	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 22:38:37.677799
3611	192.168.0.53	\N	/	GET	HomeNet/1.0	\N	2025-12-11 22:51:09.771941
1540	192.168.0.102	\N	/apple-touch-icon-120x120.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.320475
1542	192.168.0.102	\N	/apple-touch-icon.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.413798
1543	192.168.0.102	\N	/apple-touch-icon-120x120-precomposed.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.50331
1554	192.168.0.102	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:08:06.751404
1555	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:08:47.825029
3585	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:30:58.767459
3586	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 17:38:18.313625
3591	192.168.0.162	\N	/	GET	HomeNet/1.0	\N	2025-12-11 18:31:00.478951
3592	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-11 18:38:19.25896
3593	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 18:42:53.419944
3603	192.168.0.209	\N	/	GET	HomeNet/1.0	\N	2025-12-11 20:42:57.245003
3604	192.168.0.133	\N	/	GET	HomeNet/1.0	\N	2025-12-11 20:55:17.645598
3616	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 13:38:43.21847
1541	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.394264
1546	192.168.0.102	\N	/apple-touch-icon.png	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Safari	\N	2025-11-27 17:07:56.667343
1548	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:08:00.020805
1550	192.168.0.102	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:08:02.990487
1552	192.168.0.102	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:08:03.243657
1558	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 17:09:17.163633
1560	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:10:55.861675
1563	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:40:10.691296
1564	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:10.861403
1565	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:10.8721
1566	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:14.305258
1567	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:14.395285
1568	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:16.827655
1569	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:16.955271
1570	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:16.958115
1571	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:18.477968
1573	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:40:18.606608
1572	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:40:18.606608
1574	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:40:28.915078
1575	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:29.056039
1576	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:29.056717
1577	192.168.0.94	admin	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:29.869681
1578	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:29.969238
1579	192.168.0.94	admin	/logout	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:30.702925
1580	192.168.0.94	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:30.723137
1581	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/proveedores	2025-11-27 17:40:30.749926
1582	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:40:38.356773
1583	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:40:38.601834
1584	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:38.722599
1585	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:38.724894
1586	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:40:41.039863
1587	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:40:41.180317
1588	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:40:41.191222
1589	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 17:45:09.767036
1590	192.168.0.102	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:45:48.279388
1891	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 00:11:52.958395
1591	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 17:45:48.342196
1595	192.168.0.102	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:51.032802
1601	192.168.0.102	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:45:55.649552
1602	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:52:08.371472
1603	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:52:08.501276
1605	192.168.0.94	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:52:10.593257
1606	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:52:10.713826
1608	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:52:32.042502
1610	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:52:32.182921
1614	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 18:10:45.661999
3617	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 13:44:13.965625
3619	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 14:03:02.962318
3624	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 15:03:10.138209
3625	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 15:38:47.653656
3638	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 18:44:30.701371
3639	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 18:53:29.386062
3643	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 19:53:30.011645
3644	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 20:03:20.079104
3646	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 20:44:30.540161
3647	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-12 20:44:47.179575
3649	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 21:03:21.677578
3651	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 21:44:31.098008
3658	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-12 23:45:00.130921
3660	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 12:27:44.728445
3662	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 12:29:20.890202
3663	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:27:40.870285
3665	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:29:00.594434
3671	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 14:28:59.694877
3673	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 14:34:54.262863
3674	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 14:58:56.310335
3682	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:29:06.234298
3686	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 17:27:44.412192
3688	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 17:29:23.767219
3690	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 17:59:04.722078
3710	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:59:12.785839
3717	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:02:58.831134
3722	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:41:44.751679
3726	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 23:28:10.830746
3734	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 01:29:08.823014
3735	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 01:29:30.242002
3750	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 05:29:26.213414
3759	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 07:29:46.119228
3761	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 08:07:44.90371
3765	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 09:08:08.279218
3769	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 10:08:31.664287
3786	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:30:04.558603
3787	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:50:56.910026
3799	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:29:46.976034
3800	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:30:09.475593
3804	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:28:06.956856
3811	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 16:55:56.818391
1592	192.168.0.102	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:45:50.664659
1593	192.168.0.102	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-27 17:45:50.936046
1594	192.168.0.102	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:51.032806
1600	192.168.0.102	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:45:55.649559
1604	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:52:08.496929
1607	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 17:52:10.71744
1609	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:52:32.182532
1611	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 18:02:24.103337
1613	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 18:10:45.6643
1616	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 18:10:59.040201
3618	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 13:53:08.158583
3621	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 14:38:46.890097
3622	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 14:44:17.975659
3627	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 15:53:19.076789
3628	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 16:03:07.824821
3629	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 16:38:48.469673
3632	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 17:03:12.17844
3633	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 17:38:50.278617
3652	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-12 21:44:47.361583
3669	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:58:50.596805
3679	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 15:59:02.854329
3681	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:27:43.927062
3689	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 17:35:03.094121
3692	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 18:29:12.38282
3694	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 18:35:06.280369
3696	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:02:44.588398
3697	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:02:44.833117
3699	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:27:53.017557
3701	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:29:27.540467
3703	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:59:11.760698
3705	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:03:28.504916
3708	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:29:31.675001
3713	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:28:00.060499
3716	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:59:13.072401
3719	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:28:06.074157
3724	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-15 23:03:04.547728
3728	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 23:41:37.627026
3731	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 00:29:30.027654
3736	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 02:03:23.967754
3737	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 02:05:24.689656
3738	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 02:29:12.671939
3743	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 03:29:33.983118
3748	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 05:03:48.676961
3749	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 05:06:34.770309
3752	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 06:03:50.030512
3754	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 06:29:24.997273
3762	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 08:29:20.167739
3764	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 09:03:57.515071
3770	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 10:29:26.129534
3773	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 11:08:55.109716
3774	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 11:29:28.639197
3775	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 11:29:55.902921
3777	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 12:09:18.571653
3778	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 12:28:38.286125
3783	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:27:52.357935
3785	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:29:43.273156
3792	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:29:36.560176
3794	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:51:00.649952
3797	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:28:04.654414
3801	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:51:03.001482
3802	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:04:23.005472
3803	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:10:22.426007
3805	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:29:03.134355
3807	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:30:09.777755
3810	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 16:55:49.433371
1596	192.168.0.102	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:53.181036
1597	192.168.0.102	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:53.220906
1598	192.168.0.102	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:53.220869
1599	192.168.0.102	admin	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 17:45:55.518556
1612	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 18:10:45.547392
1615	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 18:10:53.270141
1617	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/	2025-11-27 18:16:59.847452
1618	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 18:16:59.991507
1619	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-27 18:17:00.003829
1620	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-27 18:17:19.574705
1621	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 18:17:29.874545
1622	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 18:22:52.834346
1623	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 18:32:19.608952
1624	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:37:42.304347
1625	192.168.0.192	\N	/public/productos	GET	curl/8.14.1	\N	2025-11-27 18:38:44.876204
1626	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 18:45:32.945888
1627	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-27 18:45:34.599836
1628	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-27 18:45:38.026382
1629	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:45:43.887125
1630	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:45:46.359906
1631	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:47:23.975289
1632	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:47:24.719031
1633	192.168.0.192	\N	/catalogo_consulta	GET	curl/8.14.1	\N	2025-11-27 18:47:34.557047
1634	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:48:50.813224
1635	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:48:50.864233
1636	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:48:50.867711
1637	192.168.0.192	\N	/catalogo_consulta	GET	curl/8.14.1	\N	2025-11-27 18:48:57.962121
1638	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:49:07.806781
1639	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:07.841928
1640	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:07.842273
1641	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:49:08.648735
1642	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:08.679411
1643	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:08.679422
1644	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:49:09.127218
1645	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:09.153881
1646	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:09.154549
1647	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:49:09.720012
1649	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:09.740983
1648	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:49:09.740983
1650	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:50:51.18912
1651	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:50:51.216712
1652	192.168.0.192	\N	/catalogo_consulta	GET	curl/8.14.1	\N	2025-11-27 18:51:27.534752
1653	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:51:29.530185
1654	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:51:29.571509
1655	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:51:29.577058
1656	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 18:51:30.742111
1658	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:51:30.776852
1657	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 18:51:30.776628
1659	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 19:02:24.73413
1660	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 19:10:55.165385
1661	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 19:11:04.163029
1662	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 19:22:52.994131
1663	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 19:32:05.090769
1664	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:05.12655
1665	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:05.127159
1666	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:32:26.770883
1667	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:26.81687
1668	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:26.821743
1669	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:32:32.908717
1670	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:32.958812
1671	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:32.959568
1672	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:32:37.871488
1673	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:37.918692
1674	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:32:37.920102
1675	192.168.0.102	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:33:33.336595
1676	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:33:33.394839
1677	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:34:03.601366
1678	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:03.693639
1679	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:03.693836
1680	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:34:49.891182
1681	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:49.938702
1682	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:49.944197
1683	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:34:51.445045
1684	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:51.496211
1685	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:51.496643
1686	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:34:56.463964
1892	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 00:33:06.995292
2193	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:05:14.185599
1687	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:56.522233
3620	192.168.0.96	\N	/	GET	HomeNet/1.0	\N	2025-12-12 14:30:58.120244
3626	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 15:44:23.077811
3631	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 16:53:19.942887
3634	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 17:44:24.02476
3636	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 18:03:17.182391
3640	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 19:03:17.316011
3642	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 19:44:30.507493
3645	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 20:39:14.648871
3656	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 22:53:40.495891
3659	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-12-13 00:44:58.88509
3666	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:29:19.562782
3668	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:46:24.804356
3670	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 14:27:41.28769
3672	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 14:29:18.536379
3678	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 15:34:57.806671
3680	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:18:50.917189
3683	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:29:21.618025
3684	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:35:00.135369
3687	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 17:29:04.181226
3698	192.168.0.232	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:02:47.641546
3704	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:02:56.417618
3707	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:29:17.866992
3709	192.168.0.232	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:44:56.9737
3711	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:03:00.138804
3718	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:03:51.276224
3723	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:59:12.194727
3727	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 23:29:24.175528
3730	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 00:28:37.407509
3732	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 01:03:11.184326
3733	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 01:05:01.382672
3739	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 02:29:32.866743
3741	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 03:05:48.095989
3745	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 04:06:11.400414
3747	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 04:29:38.813764
3755	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 06:29:44.306393
3757	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 07:07:21.45885
3758	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 07:29:27.91588
3763	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 08:29:50.555496
3767	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 09:29:53.153567
3768	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 10:04:05.887106
3772	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 11:04:07.850724
3776	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 12:04:09.802161
3779	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 12:29:32.678349
3781	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:04:10.106337
3782	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:09:42.112738
3784	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 13:28:51.860594
3788	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:04:13.938555
3789	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:09:45.227976
3791	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:28:52.361256
3793	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:30:06.328443
3795	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:04:14.374258
3806	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:29:47.890673
3808	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 16:51:04.896043
3809	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 16:55:21.166369
1688	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:56.526413
1689	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:34:57.755639
1692	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:35:07.837385
1694	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:35:07.981414
3623	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 14:53:15.42845
3630	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 16:44:25.018215
3635	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 17:53:26.642547
3637	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 18:39:19.51767
3641	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 19:39:13.217565
3648	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 20:53:34.912697
3650	192.168.0.161	\N	/	GET	HomeNet/1.0	\N	2025-12-12 21:39:11.687599
3653	192.168.0.95	\N	/	GET	HomeNet/1.0	\N	2025-12-12 21:53:36.235562
3654	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 22:03:22.88945
3655	192.168.0.75	\N	/	GET	HomeNet/1.0	\N	2025-12-12 22:44:37.085986
3657	192.168.0.238	\N	/	GET	HomeNet/1.0	\N	2025-12-12 23:03:24.363072
3661	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 12:28:58.612431
3664	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:28:52.656741
3667	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 13:34:56.941083
3675	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 15:27:43.240623
3676	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 15:29:01.305937
3677	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 15:29:19.935674
3685	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 16:59:03.089779
3691	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 18:27:50.012788
3693	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 18:29:24.278459
3695	192.168.0.132	\N	/	GET	HomeNet/1.0	\N	2025-12-15 18:59:05.092978
3700	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:29:17.048372
3702	192.168.0.176	\N	/	GET	HomeNet/1.0	\N	2025-12-15 19:35:04.58492
3706	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-15 20:27:55.27556
3712	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:03:30.376241
3714	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:29:20.50155
3715	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 21:29:27.784762
3720	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:29:23.133506
3721	192.168.0.204	\N	/	GET	HomeNet/1.0	\N	2025-12-15 22:29:34.642851
3725	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-15 23:04:07.940213
3729	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 00:04:38.098588
3740	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 03:03:47.366037
3742	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 03:29:19.7981
3744	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 04:03:47.026427
3746	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 04:29:21.321282
3751	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 05:29:42.115914
3753	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 06:06:58.055763
3756	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 07:03:50.856318
3760	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 08:03:54.52538
3766	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 09:29:24.815441
3771	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 10:29:54.133377
3780	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 12:29:58.452612
3790	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 14:27:58.763848
3796	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:09:48.008531
3798	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 15:29:00.498837
1690	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:57.834133
1691	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:34:57.848206
1693	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:35:07.980938
1695	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:38:07.796545
1696	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:07.867839
1697	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:07.882109
1698	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 19:38:15.171153
1699	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:15.240535
1700	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:15.240983
1701	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:38:31.079741
1702	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:31.129784
1703	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:31.13859
1704	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:38:32.648429
1705	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:32.699764
1706	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:38:32.700486
1707	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 19:45:24.151862
1708	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:50:59.224689
1709	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:50:59.310963
1710	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:50:59.319848
1711	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:01.697646
1712	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:01.779001
1713	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:01.779829
1714	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:17.550261
1715	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:17.628541
1716	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:17.636863
1717	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:22.232931
1718	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:22.266373
1719	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:22.270082
1720	192.168.0.102	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:34.47389
1721	192.168.0.102	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:34.547418
1722	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:46.729558
1723	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:46.796361
1724	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:46.805063
1725	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:51:50.772338
1726	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:50.82511
1727	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:51:50.856226
1729	192.168.0.102	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 19:52:16.992473
1732	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:54:03.480918
3812	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 16:57:15.647068
3820	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:00:06.176136
1730	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:54:03.403849
1731	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:54:03.481134
1733	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 19:59:07.390207
1734	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:59:07.436548
1735	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 19:59:07.442476
1736	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 19:59:20.788879
1737	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:59:20.8882
1738	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 19:59:20.916224
1739	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:02:20.651525
1740	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:20.703355
1741	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:20.707987
1742	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:02:22.04015
1743	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:22.091086
1744	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:22.091532
1745	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:02:26.185175
1746	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 20:02:27.652112
1747	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:27.685578
1748	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:27.69481
1749	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 20:02:37.473044
1750	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:37.541828
1751	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:37.542731
1752	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 20:02:49.236252
1753	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:49.287675
1754	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:49.289021
1755	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:02:54.100061
1756	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:54.166472
1757	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:02:54.169286
1758	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 20:04:52.905722
1759	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:04:52.962206
1760	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:04:52.967093
1761	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:10:46.432995
1762	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:46.483656
1763	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:46.489154
2191	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:54:49.97772
1764	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:10:48.122485
1765	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:48.165117
1766	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:48.170188
1767	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 20:10:48.732323
1768	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:48.766173
1769	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 20:10:48.77198
1770	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:10:59.469902
1771	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:11:12.521946
1773	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:13:05.230569
1776	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:32:23.714538
1777	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:45:27.388012
1779	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:11:04.207045
1781	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:23:00.280401
1784	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:02:36.413351
3813	192.168.0.94	\N	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login_tickets	2025-12-16 16:57:41.281921
3814	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login_tickets	2025-12-16 16:57:41.492676
3818	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:00:06.033774
3819	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:00:06.168095
3822	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:00:58.189772
3824	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:01:21.018816
1772	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 20:13:05.157112
1774	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 20:13:05.232694
1775	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 20:22:57.465114
1778	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:02:34.403887
1780	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:11:15.010124
1782	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:32:30.030459
1783	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 21:45:30.722909
1785	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-27 22:08:30.436387
1786	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:30.56837
1787	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:30.573963
1788	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:50.718404
1789	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:50.725776
1790	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:08:51.791402
1791	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:52.95485
1792	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:08:52.955879
1793	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:10:00.894506
1795	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:10:00.94872
1794	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:10:00.94872
1796	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:11:04.766153
1797	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:04.815242
1798	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:04.820257
1799	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:11:08.493331
1800	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:11:16.875529
1801	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:11:18.862598
1803	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:18.910298
1802	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:18.910191
1804	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:11:28.481987
1805	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:28.535728
1806	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:11:28.540396
1807	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 22:11:32.610347
1808	192.168.0.102	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 22:11:32.616192
1809	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:12:17.138076
1810	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:17.211963
1811	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:17.212715
1812	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:26.542985
1813	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:46.657111
1814	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:53.71496
1815	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:12:55.544496
1816	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:13:06.459978
1817	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:19:09.880267
1818	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:09.926312
1819	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:09.932172
1820	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:19:18.989408
1821	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:19.045059
1822	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:19.050054
1823	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:34.789835
1824	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:19:45.013716
1825	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:23:00.456101
1826	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:32:34.927636
1827	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:32:36.42873
1828	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:32:52.676641
1829	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:32:52.73384
1830	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:32:52.743906
1831	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:32:56.724578
1832	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:34:28.081363
1833	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:28.136
1834	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:28.141227
1835	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:33.704761
1836	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:34:51.948746
1837	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:52.138515
1838	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:52.14252
1839	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:55.926817
1840	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:34:58.333233
1841	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:01.52162
1842	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:35:12.857025
1843	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:12.908246
1844	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:12.911875
1845	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:17.689133
1846	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:19.200994
1847	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:22.252836
1852	192.168.0.102	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 22:36:07.245346
1848	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:35:22.960683
1850	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:36:07.206196
3815	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 16:57:41.571363
3825	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:01:33.357985
1849	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:36:06.892216
1851	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:36:07.206196
1853	192.168.0.102	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-27 22:36:07.254021
1855	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:36:12.571158
3816	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 16:57:41.578314
3817	192.168.0.94	\N	/reportar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 16:59:51.821831
3821	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:00:44.326517
3823	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:01:07.739949
1854	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:36:11.640315
1856	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:37:30.978933
1857	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:31.022632
1858	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:31.027871
1859	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:37:37.354934
1860	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:37.408883
1861	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:37.415368
1862	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:40.834012
1863	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:42.135703
1864	192.168.0.102	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-27 22:37:47.68
1865	192.168.0.102	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:47.763074
1866	192.168.0.102	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:47.777382
1867	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:51.651464
1868	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:53.496022
1869	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:54.347211
1870	192.168.0.102	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-27 22:37:55.377669
1871	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:38:57.24535
1872	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:38:57.31419
1873	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:38:57.338878
1874	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:39:02.237549
1875	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:39:03.890659
1876	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:39:21.489271
1877	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:04.973176
1878	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-27 22:42:06.788523
1879	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:06.833835
1880	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:06.842458
1881	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:12.311139
1882	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:14.103996
1883	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-27 22:42:15.182147
1884	192.168.0.141	\N	/	GET	HomeNet/1.0	\N	2025-11-27 22:45:34.84954
1885	192.168.0.73	\N	/	GET	HomeNet/1.0	\N	2025-11-27 23:02:38.815025
1886	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-27 23:11:09.014309
1887	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-27 23:11:29.501461
1888	192.168.0.127	\N	/	GET	HomeNet/1.0	\N	2025-11-27 23:23:04.631383
1889	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-27 23:33:08.046868
1890	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 00:11:10.370584
1893	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:37:22.283982
1900	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 00:44:42.560305
1905	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:44:52.845138
1911	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:02.979655
1917	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:10.806157
1923	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:13.176457
1929	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:15.043658
1931	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:15.455333
3826	192.168.0.94	\N	/reportar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:03:04.890967
3830	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:16.52947
3831	192.168.0.94	\N	/api/tickets/1/tomar	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:24.469752
3832	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:24.562441
3835	192.168.0.94	\N	/api/tickets/1/estado	PUT	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:33.129082
3837	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:33.173444
3840	192.168.0.94	\N	/api/tickets/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:05:01.393322
1894	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 00:37:48.538004
1896	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:37:48.61998
1897	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:37:55.580446
1909	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:02.607459
1910	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:02.790002
1912	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:09.108625
1913	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:09.339557
1914	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:09.522535
1915	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:09.69368
1922	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:13.006497
1924	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:13.339845
1925	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:13.476928
3827	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:03:08.114792
3828	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:03:16.4561
3829	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:16.527667
3834	192.168.0.94	\N	/api/tickets/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:28.204954
3838	192.168.0.94	\N	/api/tickets/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:40.060218
3839	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:04:28.260958
1895	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:37:48.61909
1901	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 00:44:42.807145
1902	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 00:44:42.968865
1908	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:02.421082
1916	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:09.839353
1918	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:10.955864
1920	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:11.37228
1921	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:11.572465
1927	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:14.606874
1928	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:14.782262
1930	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:15.240975
1932	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:15.770358
3833	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:24.572523
3836	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:03:33.173558
3841	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:10:24.664294
1898	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 00:44:36.946314
1899	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 00:44:37.008653
1903	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 00:44:42.969756
1904	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 00:44:52.799402
1906	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:44:52.845547
1907	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:02.256683
1919	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:11.171931
1926	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:13.639943
1933	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:17.628145
1934	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:45:23.547572
1935	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-28 00:47:35.820045
1936	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:47:35.888408
1937	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:47:35.900043
1938	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:47:41.26723
1939	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:47:43.316994
1940	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 00:47:47.826736
1941	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:47:54.290331
1942	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:47:54.442588
1943	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:47:54.667438
1944	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:47:54.856275
1945	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 00:47:55.104371
1946	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:52.122999
1947	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:52.251566
1948	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:52.395223
1949	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:52.565412
1950	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:52.706188
1951	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:53.700092
1952	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:53.907602
1953	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:54.201564
1954	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:54.400644
1955	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:55.450088
1956	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:58.287104
1957	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:58.50063
1958	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:58.701486
1959	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:58.868667
1962	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:01.010206
1968	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:06.933597
1969	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:07.16593
1973	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:04:08.538201
1978	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:17.709467
1979	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:19.902484
1980	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:21.63864
1983	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:34.627991
1987	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:40.601989
3842	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:13:34.272495
3843	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:13:34.369814
3846	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:13:55.837828
3849	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:14:34.58261
3851	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:34.633956
3861	192.168.0.94	\N	/api/tickets/2/estado	PUT	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:13.746468
3862	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:13.800626
3865	192.168.0.94	\N	/api/tickets/descargar/excel	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:22.605797
3869	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:30:09.444084
1960	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:03:59.070104
1961	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:00.665624
1970	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:07.332664
1971	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:07.50024
1975	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:08.655246
1976	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:11.886693
1985	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:37.873524
1986	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:38.241734
1988	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:41.869726
1992	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:06:02.120951
1994	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:06:02.173699
1995	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:06:04.95297
3844	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:13:34.377867
3845	192.168.0.94	\N	/api/tickets/1	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:13:36.733264
3852	192.168.0.94	\N	/api/tickets/2/tomar	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:41.852458
3853	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:41.902683
3860	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:04.551621
1963	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:01.549384
1964	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:02.882434
1965	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:03.016345
1966	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:03.849852
1967	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:04.650275
1974	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:08.654734
1989	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:55.202903
1991	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:55.247765
1993	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:06:02.17086
3847	192.168.0.94	\N	/reportar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:14:03.199556
3850	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:34.632752
3854	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:41.902748
3855	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:14:45.332612
3856	192.168.0.94	\N	/api/tickets/2/imagen	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:04.235257
3857	192.168.0.94	\N	/api/tickets/2/comentario	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:04.459326
3858	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:04.547229
3864	192.168.0.94	\N	/api/tickets/descargar/excel	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:21.257047
3866	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:28:08.026299
3867	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:28:59.338658
1972	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:07.607183
1977	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:12.613386
1981	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:23.601033
1982	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-28 01:04:34.57335
1984	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:04:34.629655
1990	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:04:55.247765
1996	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:06:06.670347
1997	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:09:26.930946
1998	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:09:26.992481
1999	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:09:26.998926
2000	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:09:31.71826
2001	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:09:31.759035
2002	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:09:31.761712
2003	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:09:44.052631
2004	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:09:45.353092
2005	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:09:57.020399
2006	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 01:11:12.590654
2007	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:11:34.144962
2008	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 01:11:59.364367
2009	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:13:32.525316
2010	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:32.673121
2011	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:32.680019
2012	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:37.541658
2013	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:38.361312
2014	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:41.995026
2015	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:46.072405
2016	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:49.532407
2017	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:52.397262
2018	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:13:54.958274
2019	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:00.078372
2020	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:00.765904
2021	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:22.722124
2022	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:24.707311
2023	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:27.232431
2192	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:57:57.203005
2194	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:12:00.272227
2024	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:14:27.826604
2025	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:14:46.785947
2026	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:14:46.81748
2027	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 01:14:53.124768
2028	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 01:14:53.380848
2030	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:14:53.545124
2031	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:14:55.405928
2033	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:14:55.466283
2035	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:14:59.079438
3848	192.168.0.94	\N	/api/tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/reportar	2025-12-16 17:14:30.509599
3859	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:04.549436
3863	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:15:13.80121
3868	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:29:46.912918
2029	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:14:53.545196
3870	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	\N	2025-12-16 17:45:55.656166
3871	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:45:55.737875
3876	192.168.0.94	\N	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 17:46:16.951679
3878	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 17:47:16.182201
3879	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:47:16.234953
2032	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:14:55.459715
3872	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:45:55.762781
3880	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:47:16.23552
2034	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:14:58.38148
2036	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:16:06.667064
2037	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:16:06.717396
2038	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:16:06.728215
2039	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:16:10.757093
2040	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:16:11.932901
2041	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:16:13.367353
2042	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:16:24.086096
2043	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:16:24.136234
2044	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:16:24.136494
2045	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:16:27.732137
2046	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:16:28.763412
2047	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:17:49.207469
2048	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:17:49.292367
2049	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:17:49.293509
2050	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:17:53.827942
2051	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:17:54.178425
2052	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:18:00.578518
2053	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:18:04.482448
2054	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:20:53.582208
2055	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:20:53.636942
2056	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:20:53.638622
2057	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:20:59.629687
2058	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:01.121964
2059	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:01.68036
2060	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:02.059387
2061	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:21:04.525859
2062	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:04.573317
2063	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:04.5704
2064	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:21:07.588934
2065	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:22:22.344266
2066	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:22:22.434453
2067	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:22:22.436905
2068	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:22:26.056522
2069	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:22:26.571775
2070	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:23:19.825595
2071	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:23:19.870947
2072	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:23:19.873583
2073	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:23:22.188723
2074	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:28:44.655303
2075	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:44.771294
2076	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:44.774658
2077	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:49.451475
2078	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:49.83754
2079	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:51.226707
2080	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:52.449031
2081	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:53.387306
2082	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:55.800932
2083	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:28:58.155341
2084	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:29:01.735106
2085	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:29:01.76169
2086	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 01:29:08.80127
2087	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 01:29:09.04838
2088	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:29:09.170328
2089	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:29:09.172457
2090	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/admin	2025-11-28 01:29:17.148465
2091	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:29:17.196794
2092	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:29:17.197153
2093	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:29:24.022995
2094	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:29:24.617703
2095	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:29:25.055157
2096	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:32:59.563008
2097	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	\N	2025-11-28 01:34:34.835471
2098	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:34.898936
2099	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:34.902169
2100	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:38.817187
2101	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:40.418982
2102	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 01:34:44.800212
2103	192.168.0.94	admin	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:34:46.68461
2107	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:50.962572
2111	192.168.0.94	admin	/api/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:34:56.246383
2113	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:35:18.91515
3873	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:45:58.826419
3874	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 17:46:02.529204
3875	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 17:46:16.87035
2104	192.168.0.94	admin	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:46.737671
2108	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:53.236829
2115	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:35:22.776188
3877	192.168.0.94	\N	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 17:47:15.950717
3881	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:47:22.462424
2105	192.168.0.94	admin	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:46.73939
2110	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:34:53.283429
2116	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:35:25.36305
3882	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 17:50:54.043643
3883	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:50:54.092778
2106	192.168.0.94	admin	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:34:49.97034
2109	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/	2025-11-28 01:34:53.281198
2112	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:35:18.790926
2114	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:35:18.91515
2117	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 01:38:10.894977
2118	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:38:11.00242
2119	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:38:11.004912
2120	192.168.0.94	\N	/public/productos/buscar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 01:38:14.158675
2121	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 02:11:14.591641
2122	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 02:34:46.386979
2123	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 03:11:19.407753
2124	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 03:35:03.961448
2125	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 04:11:20.681159
2126	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 04:12:11.550027
2127	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 04:35:19.531618
2128	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 05:11:23.321802
2129	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 05:12:13.124009
2130	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 05:35:34.837601
2131	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 06:11:24.723341
2132	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 06:12:16.037508
2133	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 06:35:47.408218
2134	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 07:11:26.961879
2135	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 07:12:17.292412
2136	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 08:11:34.527021
2137	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 08:12:23.653749
2138	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 08:36:14.144624
2139	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 09:11:37.140677
2140	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 09:36:18.385505
2141	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 10:11:40.857537
2142	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 10:12:29.005108
2143	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 10:36:20.977317
2144	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 11:11:43.237533
2145	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 11:12:29.804645
2146	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 11:36:26.91213
2147	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 12:11:46.534994
2148	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 12:12:34.227505
2149	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 12:22:22.819338
2150	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 12:36:29.92929
2151	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:04:47.502971
2152	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:11:48.015209
2153	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:12:35.39221
2154	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:22:29.493188
2155	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:36:41.138904
2156	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:54:35.073233
2157	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 13:57:23.344486
2158	192.168.0.134	\N	/	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-28 14:03:15.632078
2159	192.168.0.134	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-28 14:03:15.704021
2160	192.168.0.134	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	\N	2025-11-28 14:03:24.88472
2161	192.168.0.134	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-28 14:03:25.406687
2162	192.168.0.134	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-28 14:03:25.570232
2163	192.168.0.134	\N	/apple-touch-icon-precomposed.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-28 14:03:25.570238
2164	192.168.0.134	\N	/apple-touch-icon.png	GET	NetworkingExtension/8621.2.5.10.10 Network/4277.122.6 iOS/18.5	\N	2025-11-28 14:03:26.634689
2165	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:05:02.18551
2166	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:11:51.133209
2167	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:12:39.670146
2168	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:22:31.398153
2169	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:36:52.228959
2170	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:54:44.168902
2171	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 14:57:26.852111
2172	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:05:05.873343
2173	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:11:56.706991
2174	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:12:39.96188
2175	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:22:31.116746
2176	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:37:03.351914
2177	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:54:37.965265
2178	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 15:57:36.957246
2179	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:05:09.385316
2180	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:11:58.342335
2181	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:12:44.279082
2182	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:22:37.579243
2183	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:37:04.562869
2184	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:54:46.976998
2185	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 16:57:33.132821
2186	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:05:11.787774
2187	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:12:00.252522
2188	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:13:05.302384
2189	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:22:31.825409
2190	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 17:37:14.584327
2195	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:13:06.404928
2196	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:22:41.390875
2199	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:05:12.100556
2204	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:37:20.207295
2206	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:05:15.901884
2210	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:25:26.214608
2212	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:54:56.083143
2220	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:05:23.932792
2222	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:13:10.210373
2228	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/catalogo_consulta	2025-11-28 22:48:33.242866
2239	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:56:00.634378
2245	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:15.117117
2247	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:27.68504
3884	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:50:54.097646
3885	192.168.0.94	\N	/api/tickets/2	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:50:57.812701
3889	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:51:12.309264
2197	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:37:18.564484
2203	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:25:19.148986
2215	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:13:09.60976
2217	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:25:27.45739
2224	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:25:35.82083
2227	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-28 22:48:33.168183
2229	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/catalogo_consulta	2025-11-28 22:48:33.242866
2232	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/catalogo_consulta	2025-11-28 22:48:36.4544
2233	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:49:22.288946
2235	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-28 22:49:22.350233
2238	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:55:54.962638
3886	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 17:51:09.409943
3887	192.168.0.94	\N	/api/tickets/2/devolver	PUT	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:51:12.244644
3888	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 17:51:12.309264
2198	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 18:54:42.307768
2200	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:12:05.060797
2201	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:13:07.36833
2202	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:22:57.115287
2207	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:12:06.885331
2209	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:22:59.077759
2211	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:37:22.195351
2213	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:05:24.669854
2216	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:23:02.142279
2221	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:12:11.75407
2223	192.168.0.180	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:23:09.473058
2225	192.168.0.94	admin	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-28 22:48:18.591027
2226	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-28 22:48:18.616656
2236	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 22:54:54.299666
2237	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:55:54.94026
2242	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:56:09.266873
2249	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:51.686309
2250	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:51.917442
2251	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:51.932897
2252	192.168.0.94	\N	/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:57:04.69846
3890	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:04:28.636412
2205	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 19:54:45.836242
2208	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 20:13:07.793615
2214	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:12:11.056099
2218	192.168.0.211	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:37:24.194522
2219	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 21:54:58.949218
2230	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	\N	2025-11-28 22:48:36.401583
2231	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:145.0) Gecko/20100101 Firefox/145.0	http://192.168.0.192/catalogo_consulta	2025-11-28 22:48:36.454399
2234	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/catalogo_consulta	2025-11-28 22:49:22.345061
2240	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:56:09.031921
2241	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:56:09.247001
2243	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:14.871195
2244	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:15.097123
2246	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:27.453233
2248	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 22:56:27.699642
2253	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:57:04.72704
2254	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 22:58:20.580903
2255	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:58:27.263026
2256	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:58:27.462417
2257	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 22:58:27.491615
2258	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 23:01:30.775103
2259	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:01:32.155029
2260	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:01:32.378021
2261	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:01:32.400189
2262	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:04:07.16649
2263	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:04:09.647315
2264	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:04:09.873318
2265	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:04:09.894605
2266	192.168.0.94	\N	/catalogo_consulta	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	\N	2025-11-28 23:04:25.132959
2267	192.168.0.94	\N	/public/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 23:04:25.200469
2268	192.168.0.94	\N	/public/categorias	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 23:04:25.208169
2269	192.168.0.94	\N	/	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 23:04:27.184828
2270	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/catalogo_consulta	2025-11-28 23:04:27.203172
2318	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 07:12:38.302155
2319	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 07:14:22.470589
2271	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 23:04:33.586853
3891	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:11:39.285231
3892	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:28:12.487223
3893	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:29:04.126038
3896	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:51:06.580985
3899	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:28:18.674799
3900	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:29:05.560182
3901	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:29:57.650873
3903	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:51:10.21213
3905	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:12:25.304369
3906	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:28:11.949172
3917	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-16 20:45:06.829797
3924	192.168.0.94	admin	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:57:36.212333
3927	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:58:00.199568
3928	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:58:33.400035
3930	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:04:38.106799
2272	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 23:04:33.820059
2273	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 23:04:33.836863
2274	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login	2025-11-28 23:05:40.561222
2275	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:47.097834
2276	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:47.288851
2277	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:47.30552
2278	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:53.410366
2279	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:58.211139
2280	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:58.440986
2281	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36 Edg/142.0.0.0	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:05:58.462228
2282	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:21.454821
2283	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:21.703055
2284	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:21.72585
2285	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:24.905161
2286	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:25.135778
2287	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-28 23:08:25.152596
2288	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	\N	2025-11-28 23:09:16.381893
2289	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 23:09:18.824438
2290	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 23:09:19.071613
2291	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-28 23:09:19.088314
2292	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-28 23:12:17.01724
2293	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-28 23:13:24.403166
2294	192.168.0.121	\N	/	GET	HomeNet/1.0	\N	2025-11-28 23:25:32.912114
2295	192.168.0.166	\N	/	GET	HomeNet/1.0	\N	2025-11-28 23:55:05.479007
2296	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 00:05:33.604656
2297	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 00:12:19.176201
2298	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 00:13:26.225991
2299	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 01:05:32.859433
2300	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 01:12:20.698951
2301	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 01:14:02.573736
2302	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 02:05:37.95074
2303	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 02:12:22.141967
2304	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 02:14:05.446572
2305	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 03:05:39.907311
2306	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 03:12:22.598206
2307	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 03:14:06.116156
2308	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 04:05:40.880646
2309	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 04:12:28.255057
2310	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 04:14:18.028668
2311	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 05:05:42.269703
2312	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 05:12:34.276769
2313	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 05:14:21.356721
2314	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 06:05:43.977968
2315	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 06:12:35.65698
2316	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 06:14:21.763196
2317	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 07:05:47.330888
2320	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 08:05:49.560942
2322	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 08:14:25.108834
2326	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 10:05:52.517387
2327	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 10:12:44.843129
2328	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 10:14:31.109156
2331	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 11:14:32.386409
2333	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 12:12:52.025504
2337	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 13:15:06.975334
2340	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 14:15:09.292567
2342	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 15:12:56.131432
2344	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 16:05:59.793663
2347	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 17:06:01.302524
2349	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 17:15:31.280712
2351	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 18:13:04.836536
2354	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 19:13:05.321522
2361	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 22:06:15.478877
2365	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 23:13:11.271399
2367	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 00:06:17.760803
3894	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:29:54.166573
3895	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 18:30:10.676182
3907	192.168.0.69	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:29:06.283034
3913	192.168.0.94	\N	/logout_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 20:44:51.926776
3915	192.168.0.94	\N	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 20:45:01.562422
3916	192.168.0.94	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 20:45:01.581954
3918	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-16 20:45:06.885055
3920	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-16 20:45:07.046772
3923	192.168.0.94	admin	/reportar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 20:57:34.255926
3926	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:57:49.852175
3929	192.168.0.94	admin	/login_tickets	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 21:03:29.245738
3931	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:12:49.963261
2321	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 08:12:40.60186
2325	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 09:14:28.891924
2334	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 12:14:51.757018
2338	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 14:06:01.896375
2339	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 14:12:54.684199
2341	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 15:06:01.528053
2343	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 15:15:28.214522
2346	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 16:15:30.163101
2348	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 17:13:03.083631
2358	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 21:06:14.330253
2360	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 21:16:37.819613
2362	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 22:13:11.113621
2369	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 00:17:35.091149
2372	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-30 01:17:34.732675
3897	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:04:34.94596
3902	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:30:09.157215
3904	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:04:35.961818
3910	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:44:48.946071
3912	192.168.0.94	\N	/api/bandeja-entrada	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 20:44:49.029734
3922	192.168.0.94	admin	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 20:57:33.582705
2323	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 09:05:48.546739
2332	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 12:05:56.671653
2335	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 13:06:00.946905
2336	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 13:12:53.73876
2350	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 18:06:02.329473
2352	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 18:15:38.842565
2353	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 19:06:14.242852
2355	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 19:15:50.503715
2357	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 20:16:14.141857
2359	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 21:13:08.448198
2366	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 23:17:09.047508
3898	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 19:12:01.859101
3908	192.168.0.82	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:29:59.91889
3909	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:30:17.723501
3911	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 20:44:49.029365
3914	192.168.0.94	\N	/reportar	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/soporte	2025-12-16 20:44:51.950748
3919	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-16 20:45:07.046772
3921	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 20:51:13.470097
3925	192.168.0.94	admin	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login_tickets	2025-12-16 20:57:36.239838
2324	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 09:12:45.040407
2329	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 11:05:55.066734
2330	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 11:12:46.631002
2345	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 16:13:00.769661
2356	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-29 20:13:06.84068
2363	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-11-29 22:16:48.246203
2364	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-29 23:06:25.005283
2368	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 00:13:05.877779
2370	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 01:06:20.539538
2371	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 01:13:07.936113
2373	192.168.0.94	\N	/login	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login	2025-11-30 01:41:53.744473
2374	192.168.0.94	\N	/login	POST	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-30 01:42:08.475254
2375	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/login?mensaje=La+sesi%C3%B3n+ha+sido+cerrada+autom%C3%A1ticamente+por+horario+de+seguridad+(despu%C3%A9s+de+las+19:00).	2025-11-30 01:42:08.679594
2376	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:08.948302
2377	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:08.945892
2378	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:30.262046
2379	192.168.0.94	admin	/api/proveedores	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:30.446168
2380	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:30.45027
2381	192.168.0.94	admin	/api/estadisticas	GET	Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1	http://192.168.0.192/admin	2025-11-30 01:42:33.963099
2382	192.168.0.221	\N	/	GET	HomeNet/1.0	\N	2025-11-30 02:06:23.766659
2383	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-11-30 02:13:19.928251
3932	192.168.0.94	admin	/login_tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-16 21:14:26.27724
3937	192.168.0.94	\N	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login_tickets	2025-12-16 21:24:13.705068
3939	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 21:24:13.820835
3942	192.168.0.94	\N	/api/mis-tickets	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/soporte	2025-12-16 21:24:16.147304
3945	192.168.0.94	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login	2025-12-16 21:24:47.595118
3946	192.168.0.94	admin	/admin	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/login	2025-12-16 21:24:47.813514
3947	192.168.0.94	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0	http://192.168.0.192/admin	2025-12-16 21:24:47.901384
3949	192.168.0.188	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:28:14.347099
3952	192.168.0.104	\N	/	GET	HomeNet/1.0	\N	2025-12-16 21:30:12.15599
3954	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:04:41.638481
3959	192.168.0.54	\N	/	GET	HomeNet/1.0	\N	2025-12-16 22:51:18.965117
3960	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-16 23:04:45.999597
3961	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-16 23:13:35.376956
3966	192.168.0.94	\N	/	GET	HomeNet/1.0	\N	2025-12-17 00:29:34.783415
3978	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 06:05:57.76651
3982	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 08:06:05.086486
3986	192.168.0.198	\N	/	GET	HomeNet/1.0	\N	2025-12-17 10:06:08.526092
3996	192.168.0.105	\N	/login	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	\N	2025-12-17 12:58:01.015756
3998	192.168.0.105	\N	/login	POST	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/login	2025-12-17 13:00:32.809874
4002	192.168.0.105	admin	/api/productos	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 13:00:38.709108
4003	192.168.0.105	admin	/soporte	GET	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0	http://192.168.0.192/admin	2025-12-17 13:00:43.707755
4006	192.168.0.206	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:28:02.73051
4010	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 13:58:37.300166
4017	192.168.0.105	\N	/	GET	HomeNet/1.0	\N	2025-12-17 14:58:40.386259
\.


--
-- Data for Name: comentarios_tickets; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.comentarios_tickets (id, ticket_id, ingeniero_id, contenido, imagen_url, fecha_creacion) FROM stdin;
1	2	8	se corrije cable de corriente	\N	2025-12-16 17:15:04.509748
\.


--
-- Data for Name: historial_precios_proveedor; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.historial_precios_proveedor (id, producto_proveedor_id, precio, fecha_precio, notas, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.permissions (id, module, action, descripcion) FROM stdin;
1	tickets	view	Ver tickets
2	tickets	edit	Editar tickets
3	tickets	export	Exportar tickets a Excel
4	catalog	view	Ver catálogo
5	catalog	edit	Editar catálogo
\.


--
-- Data for Name: producto_proveedor; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.producto_proveedor (id, producto_id, proveedor_id, precio_proveedor, fecha_precio, cantidad_minima, fecha_creacion) FROM stdin;
\.


--
-- Data for Name: productos; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.productos (id, nombre, descripcion, precio, cantidad, imagen_url, categoria, fecha_creacion, fecha_actualizacion) FROM stdin;
1	TP11	TAPON P/CAJA DE REDUCTOR 3/8	0	0	\N	\N	\N	\N
2	TP12	TAPON P/CAJA DE REDUCTOR 3/8 BARRENADO	0	0	\N	\N	\N	\N
3	TP13	TAPON PERNO CONICO 9/16 P/BOQUILLA LATON	0	0	\N	\N	\N	\N
4	TZ01	TAZA 15520 ETK	0	0	\N	\N	\N	\N
5	TF01	TEFLON 1 METRO	0	0	\N	\N	\N	\N
6	TF03	TEFLON DPLX	0	0	\N	\N	\N	\N
7	TF04	TEFLON SENCILLO	0	0	\N	\N	\N	\N
8	TO01	TORNILLO CABEZA DE GOTA 1/4 X 1	0	0	\N	\N	\N	\N
9	TO02	TORNILLO CABEZA DE GOTA 3/16 X 1/2	0	0	\N	\N	\N	\N
10	TO15	TORNILLO CABEZA HEXAGONAL 1/2 X 3' 1/2	0	0	\N	\N	\N	\N
11	TO09	TORNILLO CABEZA HEXAGONAL 3/4-1 1/2	0	0	\N	\N	\N	\N
12	TO03	TORNILLO CABEZA HEXAGONAL 3/8 X 1	0	0	\N	\N	\N	\N
13	TO04	TORNILLO CABEZA HEXAGONAL 3/8 X 1 1/4	0	0	\N	\N	\N	\N
14	TO99	TORNILLO CABEZA HEXAGONAL 3/8 X 1 INOX	0	0	\N	\N	\N	\N
15	TO05	TORNILLO CABEZA HEXAGONAL 3/8 X 3/4	0	0	\N	\N	\N	\N
16	TO06	TORNILLO CABEZA HEXAGONAL 5/16 X 1	0	0	\N	\N	\N	\N
17	TO07	TORNILLO CABEZA HEXAGONAL 5/16 X 3/4	0	0	\N	\N	\N	\N
18	TO08	TORNILLO CABEZA HEXAGONAL 7/16 X 1	0	0	\N	\N	\N	\N
19	TO10	TORNILLO SET CAB CUAD 1/4X1/2 P/TRINQUET	0	0	\N	\N	\N	\N
20	TO11	TORNILLO SET CAB CUAD SET 3/8 X 1 1/2 MOLETEADOS MARCA TOLEDO	0	0	\N	\N	\N	\N
21	TO12	TORNILLO SET CAB CUAD SET 3/8 X 1 1/4 MOLETEADOS MARCA TOLEDO	0	0	\N	\N	\N	\N
22	TO13	TORNILLO SET CAB CUAD SET 3/8 X 3/4	0	0	\N	\N	\N	\N
23	TS07	TRANSPORTADOR MAQUINA-ENFRIADOR	0	0	\N	\N	\N	\N
24	TC01	TUERCA CUADRADA 1/4	0	0	\N	\N	\N	\N
25	TC02	TUERCA DE LATON	0	0	\N	\N	\N	\N
26	TC97	TUERCA HEXAGONAL 1/2 INOX	0	0	\N	\N	\N	\N
27	TC98	TUERCA HEXAGONAL 3/8 INOX	0	0	\N	\N	\N	\N
28	TC99	TUERCA HEXAGONAL 5/8 INOX	0	0	\N	\N	\N	\N
29	TC03	TUERCA TENSORA P/CABEZAL RESTAURANTERO	0	0	\N	\N	\N	\N
30	VA09	VALVULA SOLENOIDE 1	0	0	\N	\N	\N	\N
31	VA04	VALVULA SOLENOIDE 1/2 BAJO FLUJO	0	0	\N	\N	\N	\N
32	VA07	VALVULA SOLENOIDE 3/4	0	0	\N	\N	\N	\N
33	VL05	VARILLA TRAVESANO DPLX	0	0	\N	\N	\N	\N
34	MO33	MPTOREDUCTOR	0	0	\N	\N	\N	\N
35	MU01	MUELLE PARA CARRO	0	0	\N	\N	\N	\N
36	OP01	OPRESOR ALLEN 1/4X5/16	0	0	\N	\N	\N	\N
37	OP94	OPRESOR ALLEN 1/4X5/16 INOX GA	0	0	\N	\N	\N	\N
38	OP93	OPRESOR ALLEN 3/8 X 1 CBEZA CUADRAD INOX	0	0	\N	\N	\N	\N
39	OP02	OPRESOR ALLEN 3/8 X 1/2	0	0	\N	\N	\N	\N
40	OP95	OPRESOR ALLEN 3/8 X 1/2 INOX	0	0	\N	\N	\N	\N
41	OP03	OPRESOR ALLEN 3/8X3/8	0	0	\N	\N	\N	\N
42	OP04	OPRESOR ALLEN 5/16 X 1/2	0	0	\N	\N	\N	\N
43	OP96	OPRESOR ALLEN 5/16 X 1/2 INOX	0	0	\N	\N	\N	\N
44	OP05	OPRESOR ALLEN 5/8 X 1/2	0	0	\N	\N	\N	\N
45	OP97	OPRESOR SET 3/8 X 1 1/2 CABEZA CUAD INOX	0	0	\N	\N	\N	\N
46	OP98	OPRESOR SET 3/8 X 1 1/4 CABEZA CUAD INOX	0	0	\N	\N	\N	\N
47	OP99	OPRESOR SET 3/8 X 3/4 CABEZA CUAD INOX	0	0	\N	\N	\N	\N
48	PP09	PAPEL GA P/1KG 21 GR/M2 2850 HOJAS	0	0	\N	\N	\N	\N
49	PP08	PAPEL GA P/2KG 21 GR/M2 1050 HOJAS	0	0	\N	\N	\N	\N
50	PP10	PAPEL GA P/2KG 21 GR/M2 1425 HOJAS	0	0	\N	\N	\N	\N
51	COM007	Perfil T de 1' de ancho en un largo de 3 m, respaldo acero inoxidable, alto 21 mm, Clave 12263-E	0	0	\N	\N	\N	\N
52	PE03	PERFILADOR DUPLEX 10 CM	0	0	\N	\N	\N	\N
53	PE04	PERFILADOR DUPLEX 11 CM	0	0	\N	\N	\N	\N
54	PE05	PERFILADOR DUPLEX 12 CM	0	0	\N	\N	\N	\N
55	PE06	PERFILADOR DUPLEX 13 CM	0	0	\N	\N	\N	\N
56	PE07	PERFILADOR DUPLEX 14 CM	0	0	\N	\N	\N	\N
57	PE08	PERFILADOR DUPLEX 15 CM	0	0	\N	\N	\N	\N
58	PE09	PERFILADOR DUPLEX 16 CM	0	0	\N	\N	\N	\N
59	PE17	PERFILADOR FE-INOX DUPLEX 15 CM	0	0	\N	\N	\N	\N
60	PN01	PERNO P/BANDA METALICA	0	0	\N	\N	\N	\N
61	PN02	PERNO P/BANDA METALICA 100 PIEZAA	0	0	\N	\N	\N	\N
62	PA01	PINTURA ALUMINIO ALTA TEMPERATURA 1 LTR	0	0	\N	\N	\N	\N
63	PA02	PINTURA GRIS DE 1 LTR	0	0	\N	\N	\N	\N
64	PA03	PINTURA VERDE DE 1 LTR	0	0	\N	\N	\N	\N
65	POT003	POTENCIOMETRO 10 VUELTAS 10K	0	0	\N	\N	\N	\N
66	RD05	REDUCTOR 80	0	0	\N	\N	\N	\N
67	MO34	REDUCTOR M06 PARA MOTOR BRIDA C 2HP	0	0	\N	\N	\N	\N
68	RG89	REGATON 1/4 RESPALDO PARA AMASADORA	0	0	\N	\N	\N	\N
69	RG01	REGULADOR FASE 1	0	0	\N	\N	\N	\N
70	RG02	REGULADOR FASE 2	0	0	\N	\N	\N	\N
71	REL006	RELEVADOR 8PIN 24VDC C/BASE	0	0	\N	\N	\N	\N
72	RS13	RESISTENCIA P/ PRENSA LIBRO SENCILLO 7'	0	0	\N	\N	\N	\N
73	RS08	RESORTE C/GANCHO DE TENSION GALV MAQ ROD	0	0	\N	\N	\N	\N
74	RS07	RESORTE P/CABEZAL REST ECO AUT	0	0	\N	\N	\N	\N
75	RS09	RESORTE PARA ACOMODADOR DE TORTILLA	0	0	\N	\N	\N	\N
76	RS01	RESORTE PARA CARRO DPLX (NORMAL)	0	0	\N	\N	\N	\N
77	RS02	RESORTE PARA CARRO SENC TROPICALIZADO	0	0	\N	\N	\N	\N
78	RS03	RESORTE PARA REGULADOR DE ALTA	0	0	\N	\N	\N	\N
79	RS04	RESORTE PARA REGULADOR DE BAJA	0	0	\N	\N	\N	\N
80	RS05	RESORTE PARA TRINQUETE	0	0	\N	\N	\N	\N
81	RS06	RESORTE TENSOR PARA COMAL MA	0	0	\N	\N	\N	\N
82	RN03	RETEN 13071 GRANDE	0	0	\N	\N	\N	\N
83	RN13	RETEN 13071 GRANDE CR	0	0	\N	\N	\N	\N
84	RN01	RETEN 8654 CHICO	0	0	\N	\N	\N	\N
85	RN14	RETEN 8654 CHICO CR	0	0	\N	\N	\N	\N
86	RN02	RETEN 9966 CENTRAL	0	0	\N	\N	\N	\N
87	RN16	RETEN 9966 CENTRAL CR	0	0	\N	\N	\N	\N
88	COM005	Retenedor para sección cuadrada de 1.5' en nylon. sección cuadrada de 1.5'	0	0	\N	\N	\N	\N
89	WM-RC142	RODILLO CORTADOR 15.5 CM	0	0	\N	\N	\N	\N
90	RL01	ROLLO ALAMBRE P/MAQ RODILLOS	0	0	\N	\N	\N	\N
91	RA03	RONDANA PLANA 1/4 NORM P/VARILLA TRAVESA	0	0	\N	\N	\N	\N
92	RUE004	RUEDA LOCA DE 4' ECONÓMICA C/FRENO	0	0	\N	\N	\N	\N
93	RUE003	RUEDA LOCA DE 4' ECONÓMICA S/FRENO	0	0	\N	\N	\N	\N
94	SL99	SELLO DE HULE GRADO ALIMENTICIO	0	0	\N	\N	\N	\N
95	SL01	SELLO ESPONJA	0	0	\N	\N	\N	\N
96	SF88	SINFIN LARGO DERECHO MAQUINADO NAYLAMID	0	0	\N	\N	\N	\N
97	SF89	SINFIN LARGO IZQUIERD MAQUINADO NAYLAMID	0	0	\N	\N	\N	\N
98	SF17	SINFIN P/REDUCTOR 80	0	0	\N	\N	\N	\N
99	SF20	SINFIN PARA MOLINO TOLUCA No. 1	0	0	\N	\N	\N	\N
100	SF22	SINFIN PARA MOLINO TOLUCA No. 3	0	0	\N	\N	\N	\N
101	COM008	Sprocket serie MD254 en acetal 15 dientes 4.8' dp y para sección cuadrada de 1.5' POM	0	0	\N	\N	\N	\N
102	AC01	ACEITE BARDAHL ESTANDAR 250	0	0	\N	\N	\N	\N
103	RL15	ALAMBRE DESPEGADOR 15 GR	0	0	\N	\N	\N	\N
104	RL90	ALAMBRE DESPEGADOR 90 GR	0	0	\N	\N	\N	\N
105	AN01	ANTIADHERENTE A 19 LITROS	0	0	\N	\N	\N	\N
106	BA31	BALERO 6205 ZZ MULTIMARCA	0	0	\N	\N	\N	\N
107	CD11	CADENA (CS311A2-00(HT) X 100 FT-PC	0	0	\N	\N	\N	\N
108	CD02	CADENA P40 CAJA	0	0	\N	\N	\N	\N
109	CD06	CADENA P50 CAJA	0	0	\N	\N	\N	\N
110	CD04	CADENA P42 CAJA	0	0	\N	\N	\N	\N
111	CD08	CANDADO P40	0	0	\N	\N	\N	\N
112	CD09	CANDADO P42	0	0	\N	\N	\N	\N
113	CD10	CANDADO P50	0	0	\N	\N	\N	\N
114	CD07	CANDADO PARA BANDA METALICA MA	0	0	\N	\N	\N	\N
115	CA104	CATARINA 40B13 E.1" C.1/4	0	0	\N	\N	\N	\N
116	CA106	CATARINA 40B21 E.15/16"	0	0	\N	\N	\N	\N
117	CA107	CATARINA 40B21 E.25MM C.1/4	0	0	\N	\N	\N	\N
118	CA109	CATARINA 40B21 E.7/8"	0	0	\N	\N	\N	\N
119	CA184	CATARINA 40B23 E.1-1/8" C.1/4	0	0	\N	\N	\N	\N
120	CA223	CATARINA 40B27 25MM	0	0	\N	\N	\N	\N
121	CA110	CATARINA 40B36 E.15/16"	0	0	\N	\N	\N	\N
122	CA129	CATARINA 50B120 E.1 1/4" C.1/4	0	0	\N	\N	\N	\N
123	CA217	CATARINA 50B14 E.1 1/4" C.1/4	0	0	\N	\N	\N	\N
124	CA218	CATARINA 50B20 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
125	CA219	CATARINA 50B21 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
126	CA220	CATARINA 50B22 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
127	CA221	CATARINA 50B23 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
128	CA117	CATARINA 50B33 E.1" C.1/4	0	0	\N	\N	\N	\N
129	CA116	CATARINA 50B33 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
130	CA121	CATARINA 50B36 E.1" C.1/4	0	0	\N	\N	\N	\N
131	CA118	CATARINA 50B36 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
132	CA194	CATARINA 50B74 E.1-1/4" C.1/4	0	0	\N	\N	\N	\N
133	CA88	CATARINA 50B80 E.1" C.1/4	0	0	\N	\N	\N	\N
134	CO14	CORONA DE BRONCE P/ REDUCTOR 80	0	0	\N	\N	\N	\N
135	INS011	DISCO DURO SATA 8 TB	0	0	\N	\N	\N	\N
136	EXP153	DISPOSITIVO PARA EL PESAJE DE TORTILLAS	0	0	\N	\N	\N	\N
137	MT34	FLAME RELAY MODULO DETECTOR DE FLAMA	0	0	\N	\N	\N	\N
138	FL49	FLECHA P/ REDUCTOR 80	0	0	\N	\N	\N	\N
139	GR11	GRASA BARDAHL 450G	0	0	\N	\N	\N	\N
140	COM006	Guía de desgaste tipo 'U', de 9.65 X 7.87 mm, para solera vertical de 1/8' de espesor, en rollo de bobina de UHMWPE de 100' (30.48 m), clave 100303-30	0	0	\N	\N	\N	\N
141	IN01	INFRAROJO	0	0	\N	\N	\N	\N
142	INS010	INSUMOS DE COMPUTO	0	0	\N	\N	\N	\N
143	JUE025	JUEGO DE PIEDRAS 11 INT 2 1/4	0	0	\N	\N	\N	\N
144	MLEG18P	MALLA ENFRIADOR GALVANIZADA 18 PULGADAS X METRO	0	0	\N	\N	\N	\N
145	MLFG22P	MALLA FINA GALVANIZADA 22 PULGADAS X METRO	0	0	\N	\N	\N	\N
146	MLFG78C	MALLA FINA GALVANIZADA 78 CM X METRO	0	0	\N	\N	\N	\N
147	MLFG85C	MALLA FINA GALVANIZADA 85 CM X METRO	0	0	\N	\N	\N	\N
148	MLFI76C	MALLA FINA INOX 76 CM POR MTR	0	0	\N	\N	\N	\N
149	MAL008	MALLA INOX DE 24 PULG X 10 MTS PARA ENFRIADOR CAL 16	0	0	\N	\N	\N	\N
150	ML57	MALLA P/DESLIZADR MEC SEN GALV 28.5X40CM	0	0	\N	\N	\N	\N
151	MLEI18P	MALLA P/ENFRIADOR INOX 18PULG X METRO	0	0	\N	\N	\N	\N
152	EXP137	MALLA PARA ENFRIADOR DE 18" X 10 MTS. EN GALVANIZADO CALIBRE 14	0	0	\N	\N	\N	\N
153	BT10	MICROSWITCH GRIS NO SMP-304 CODIFICADO 230VCA	0	0	\N	\N	\N	\N
154	BT09	MICROSWITCH TELEMECANIQUE CODIFICADO 24V	0	0	\N	\N	\N	\N
155	WM-MO09	MOTOR 1/2 HP TRIFASICO 1750 RPM	0	0	\N	\N	\N	\N
156	MOT016	MOTOR 25HP 4P 284/6T 380V 50 HZ	0	0	\N	\N	\N	\N
157	MOT018	MOTOR 2HP 4P 143/5T 380V 50 HZ	0	0	\N	\N	\N	\N
158	MOT017	MOTOR 3HP 4P 182/4T 380V 50 HZ	0	0	\N	\N	\N	\N
159	MO48	MOTOR BRIDA C 1 HP PARA REDUCTOR M05	0	0	\N	\N	\N	\N
160	MR0001	MOTOREDUCTOR 1 HP P/ALIMENTADOR - TORTIMEX - MR0001	0	0	\N	\N	\N	\N
161	MOT029	MOTOREDUCTOR 200 WATTS	0	0	\N	\N	\N	\N
\.


--
-- Data for Name: proveedores; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.proveedores (id, nombre, telefono, rfc, domicilio, correo, contacto, notas, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.role_permissions (role_id, permission_id) FROM stdin;
1	1
1	5
1	4
1	3
1	2
2	2
2	1
2	3
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.roles (id, name, descripcion) FROM stdin;
1	admin	Administrador completo
2	support	Ingeniero de soporte
\.


--
-- Data for Name: tickets; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.tickets (id, numero_ticket, titulo, descripcion, nombre_solicitante, email_solicitante, departamento, ingeniero_id, estado, prioridad, categoria, fecha_creacion, fecha_asignacion, fecha_resolucion, fecha_actualizacion) FROM stdin;
1	TKT-1765904588129	no enciende	no enciende mi compu	jose magadan	josemagadanmaga-kurt@hotmail.com	Administración	8	resuelto	media	Hardware	2025-12-16 17:03:08.129254	2025-12-16 17:03:24.495327	2025-12-16 17:03:33.148651	2025-12-16 17:03:33.150402
2	TKT-1765905270530	no enciende	no enciende mi compu	jose 	juan@gmail.com	Compras	\N	nuevo	media	Hardware	2025-12-16 17:14:30.530248	\N	2025-12-16 17:15:13.767978	2025-12-16 17:51:12.282518
\.


--
-- Data for Name: usuarios; Type: TABLE DATA; Schema: public; Owner: catalogo_user
--

COPY public.usuarios (id, username, password_hash, correo, es_admin, activo, fecha_creacion, fecha_actualizacion, role_id) FROM stdin;
1	admin	scrypt:32768:8:1$AObwPY45ntJOePwC$4b7c85cc7bab75ffd821b6fae3ca50e24397d94561c9e058e17a6b0a35091763e861c0bd5fc63a5a359ad56a417d3ce53f88c5ff249f77eb51209bc27ad40acf	admin@example.com	t	t	2025-11-19 19:28:54.67718	2025-11-19 19:28:54.677186	\N
4	sara	scrypt:32768:8:1$UK2G5W1g1mwJu2xF$0244c308845c307a90abdcaee4cb88ecec05f5690cf08bf96251d10b6d1583d11ae039a1ed20c586011b18e2119926026526ab164831aa935294a72f6da6e0f8	sara@example.com	t	t	2025-11-19 19:33:25.240639	2025-11-19 19:33:25.240644	\N
5	root	scrypt:32768:8:1$WVN9STWFIifrsb7n$c66b4d994dd0bd8ad9e9acc689b5af6d0c406d888b34e93f0e6e35a08530f9b3c8601c0793534ce5db8245077766540bf73a0d43fd1ae683690b524240ebfb79	root@example.com	t	t	2025-11-20 01:36:09.86775	2025-11-20 01:36:09.867755	\N
6	ing_carlos	scrypt:32768:8:1$3DYOIIe9ELn4dqki$5e7a24a73b144c4924123f45b1807e4c27001c1734242ac69b656cd086c509b6d58dc1befd80d350440ee32e10579021720f2efe60bae54d96569355dd806136	carlos@company.com	f	t	2025-12-16 16:54:25.866192	2025-12-16 21:23:24.520698	2
7	ing_maria	scrypt:32768:8:1$dFXKPt6QhbsGuetx$138f99216152da31188c84544e72de9f183d934fc3c9012f7472cbf6c8d70eb10e777d77e6ad0da52e86a2a4df0939ac6eeacf280bfe927a4eee205eadf0d7be	maria@company.com	f	t	2025-12-16 16:54:26.05681	2025-12-16 21:23:24.524945	2
8	ing_jorge	scrypt:32768:8:1$f1taamVlJTIdFGYU$14c7fc366eeff5fc802b627e5b577299d9472b0b9f0b4d80e8f2d2582126616b874cc3609cd969905cb89a2bf1a0aee3251ee9ccf1f551d8eb7e230359f51332	jorge@company.com	f	t	2025-12-16 16:54:26.204938	2025-12-16 21:23:24.528234	2
\.


--
-- Name: access_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.access_logs_id_seq', 4093, true);


--
-- Name: comentarios_tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.comentarios_tickets_id_seq', 1, true);


--
-- Name: historial_precios_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.historial_precios_proveedor_id_seq', 1, false);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.permissions_id_seq', 5, true);


--
-- Name: producto_proveedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.producto_proveedor_id_seq', 1, true);


--
-- Name: productos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.productos_id_seq', 162, true);


--
-- Name: proveedores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.proveedores_id_seq', 4, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.roles_id_seq', 2, true);


--
-- Name: tickets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.tickets_id_seq', 2, true);


--
-- Name: usuarios_id_seq; Type: SEQUENCE SET; Schema: public; Owner: catalogo_user
--

SELECT pg_catalog.setval('public.usuarios_id_seq', 8, true);


--
-- Name: access_logs access_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.access_logs
    ADD CONSTRAINT access_logs_pkey PRIMARY KEY (id);


--
-- Name: comentarios_tickets comentarios_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.comentarios_tickets
    ADD CONSTRAINT comentarios_tickets_pkey PRIMARY KEY (id);


--
-- Name: historial_precios_proveedor historial_precios_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.historial_precios_proveedor
    ADD CONSTRAINT historial_precios_proveedor_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: producto_proveedor producto_proveedor_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.producto_proveedor
    ADD CONSTRAINT producto_proveedor_pkey PRIMARY KEY (id);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- Name: proveedores proveedores_nombre_key; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_nombre_key UNIQUE (nombre);


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_numero_ticket_key; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_numero_ticket_key UNIQUE (numero_ticket);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_correo_key; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_correo_key UNIQUE (correo);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: usuarios usuarios_username_key; Type: CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_username_key UNIQUE (username);


--
-- Name: comentarios_tickets comentarios_tickets_ingeniero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.comentarios_tickets
    ADD CONSTRAINT comentarios_tickets_ingeniero_id_fkey FOREIGN KEY (ingeniero_id) REFERENCES public.usuarios(id);


--
-- Name: comentarios_tickets comentarios_tickets_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.comentarios_tickets
    ADD CONSTRAINT comentarios_tickets_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.tickets(id);


--
-- Name: historial_precios_proveedor historial_precios_proveedor_producto_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.historial_precios_proveedor
    ADD CONSTRAINT historial_precios_proveedor_producto_proveedor_id_fkey FOREIGN KEY (producto_proveedor_id) REFERENCES public.producto_proveedor(id);


--
-- Name: producto_proveedor producto_proveedor_producto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.producto_proveedor
    ADD CONSTRAINT producto_proveedor_producto_id_fkey FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- Name: producto_proveedor producto_proveedor_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.producto_proveedor
    ADD CONSTRAINT producto_proveedor_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id);


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: tickets tickets_ingeniero_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_ingeniero_id_fkey FOREIGN KEY (ingeniero_id) REFERENCES public.usuarios(id);


--
-- Name: usuarios usuarios_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: catalogo_user
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- PostgreSQL database dump complete
--

\unrestrict OjhYDTXCtX3NPrNVbPejHbZC6vl0QUR5wCS3wtplmS2P1eNObK5mtbHINAnJxbh


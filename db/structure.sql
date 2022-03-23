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

--
-- Name: user_notification_nature; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_notification_nature AS ENUM (
    'info',
    'warning',
    'error'
);


--
-- Name: user_notification_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_notification_status AS ENUM (
    'unread',
    'read'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: clients; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clients (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived boolean DEFAULT false NOT NULL
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.clients_id_seq OWNED BY public.clients.id;


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.delayed_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;


--
-- Name: entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entries (
    id integer NOT NULL,
    user_id integer NOT NULL,
    title character varying,
    started_at timestamp without time zone NOT NULL,
    stopped_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    project_id integer
);


--
-- Name: entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entries_id_seq OWNED BY public.entries.id;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    client_id integer
);


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    token character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: sessions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_id_seq OWNED BY public.sessions.id;


--
-- Name: teamwork_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teamwork_domains (
    id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying NOT NULL,
    alias character varying NOT NULL,
    token character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teamwork_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teamwork_domains_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teamwork_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teamwork_domains_id_seq OWNED BY public.teamwork_domains.id;


--
-- Name: teamwork_time_entries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teamwork_time_entries (
    id integer NOT NULL,
    entry_id integer NOT NULL,
    teamwork_domain_id integer NOT NULL,
    time_entry_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teamwork_time_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teamwork_time_entries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teamwork_time_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teamwork_time_entries_id_seq OWNED BY public.teamwork_time_entries.id;


--
-- Name: teamwork_user_config_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teamwork_user_config_sets (
    id integer NOT NULL,
    user_id integer NOT NULL,
    set json DEFAULT '{}'::json NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teamwork_user_config_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teamwork_user_config_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teamwork_user_config_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teamwork_user_config_sets_id_seq OWNED BY public.teamwork_user_config_sets.id;


--
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_notifications (
    id integer NOT NULL,
    user_id integer NOT NULL,
    resource_type character varying,
    resource_id integer,
    nature public.user_notification_nature DEFAULT 'info'::public.user_notification_nature NOT NULL,
    status public.user_notification_status DEFAULT 'unread'::public.user_notification_status NOT NULL,
    title character varying,
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_notifications_id_seq OWNED BY public.user_notifications.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    salt character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    configs json
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: clients id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients ALTER COLUMN id SET DEFAULT nextval('public.clients_id_seq'::regclass);


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);


--
-- Name: entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries ALTER COLUMN id SET DEFAULT nextval('public.entries_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: sessions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN id SET DEFAULT nextval('public.sessions_id_seq'::regclass);


--
-- Name: teamwork_domains id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_domains ALTER COLUMN id SET DEFAULT nextval('public.teamwork_domains_id_seq'::regclass);


--
-- Name: teamwork_time_entries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_time_entries ALTER COLUMN id SET DEFAULT nextval('public.teamwork_time_entries_id_seq'::regclass);


--
-- Name: teamwork_user_config_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_user_config_sets ALTER COLUMN id SET DEFAULT nextval('public.teamwork_user_config_sets_id_seq'::regclass);


--
-- Name: user_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications ALTER COLUMN id SET DEFAULT nextval('public.user_notifications_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: entries entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entries
    ADD CONSTRAINT entries_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: teamwork_domains teamwork_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_domains
    ADD CONSTRAINT teamwork_domains_pkey PRIMARY KEY (id);


--
-- Name: teamwork_time_entries teamwork_time_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_time_entries
    ADD CONSTRAINT teamwork_time_entries_pkey PRIMARY KEY (id);


--
-- Name: teamwork_user_config_sets teamwork_user_config_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_user_config_sets
    ADD CONSTRAINT teamwork_user_config_sets_pkey PRIMARY KEY (id);


--
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);


--
-- Name: index_clients_on_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_clients_on_archived ON public.clients USING btree (archived);


--
-- Name: index_clients_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_clients_on_name ON public.clients USING btree (name);


--
-- Name: index_entries_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_project_id ON public.entries USING btree (project_id);


--
-- Name: index_entries_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entries_on_user_id ON public.entries USING btree (user_id);


--
-- Name: index_projects_on_archived; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_archived ON public.projects USING btree (archived);


--
-- Name: index_projects_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_client_id ON public.projects USING btree (client_id);


--
-- Name: index_projects_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_name ON public.projects USING btree (name);


--
-- Name: index_sessions_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_sessions_on_token ON public.sessions USING btree (token);


--
-- Name: index_sessions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sessions_on_user_id ON public.sessions USING btree (user_id);


--
-- Name: index_teamwork_domains_on_alias; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teamwork_domains_on_alias ON public.teamwork_domains USING btree (alias);


--
-- Name: index_teamwork_domains_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teamwork_domains_on_name ON public.teamwork_domains USING btree (name);


--
-- Name: index_teamwork_domains_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teamwork_domains_on_user_id ON public.teamwork_domains USING btree (user_id);


--
-- Name: index_teamwork_time_entries_on_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teamwork_time_entries_on_entry_id ON public.teamwork_time_entries USING btree (entry_id);


--
-- Name: index_teamwork_time_entries_on_teamwork_domain_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teamwork_time_entries_on_teamwork_domain_id ON public.teamwork_time_entries USING btree (teamwork_domain_id);


--
-- Name: index_teamwork_time_entries_on_time_entry_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teamwork_time_entries_on_time_entry_id ON public.teamwork_time_entries USING btree (time_entry_id);


--
-- Name: index_teamwork_user_config_sets_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_teamwork_user_config_sets_on_user_id ON public.teamwork_user_config_sets USING btree (user_id);


--
-- Name: index_user_notifications_on_resource_type_and_resource_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_resource_type_and_resource_id ON public.user_notifications USING btree (resource_type, resource_id);


--
-- Name: index_user_notifications_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_notifications_on_user_id ON public.user_notifications USING btree (user_id);


--
-- Name: teamwork_user_config_sets fk_rails_612d7a3808; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_user_config_sets
    ADD CONSTRAINT fk_rails_612d7a3808 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: teamwork_time_entries fk_rails_67ae1f1cc8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_time_entries
    ADD CONSTRAINT fk_rails_67ae1f1cc8 FOREIGN KEY (teamwork_domain_id) REFERENCES public.teamwork_domains(id);


--
-- Name: teamwork_domains fk_rails_bc7b33937e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teamwork_domains
    ADD CONSTRAINT fk_rails_bc7b33937e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_notifications fk_rails_cdbff2ee9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT fk_rails_cdbff2ee9e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20161125100824'),
('20161125131803'),
('20161125152803'),
('20161202092117'),
('20161215211334'),
('20161215211445'),
('20161216111431'),
('20161219095225'),
('20170126155219'),
('20220310151000'),
('20220310151652'),
('20220313093405'),
('20220314134033'),
('20220316174726'),
('20220321094812'),
('20220323133241');



-- public api used in developer dash, user dash,
-- uses JWT token for authentication, role "user"
CREATE SCHEMA IF NOT EXISTS api;
-- public api used in admin
-- uses JWT token for authentication, role "admin"
CREATE SCHEMA IF NOT EXISTS api_admin_v1;
-- public api used in course api
-- uses API key for authentication, role "anonymous"
CREATE SCHEMA IF NOT EXISTS api_developer_v1;
CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS api_keys;
CREATE SCHEMA IF NOT EXISTS jwt;
CREATE SCHEMA IF NOT EXISTS triggers;
CREATE SCHEMA IF NOT EXISTS settings;
CREATE SCHEMA IF NOT EXISTS subsets;
CREATE SCHEMA IF NOT EXISTS bi;
CREATE SCHEMA IF NOT EXISTS transliterate;

-- pgFormatter-ignore
CREATE EXTENSION IF NOT EXISTS citext      WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plpgsql     WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS pgcrypto    WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS unaccent    WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS hstore      WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pg_trgm     WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plv8        WITH SCHEMA pg_catalog;

CREATE AGGREGATE array_accum (anyarray)
(
  sfunc = array_cat,
  stype = anyarray,
  initcond = '{}'
);

CREATE DOMAIN app.domain AS CITEXT;

ALTER DOMAIN app.domain ADD CONSTRAINT domain__must_be_a_domain CHECK ( value ~ '^([a-z0-9\-\_]+\.)+[a-z]+$' );

CREATE DOMAIN app.username AS CITEXT;

ALTER DOMAIN app.username ADD CONSTRAINT username__format CHECK (NOT(value ~* '[^0-9a-zA-Z\.\-\_]'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_dash CHECK (NOT(value ~* '--'));
ALTER DOMAIN app.username ADD CONSTRAINT username__consecutive_underline CHECK (NOT(value ~* '__'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_dash CHECK (NOT(value ~* '^-' OR value ~* '-$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__boundary_underline CHECK (NOT(value ~* '^_' OR value ~* '_$'));
ALTER DOMAIN app.username ADD CONSTRAINT username__length_upper CHECK (LENGTH(value) <= 15);
ALTER DOMAIN app.username ADD CONSTRAINT username__length_lower CHECK (LENGTH(value) >= 5);
ALTER DOMAIN app.username ADD CONSTRAINT username__lowercased CHECK (value = LOWER(value));

CREATE TYPE app.api_key_status AS ENUM (
  'enabled',
  'disabled',
  'blacklisted'
);

CREATE TYPE app.provider_created_by AS ENUM (
  'api',
  'system'
);

CREATE TYPE app.provider_logo AS (
  id uuid,
  provider_id uuid,
  file varchar,
  user_account_id bigint,
  created_at timestamptz,
  updated_at timestamptz,
  fetch_url text,
  upload_url text,
  file_content_type varchar
);

CREATE TYPE course_areas AS ENUM ('unclassified', 'tech', 'non-tech');

CREATE TYPE app.authority_confirmation_method AS ENUM (
  'dns',
  'html'
);

CREATE TYPE app.authority_confirmation_status AS ENUM (
  'unconfirmed',
  'confirming',
  'confirmed',
  'failed',
  'deleted',
  'canceled'
);

CREATE TYPE app.category AS ENUM (
  'arts_and_design',
  'business',
  'marketing',
  'computer_science',
  'data_science',
  'language_and_communication',
  'life_sciences',
  'math_and_logic',
  'personal_development',
  'physical_science_and_engineering',
  'social_science',
  'health_and_fitness',
  'social_sciences'
);

CREATE TYPE app.contact_reason AS ENUM (
  'customer_support',
  'bug_report',
  'feature_suggestion',
  'commercial_and_partnerships',
  'manual_profile_claim',
  'other'
);

CREATE TYPE app.crawler_status AS ENUM (
  'unverified', 'pending', 'broken', 'active', 'deleted'
);

CREATE TYPE app.iso639_1_alpha2_code AS ENUM (
  'aa',
  'ab',
  'ae',
  'af',
  'ak',
  'am',
  'an',
  'ar',
  'as',
  'av',
  'ay',
  'az',
  'ba',
  'be',
  'bg',
  'bh',
  'bi',
  'bm',
  'bn',
  'bo',
  'br',
  'bs',
  'ca',
  'ce',
  'ch',
  'co',
  'cr',
  'cs',
  'cu',
  'cv',
  'cy',
  'da',
  'de',
  'dv',
  'dz',
  'ee',
  'el',
  'en',
  'eo',
  'es',
  'et',
  'eu',
  'fa',
  'ff',
  'fi',
  'fj',
  'fo',
  'fr',
  'fy',
  'ga',
  'gd',
  'gl',
  'gn',
  'gu',
  'gv',
  'ha',
  'he',
  'hi',
  'ho',
  'hr',
  'ht',
  'hu',
  'hy',
  'hz',
  'ia',
  'id',
  'ie',
  'ig',
  'ii',
  'ik',
  'io',
  'is',
  'it',
  'iu',
  'ja',
  'jv',
  'ka',
  'kg',
  'ki',
  'kj',
  'kk',
  'kl',
  'km',
  'kn',
  'ko',
  'kr',
  'ks',
  'ku',
  'kv',
  'kw',
  'ky',
  'la',
  'lb',
  'lg',
  'li',
  'ln',
  'lo',
  'lt',
  'lu',
  'lv',
  'mg',
  'mh',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'na',
  'nb',
  'nd',
  'ne',
  'ng',
  'nl',
  'nn',
  'no',
  'nr',
  'nv',
  'ny',
  'oc',
  'oj',
  'om',
  'or',
  'os',
  'pa',
  'pi',
  'pl',
  'ps',
  'pt',
  'qu',
  'rm',
  'rn',
  'ro',
  'ru',
  'rw',
  'sa',
  'sc',
  'sd',
  'se',
  'sg',
  'si',
  'sk',
  'sl',
  'sm',
  'sn',
  'so',
  'sq',
  'sr',
  'ss',
  'st',
  'su',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'ti',
  'tk',
  'tl',
  'tn',
  'to',
  'tr',
  'ts',
  'tt',
  'tw',
  'ty',
  'ug',
  'uk',
  'ur',
  'uz',
  've',
  'vi',
  'vo',
  'wa',
  'wo',
  'xh',
  'yi',
  'yo',
  'za',
  'zh',
  'zu'
);

CREATE TYPE app.iso639_code AS ENUM (
  'ar-EG',
  'ar-JO',
  'ar-LB',
  'ar-SY',
  'de-DE',
  'en-AU',
  'en-BZ',
  'en-CA',
  'en-GB',
  'en-IN',
  'en-NZ',
  'en-US',
  'en-ZA',
  'es-AR',
  'es-BO',
  'es-CL',
  'es-CO',
  'es-EC',
  'es-ES',
  'es-GT',
  'es-MX',
  'es-PE',
  'es-VE',
  'fr-BE',
  'fr-CH',
  'fr-FR',
  'it-IT',
  'jp-JP',
  'nl-BE',
  'nl-NL',
  'pl-PL',
  'pt-BR',
  'pt-PT',
  'sv-SV',
  'zh-CN',
  'zh-CMN',
  'zh-HANS',
  'zh-HANT',
  'zh-TW',
  'af',
  'am',
  'ar',
  'az',
  'be',
  'bg',
  'bn',
  'bo',
  'bs',
  'ca',
  'co',
  'cs',
  'cy',
  'da',
  'de',
  'el',
  'en',
  'eo',
  'es',
  'et',
  'eu',
  'fa',
  'fi',
  'fil',
  'fr',
  'fy',
  'ga',
  'gd',
  'gl',
  'gu',
  'ha',
  'he',
  'hi',
  'hr',
  'ht',
  'hu',
  'hy',
  'id',
  'ig',
  'is',
  'it',
  'iw',
  'ja',
  'jp',
  'ka',
  'kk',
  'km',
  'kn',
  'ko',
  'ku',
  'ky',
  'lb',
  'lo',
  'lt',
  'lv',
  'mg',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'nb',
  'ne',
  'nl',
  'no',
  'pa',
  'pl',
  'ps',
  'pt',
  'ro',
  'ru',
  'rw',
  'sd',
  'si',
  'sk',
  'sl',
  'sn',
  'so',
  'sq',
  'sr',
  'st',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'tl',
  'tr',
  'tt',
  'uk',
  'ur',
  'uz',
  'vi',
  'xh',
  'yi',
  'yo',
  'zh',
  'zu'
);

CREATE TYPE app.iso3166_1_alpha2_code AS ENUM (
  'AD','AE','AF','AG','AI','AL','AM','AO','AQ','AR','AS','AT','AU','AW','AX','AZ','BA','BB','BD','BE','BF','BG','BH','BI','BJ','BL','BM','BN','BO','BQ','BR','BS','BT','BV','BW','BY','BZ','CA','CC','CD','CF','CG','CH','CI','CK','CL','CM','CN','CO','CR','CU','CV','CW','CX','CY','CZ','DE','DJ','DK','DM','DO','DZ','EC','EE','EG','EH','ER','ES','ET','FI','FJ','FK','FM','FO','FR','GA','GB','GD','GE','GF','GG','GH','GI','GL','GM','GN','GP','GQ','GR','GS','GT','GU','GW','GY','HK','HM','HN','HR','HT','HU','ID','IE','IL','IM','IN','IO','IQ','IR','IS','IT','JE','JM','JO','JP','KE','KG','KH','KI','KM','KN','KP','KR','KW','KY','KZ','LA','LB','LC','LI','LK','LR','LS','LT','LU','LV','LY','MA','MC','MD','ME','MF','MG','MH','MK','ML','MM','MN','MO','MP','MQ','MR','MS','MT','MU','MV','MW','MX','MY','MZ','NA','NC','NE','NF','NG','NI','NL','NO','NP','NR','NU','NZ','OM','PA','PE','PF','PG','PH','PK','PL','PM','PN','PR','PS','PT','PW','PY','QA','RE','RO','RS','RU','RW','SA','SB','SC','SD','SE','SG','SH','SI','SJ','SK','SL','SM','SN','SO','SR','SS','ST','SV','SX','SY','SZ','TC','TD','TF','TG','TH','TJ','TK','TL','TM','TN','TO','TR','TT','TV','TW','TZ','UA','UG','UM','US','UY','UZ','VA','VC','VE','VG','VI','VN','VU','WF','WS','XK','YE','YT','ZA','ZM','ZW'
);

CREATE TYPE app.iso4217_code AS ENUM (
  'AED','AFN','ALL','AMD','ANG','AOA','ARS','AUD','AWG','AZN','BAM','BBD','BDT','BGN','BHD','BIF','BMD','BND','BOB','BOV','BRL','BSD','BTN','BWP','BYN','BZD','CAD','CDF','CHE','CHF','CHW','CLF','CLP','CNY','COP','COU','CRC','CUC','CUP','CVE','CZK','DJF','DKK','DOP','DZD','EGP','ERN','ETB','EUR','FJD','FKP','GBP','GEL','GHS','GIP','GMD','GNF','GTQ','GYD','HKD','HNL','HRK','HTG','HUF','IDR','ILS','INR','IQD','IRR','ISK','JMD','JOD','JPY','KES','KGS','KHR','KMF','KPW','KRW','KWD','KYD','KZT','LAK','LBP','LKR','LRD','LSL','LYD','MAD','MDL','MGA','MKD','MMK','MNT','MOP','MRU','MUR','MVR','MWK','MXN','MXV','MYR','MZN','NAD','NGN','NIO','NOK','NPR','NZD','OMR','PAB','PEN','PGK','PHP','PKR','PLN','PYG','QAR','RON','RSD','RUB','RWF','SAR','SBD','SCR','SDG','SEK','SGD','SHP','SLL','SOS','SRD','SSP','STN','SVC','SYP','SZL','THB','TJS','TMT','TND','TOP','TRY','TTD','TWD','TZS','UAH','UGX','USD','USN','UYI','UYU','UYW','UZS','VES','VND','VUV','WST','XAF','XAG','XAU','XBA','XBB','XBC','XBD','XCD','XDR','XOF','XPD','XPF','XPT','XSU','XTS','XUA','XXX','YER','ZAR','ZMW','ZWL'
);

CREATE TYPE app.level AS ENUM (
  'beginner',
  'intermediate',
  'advanced'
);

CREATE TYPE app.locale AS (
  language  app.iso639_1_alpha2_code,
  country   app.iso3166_1_alpha2_code
);

CREATE TYPE app.locale_status AS ENUM (
  'empty_audio',
  'manually_overriden',
  'mismatch',
  'multiple_countries',
  'multiple_languages',
  'not_identifiable',
  'ok'
);

CREATE TYPE app.pace AS ENUM (
  'self_paced',
  'instructor_paced',
  'live_class'
);

CREATE TYPE app.payment_source AS ENUM (
  'impact_radius',
  'awin',
  'rakuten',
  'share_a_sale',
  'commission_junction',
  'zanox'
);

CREATE TYPE app.payment_status AS ENUM (
  'open',
  'locked',
  'paid'
);

CREATE TYPE app.period_unit AS ENUM (
  'unknown', 'minutes', 'hours', 'days', 'weeks', 'months', 'years', 'lessons'
);

CREATE TYPE app.post_status AS ENUM (
  'void',
  'draft',
  'published',
  'disabled'
);

CREATE TYPE app.preview_course_status AS ENUM (
  'pending', 'failed', 'succeeded'
);

CREATE TYPE app.pricing AS ENUM (
  'single_course', 'subscription'
);

CREATE TYPE app.pricing_customer AS ENUM (
  'unknown', 'individual', 'enterprise'
);

CREATE TYPE app.pricing_plan AS ENUM (
  'regular', 'premium'
);

CREATE TYPE app.provider_ownership_creation_status AS ENUM (
  'initial',
  'pending',
  'succeeded',
  'failed'
);

CREATE TYPE app.sitemap AS (
  id     uuid,
  status varchar,
  url    varchar,
  type   varchar
);

CREATE TYPE app.source AS ENUM (
  'api',
  'import',
  'admin'
);

CREATE TYPE app.organization_type AS ENUM (
  'university',
  'provider',
  'company',
  'school',
  'ngo',
  'other'
);

CREATE TYPE app.offeror_type AS ENUM (
  'organization',
  'instructor'
);

CREATE TYPE app.offered_role AS ENUM (
  'owner',
  'reference'
);

CREATE TYPE app.redeem_status AS ENUM (
  'under_analysis',
  'rejected',
  'approved'
);

CREATE TYPE app.review_state AS ENUM (
  'pending',
  'draft',
  'submitted',
  'approved',
  'rejected'
);

CREATE TYPE app.wallet_transaction_status AS ENUM (
  'locked',
  'canceled',
  'settled'
);

CREATE TYPE app.suspension_reason AS ENUM (
  'dmca_takedown',
  'tos_infringment',
  'provider_error',
  'other'
);

-- Meta resources:
-- tables
-- table_templates
-- table_custom_fields
-- custom_fields
-- custom_actions

-- Meta resources are not only used to define other resources, but also to define how to handle themselves
CREATE TYPE api_admin_v1.resource AS ENUM (
  'tables',
  'table_templates',
  'custom_fields',
  'custom_actions',
  'tables_custom_fields',
  'tables_custom_actions',
  'admin_accounts',
  'contacts',
  'user_accounts',
  'posts',
  'promotions',
  'instructors',
  'tracked_actions',
  'enrollments',
  'providers',
  'courses',
  'topics'
);

CREATE TABLE settings.secrets (
  key   varchar PRIMARY KEY,
  value varchar
);

CREATE TABLE settings.global (
  id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  subdomains app.locale[],
  minimum_redeemable_amount numeric
);

CREATE TABLE app.user_accounts (
  id                      bigserial    PRIMARY KEY,
  email                   varchar      DEFAULT ''::varchar NOT NULL,
  encrypted_password      varchar      DEFAULT ''::varchar NOT NULL,
  reset_password_token    varchar,
  reset_password_sent_at  timestamptz,
  remember_created_at     timestamptz,
  sign_in_count           integer      DEFAULT 0           NOT NULL,
  current_sign_in_at      timestamptz,
  last_sign_in_at         timestamptz,
  current_sign_in_ip      inet,
  last_sign_in_ip         inet,
  tracking_data           json         DEFAULT '{}'::json,
  confirmation_token      varchar,
  confirmed_at            timestamptz,
  confirmation_sent_at    timestamptz,
  unconfirmed_email       varchar,
  failed_attempts         integer      DEFAULT 0           NOT NULL,
  unlock_token            varchar,
  locked_at               timestamptz,
  destroyed_at            timestamptz,
  autogen_email_for_oauth boolean DEFAULT false NOT NULL,
  created_at              timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz  DEFAULT NOW()       NOT NULL
);

CREATE TABLE app.admin_accounts (
  id                     bigserial    PRIMARY KEY,
  email                  varchar      DEFAULT ''::varchar NOT NULL,
  encrypted_password     varchar      DEFAULT ''::varchar NOT NULL,
  reset_password_token   varchar,
  reset_password_sent_at timestamptz,
  remember_created_at    timestamptz,
  sign_in_count          integer      DEFAULT 0           NOT NULL,
  current_sign_in_at     timestamptz,
  last_sign_in_at        timestamptz,
  current_sign_in_ip     inet,
  last_sign_in_ip        inet,
  confirmation_token     varchar,
  confirmed_at           timestamptz,
  confirmation_sent_at   timestamptz,
  unconfirmed_email      varchar,
  failed_attempts        integer      DEFAULT 0           NOT NULL,
  unlock_token           varchar,
  locked_at              timestamptz,
  created_at             timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at             timestamptz  DEFAULT NOW()       NOT NULL,
  preferences            jsonb        DEFAULT '{}'::jsonb
);

CREATE TABLE app.admin_profiles (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name              varchar,
  bio               text,
  social_profiles   jsonb       DEFAULT '{}'::jsonb,
  preferences       jsonb,
  admin_account_id  bigint      REFERENCES app.admin_accounts(id) ON DELETE CASCADE,
  created_at        timestamptz DEFAULT NOW() NOT NULL,
  updated_at        timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.api_keys (
  prefix                  varchar       PRIMARY KEY,
  encrypted_secret        varchar       NOT NULL,
  user_account_id         bigint        REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  status                  app.api_key_status,
  created_at              timestamptz   DEFAULT NOW()         NOT NULL,
  updated_at              timestamptz   DEFAULT NOW()         NOT NULL
);

CREATE TABLE app.cached_nlped_queries (
  id         uuid   DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  query      citext NOT NULL CHECK (LENGTH(query) > 0),
  nlp        jsonb  DEFAULT '{}',
  lang       varchar(5),
  lang_score decimal(5,4) DEFAULT 0.0000
);

CREATE TABLE app.certificates (
  id              uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id bigint      REFERENCES app.user_accounts(id),
  file            varchar     CONSTRAINT valid_file_format CHECK ( lower(file) ~ '.(gif|jpg|jpeg|png|pdf)$' ),
  created_at      timestamptz DEFAULT NOW() NOT NULL,
  updated_at      timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.contacts (
  id         bigserial   PRIMARY KEY,
  name       varchar,
  email      varchar,
  subject    varchar,
  reason     app.contact_reason,
  message    text,
  created_at timestamptz DEFAULT NOW() NOT NULL,
  updated_at timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.domain_ownership_verifications (
  id                            uuid                              DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  user_account_id               bigint                            REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  authority_confirmation_status app.authority_confirmation_status DEFAULT    'unconfirmed' NOT NULL,
  authority_confirmation_token  varchar,
  authority_confirmation_method app.authority_confirmation_method DEFAULT    'dns'         NOT NULL,
  created_at                    timestamptz                       DEFAULT    NOW()         NOT NULL,
  updated_at                    timestamptz                       DEFAULT    NOW()         NOT NULL,
  domain                        app.domain                        NOT NULL,
  authority_confirmation_salt   varchar,
  run_count                     bigint                            DEFAULT 0
);

CREATE TABLE app.domain_ownerships (
  id                               uuid                              DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  user_account_id                  bigint                            REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  domain_ownership_verification_id uuid                              REFERENCES app.domain_ownership_verifications(id) ON DELETE CASCADE,
  authority_confirmation_method    app.authority_confirmation_method DEFAULT    'dns'         NOT NULL,
  created_at                       timestamptz                       DEFAULT    NOW()         NOT NULL,
  updated_at                       timestamptz                       DEFAULT    NOW()         NOT NULL,
  domain                           app.domain                                                 NOT NULL
);

CREATE TABLE app.domain_ownership_verification_logs (
  id                               bigserial    PRIMARY KEY,
  user_account_id                  bigint       REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  domain_ownership_verification_id uuid         REFERENCES app.domain_ownerships(id) ON DELETE CASCADE,
  log                              varchar,
  created_at                       timestamptz  DEFAULT NOW() NOT NULL
);

-- pgFormatter-ignore
CREATE TABLE app.providers (
  id                             uuid         DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  old_id                         bigserial,
  name                           public.citext,
  name_dirty                     boolean      DEFAULT true NOT NULL,
  name_changed_at                timestamptz  CHECK ((name_dirty) OR (NOT name_dirty AND name_changed_at IS NOT NULL)),
  description                    text,
  slug                           varchar,
  url                            varchar,
  domain                         app.domain,
  afn_url_template               varchar,
  published                      boolean      DEFAULT false,
  published_at                   timestamptz,
  created_at                     timestamptz  DEFAULT NOW() NOT NULL,
  created_by                     app.provider_created_by DEFAULT  'system'::app.provider_created_by NOT NULL,
  updated_at                     timestamptz  DEFAULT NOW() NOT NULL,
  encoded_deep_linking           boolean      DEFAULT false,
  featured_on_footer             boolean      DEFAULT false,
  featured_on_search             boolean      DEFAULT false,
  search_boost                   integer      DEFAULT 1,
  robots_doindex                 boolean                DEFAULT false,
  robots_doindex_for_locales     app.locale[]           DEFAULT '{}'::app.locale[],
  canonical_subdomain            varchar(5),
  earnable_coins                 numeric                DEFAULT 0,
  constraint                     earnable_coins_nonnegative check (earnable_coins >= 0)
);

CREATE TABLE app.provider_ownerships (
  id                  uuid               DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  user_account_id     bigint             REFERENCES app.user_accounts(id)     ON DELETE CASCADE,
  provider_id         uuid               REFERENCES app.providers(id)         ON DELETE CASCADE,
  domain_ownership_id uuid               REFERENCES app.domain_ownerships(id) ON DELETE CASCADE
);

CREATE TABLE app.provider_ownership_creations (
  id                            uuid                                   DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  user_account_id               bigint                                 REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  status                        app.provider_ownership_creation_status DEFAULT    'initial'::app.provider_ownership_creation_status NOT NULL,
  created_at                    timestamptz                            DEFAULT    NOW()         NOT NULL,
  updated_at                    timestamptz                            DEFAULT    NOW()         NOT NULL,
  domain                        app.domain                             NOT NULL,
  run_count                     bigint                                 DEFAULT 0
);

-- pgFormatter-ignore
CREATE TABLE app.courses (
  id                                      uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  global_sequence                         integer,
  name                                    varchar,
  description                             text,
  slug                                    varchar,
  url                                     varchar,
  url_md5                                 varchar,
  duration_in_hours                       numeric,
  price                                   numeric,
  rating                                  numeric,
  relevance                               integer                 DEFAULT 0,
  region                                  varchar,
  audio                                   text[]                  DEFAULT '{}',
  subtitles_text                          text[]                  DEFAULT '{}',
  published                               boolean                 DEFAULT true,
  stale                                   boolean                 DEFAULT false,
  category                                app.category,
  provider_id                             uuid                    REFERENCES app.providers(id),
  created_at                              timestamptz             DEFAULT NOW() NOT NULL,
  updated_at                              timestamptz             DEFAULT NOW() NOT NULL,
  dataset_sequence                        integer,
  resource_sequence                       integer,
  provider_tags                           text[]                  DEFAULT '{}',
  video                                   jsonb,
  source                                  app.source              DEFAULT 'api',
  pace                                    app.pace,
  earnable_coins                          smallint,
  certificate                             jsonb                   DEFAULT '{}',
  offered_by                              jsonb                   DEFAULT '[]',
  syllabus                                text,
  effort                                  integer,
  enrollments_count                       integer                 DEFAULT 0,
  free_content                            boolean                 DEFAULT false,
  paid_content                            boolean                 DEFAULT true,
  level                                   app.level[]             DEFAULT '{}',
  __provider_name__                       varchar,
  __source_schema__                       jsonb,
  instructors                             jsonb                   DEFAULT '[]',
  old_curated_tags                        varchar[]               DEFAULT '{}',
  refinement_tags                         varchar[],
  up_to_date_id                           uuid                    REFERENCES app.courses(id) ON DELETE SET NULL,
  last_execution_id                       uuid,
  last_fetched_at                         timestamptz,
  schema_version                          varchar,
  locale                                  app.locale,
  locale_status                           app.locale_status,
  canonical_subdomain                     varchar,
  subtitles                               app.locale[]            DEFAULT '{}'::app.locale[],
  canonical_id                            uuid                    REFERENCES app.courses(id) ON DELETE SET NULL,
  overwritten_fields                      hstore                  DEFAULT '' NOT NULL,
  robots_doindex                          boolean                 DEFAULT false,
  robots_doindex_for_locales              app.locale[]            DEFAULT '{}'::app.locale[],
  suspended                               boolean                 DEFAULT false,
  suspension_reason                       app.suspension_reason,
  extra                                   jsonb                   DEFAULT '{}',
  provider_rating                         jsonb                   DEFAULT '{}',
  constraint                              earnable_coins_nonnegative check (earnable_coins >= 0),
  area                                    course_areas            DEFAULT 'unclassified'
);

CREATE TABLE app.course_pricings (
  id                         uuid                  PRIMARY KEY DEFAULT public.uuid_generate_v4(),
  course_id                  uuid                  REFERENCES app.courses(id) ON DELETE CASCADE,
  pricing_type               app.pricing           NOT NULL,
  plan_type                  app.pricing_plan      NOT NULL DEFAULT 'regular',
  customer_type              app.pricing_customer           DEFAULT 'individual',
  price                      decimal(13,2)          NOT NULL,
  total_price                decimal(13,2),
  original_price             decimal(13,2),
  discount                   decimal(13,2),
  currency                   app.iso4217_code      NOT NULL,
  payment_period_unit        app.period_unit,
  payment_period_value       integer,
  trial_period_unit          app.period_unit,
  trial_period_value         integer,
  subscription_period_unit   app.period_unit,
  subscription_period_value  integer,
  created_at                 timestamptz           NOT NULL DEFAULT NOW(),
  updated_at                 timestamptz           NOT NULL DEFAULT NOW()
);

CREATE TABLE app.curated_search_terms (
  query         public.citext PRIMARY KEY,
  entries       integer DEFAULT 0,
  lang          varchar(5),
  score         decimal(4,3) DEFAULT 0,
  visible       boolean DEFAULT true,
  priority      integer DEFAULT 0
);

-- pgFormatter-ignore
CREATE TABLE app.currency_conversions (
  currency          varchar         PRIMARY KEY,
  value_in_usd      numeric(13,7)   NOT NULL CHECK (value_in_usd > 0),
  created_at        timestamptz     DEFAULT NOW() NOT NULL,
  updated_at        timestamptz     DEFAULT NOW() NOT NULL
);

CREATE TABLE app.enrollments (
  id                uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id   bigint      REFERENCES app.user_accounts(id),
  course_id         uuid        REFERENCES app.courses(id),
  provider_id       uuid        REFERENCES app.providers(id),
  tracked_url       varchar,
  description       text,
  user_rating       numeric,
  tracking_data     jsonb       DEFAULT '{}'::jsonb,
  tracking_cookies  jsonb       DEFAULT '{}'::jsonb,
  earnable_coins    smallint,
  marked_as_destroyed_at timestamptz,
  created_at        timestamptz DEFAULT NOW() NOT NULL,
  updated_at        timestamptz DEFAULT NOW() NOT NULL,
  constraint        earnable_coins_nonnegative check (earnable_coins >= 0)
);

CREATE TABLE app.tracked_actions (
  id               uuid                DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  enrollment_id    uuid                REFERENCES app.enrollments(id),
  status           app.payment_status,
  source           app.payment_source,
  created_at       timestamptz         DEFAULT NOW() NOT NULL,
  updated_at       timestamptz         DEFAULT NOW() NOT NULL,
  sale_amount      numeric,
  earnings_amount  numeric,
  payload          jsonb,
  compound_ext_id  varchar,
  ext_click_date   timestamptz,
  ext_id           varchar,
  ext_sku_id       varchar,
  ext_product_name varchar
);

CREATE TABLE app.course_reviews (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id   bigint REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  course_id         uuid REFERENCES app.courses(id) ON DELETE CASCADE,
  rating            numeric(1,0),
  completed         boolean DEFAULT false,
  publish_org       boolean DEFAULT false,
  feedback          varchar,
  state             varchar NOT NULL DEFAULT 'pending',
  created_at        timestamptz  DEFAULT NOW() NOT NULL,
  updated_at        timestamptz  DEFAULT NOW() NOT NULL,
  CONSTRAINT rating__greater_than CHECK (rating >= 1),
  CONSTRAINT rating__less_than CHECK (rating <= 5),
  CONSTRAINT state__inclusion CHECK (state IN ('pending','accessed','submitted'))
);

CREATE TABLE app.provider_crawlers (
  id               uuid               DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  user_agent_token uuid               DEFAULT    public.uuid_generate_v4() NOT NULL,
  provider_id      uuid               REFERENCES app.providers(id)         ON DELETE CASCADE,
  published        boolean            DEFAULT    false                     NOT NULL,
  scheduled        boolean            DEFAULT    false                     NOT NULL,
  created_at       timestamptz        DEFAULT    NOW()                     NOT NULL,
  updated_at       timestamptz        DEFAULT    NOW()                     NOT NULL,
  status           app.crawler_status DEFAULT    'unverified'              NOT NULL,
  user_account_ids bigint[]           DEFAULT    '{}'                      NOT NULL,
  sitemaps         app.sitemap[]      DEFAULT    '{}'                      NOT NULL,
  version          varchar,
  settings         jsonb,
  urls             varchar[]          DEFAULT    '{}'                      NOT NULL
);

CREATE TABLE app.crawler_domains (
  id                            uuid                              DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  provider_crawler_id           uuid                              REFERENCES app.provider_crawlers(id) ON DELETE CASCADE,
  authority_confirmation_status app.authority_confirmation_status DEFAULT    'unconfirmed'                               NOT NULL,
  authority_confirmation_token  varchar,
  authority_confirmation_method app.authority_confirmation_method DEFAULT    'dns'                                       NOT NULL,
  created_at                    timestamptz                       DEFAULT    NOW()                                       NOT NULL,
  updated_at                    timestamptz                       DEFAULT    NOW()                                       NOT NULL,
  domain                        varchar                                                                                  NOT NULL,
  authority_confirmation_salt   varchar

  CONSTRAINT domain__must_be_a_domain CHECK ( domain ~ '^([a-z0-9\-\_]+\.)+[a-z]+$' )
);

CREATE TABLE app.crawling_events (
  id                  uuid        DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  provider_crawler_id uuid        REFERENCES app.provider_crawlers(id) ON DELETE CASCADE,
  execution_id        uuid                                             NOT NULL,
  created_at          timestamptz DEFAULT    NOW()                     NOT NULL,
  updated_at          timestamptz DEFAULT    NOW()                     NOT NULL,
  sequence            bigint,
  type                varchar                                          NOT NULL,
  data                jsonb
);

CREATE TABLE app.direct_uploads (
  id              uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id bigint      REFERENCES app.user_accounts(id),
  file            varchar     CONSTRAINT valid_file_format CHECK ( LOWER(file) ~ '.(gif|jpg|jpeg|png|pdf|svg)$' ),
  created_at      timestamptz DEFAULT NOW() NOT NULL,
  updated_at      timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.favorites (
  id              bigserial   PRIMARY KEY,
  user_account_id bigint      REFERENCES app.user_accounts(id),
  course_id       uuid        REFERENCES app.courses(id),
  created_at      timestamptz DEFAULT NOW() NOT NULL,
  updated_at      timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.faqs (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  question          varchar NOT NULL,
  answer            text NOT NULL,
  created_at        timestamptz DEFAULT NOW() NOT NULL,
  updated_at        timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.faqables (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  faq_id            uuid REFERENCES app.faqs(id),
  faqed_id          uuid NOT NULL,
  faqed_type        varchar NOT NULL,
  position          integer DEFAULT 0
);

CREATE TABLE app.forums (
  id                  uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                text        NOT NULL,
  slug                text        NOT NULL,
  url                 text        NOT NULL,
  created_at          timestamptz DEFAULT NOW() NOT NULL,
  updated_at          timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.forum_posts (
  id                  uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  forum_id            uuid        REFERENCES app.forums(id)         ON DELETE CASCADE,
  external_id         text        NOT NULL,
  body                text        NOT NULL,
  url                 text,
  raw                 jsonb,
  created_at          timestamptz DEFAULT NOW() NOT NULL,
  updated_at          timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.forum_recommendations (
  id                  uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  forum_post_id       uuid        REFERENCES app.forum_posts(id)    ON DELETE CASCADE,
  course_id           uuid        REFERENCES app.courses(id)        ON DELETE CASCADE,
  created_at          timestamptz DEFAULT NOW() NOT NULL,
  updated_at          timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.images (
  id             uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  old_id         bigserial,
  caption        varchar,
  file           varchar,
  pos            integer     DEFAULT 0,
  imageable_type varchar,
  imageable_id   uuid,
  created_at     timestamptz DEFAULT NOW() NOT NULL,
  updated_at     timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.landing_pages (
  id            bigserial   PRIMARY KEY,
  slug          public.citext,
  template      varchar,
  meta_html     text,
  html          jsonb       DEFAULT '{}'::jsonb,
  body_html     text,
  created_at    timestamptz DEFAULT NOW() NOT NULL,
  updated_at    timestamptz DEFAULT NOW() NOT NULL,
  data          jsonb       DEFAULT '{}'::jsonb,
  erb_template  text,
  layout        varchar
);

CREATE TABLE app.oauth_accounts (
  id              bigserial   PRIMARY KEY,
  provider        varchar,
  uid             varchar,
  raw_data        jsonb       DEFAULT '{}'::jsonb NOT NULL,
  user_account_id bigint      REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  created_at      timestamptz DEFAULT NOW() NOT NULL,
  updated_at      timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.posts (
  id                              uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  slug                            varchar,
  title                           varchar,
  body                            text,
  description                     varchar(450),
  tags                            varchar[]       DEFAULT '{}'::varchar[],
  meta                            jsonb           DEFAULT '"{\"title\": \"\", \"description\": \"\"}"'::jsonb,
  locale                          app.iso639_code DEFAULT 'en'::app.iso639_code,
  status                          app.post_status DEFAULT 'draft'::app.post_status,
  content_digest                  varchar,
  content_changed_at              timestamptz,
  admin_account_id                bigint          REFERENCES app.admin_accounts(id),
  original_post_id                uuid            REFERENCES app.posts(id),
  cover_image_id                  uuid            REFERENCES app.images(id),
  show_affiliate_link_disclaimer  boolean         DEFAULT false,
  published_at                    timestamptz,
  created_at                      timestamptz     DEFAULT NOW() NOT NULL,
  updated_at                      timestamptz     DEFAULT NOW() NOT NULL
);

CREATE TABLE app.post_relations (
  id            uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  relation_type varchar NOT NULL,
  relation_id   uuid NOT NULL,
  post_id       uuid REFERENCES app.posts(id)
);

CREATE TABLE app.preview_courses (
  id                  uuid                      DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  status              app.preview_course_status DEFAULT    'pending',
  name                varchar,
  description         text,
  slug                varchar,
  url                 varchar       NOT NULL,
  url_md5             varchar,
  duration_in_hours   numeric,
  price               numeric,
  rating              numeric,
  relevance           integer       DEFAULT 0,
  region              varchar,
  audio               text[]        DEFAULT '{}'::text[],
  subtitles_text      text[]        DEFAULT '{}'::text[],
  subtitles           app.locale[]  DEFAULT '{}'::app.locale[],
  published           boolean       DEFAULT true,
  stale               boolean       DEFAULT false,
  category            app.category,
  tags                text[]        DEFAULT '{}'::text[],
  video               jsonb,
  source              app.source    DEFAULT 'api'::app.source,
  pace                app.pace,
  certificate         jsonb         DEFAULT '{}'::jsonb,
  offered_by          jsonb         DEFAULT '[]'::jsonb,
  syllabus            text,
  effort              integer,
  enrollments_count   integer       DEFAULT 0,
  free_content        boolean       DEFAULT false,
  paid_content        boolean       DEFAULT true,
  level               app.level[]   DEFAULT '{}'::app.level[],
  __provider_name__   varchar,
  __source_schema__   jsonb,
  __indexed_json__    jsonb,
  instructors         jsonb         DEFAULT '[]'::jsonb,
  curated_tags        varchar[]     DEFAULT '{}'::varchar[],
  refinement_tags     varchar[],
  provider_id         uuid          REFERENCES app.providers(id),
  provider_crawler_id uuid          REFERENCES app.provider_crawlers(id)     ON DELETE CASCADE,
  created_at          timestamptz   DEFAULT    NOW()                         NOT NULL,
  updated_at          timestamptz   DEFAULT    NOW()                         NOT NULL,
  expired_at          timestamptz   DEFAULT    NOW() + INTERVAL '20 MINUTES' NOT NULL
);

CREATE TABLE app.preview_course_images (
  id             uuid   DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
  kind           varchar,
  file           varchar,
  preview_course_id uuid REFERENCES app.preview_courses(id),
  created_at     timestamptz DEFAULT NOW() NOT NULL,
  updated_at     timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.preview_course_pricings (
  id                         uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  preview_course_id          uuid        REFERENCES app.preview_courses(id),
  pricing_type               app.pricing NOT NULL,
  plan_type                  app.pricing_plan NOT NULL,
  customer_type              app.pricing_customer,
  price                      decimal(13,2) NOT NULL,
  total_price                decimal(13,2),
  original_price             decimal(13,2),
  discount                   decimal(13,2),
  currency                   app.iso4217_code NOT NULL,
  payment_period_unit        app.period_unit,
  payment_period_value       integer,
  trial_period_unit          app.period_unit,
  trial_period_value         integer,
  subscription_period_unit   app.period_unit,
  subscription_period_value  integer,
  created_at                 timestamptz DEFAULT NOW() NOT NULL,
  updated_at                 timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.profiles (
  id                  uuid          DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                varchar,
  _name               varchar,
  username            app.username,
  _username           varchar       CONSTRAINT username__format CHECK (_username ~* '^\w{5,15}$'),
  username_changed_at timestamptz,
  date_of_birth       date,
  oauth_avatar_url    varchar,
  uploaded_avatar_url varchar,
  instructor          boolean     DEFAULT false,
  long_bio            varchar,
  public              boolean     DEFAULT true,
  website             varchar,
  country             app.iso3166_1_alpha2_code,
  course_ids          uuid[]      DEFAULT '{}'::uuid[],
  short_bio           varchar     CONSTRAINT short_bio__length CHECK (LENGTH(short_bio) <= 60),
  public_profiles     jsonb       DEFAULT '{}'::jsonb,
  social_profiles     jsonb       DEFAULT '{}'::jsonb,
  elearning_profiles  jsonb       DEFAULT '{}'::jsonb,
  teaching_subjects   varchar[]   DEFAULT '{}',
  user_account_id     bigint      REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  interests           text[]      DEFAULT '{}'::text[],
  preferences         jsonb       DEFAULT '{}'::jsonb,
  taken_surveys       varchar[]   DEFAULT '{}'::varchar[],
  created_at          timestamptz DEFAULT NOW() NOT NULL,
  updated_at          timestamptz DEFAULT NOW() NOT NULL
);

CREATE TABLE app.promotions (
  id                   uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  provider_id          uuid  REFERENCES app.providers(id),
  name                 varchar(100) NOT NULL,
  headline             varchar(500) NOT NULL,
  terms_and_conditions varchar NOT NULL,
  starts_at            timestamptz DEFAULT NOW() NOT NULL,
  ends_at              timestamptz NOT NULL,
  status               varchar DEFAULT 'initial',
  enabled_at           timestamptz,
  expired_at           timestamptz,
  disabled_at          timestamptz,
  awaiting_at          timestamptz,
  active_subdomains    app.locale[]   DEFAULT '{}'::app.locale[],
  required_params      jsonb DEFAULT '{}'::jsonb,
  created_at           timestamptz  DEFAULT NOW() NOT NULL,
  updated_at           timestamptz  DEFAULT NOW() NOT NULL
);

CREATE TABLE app.orphaned_profiles (
  id                             uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id                bigint                  REFERENCES app.user_accounts(id)     ON DELETE CASCADE,
  name                           varchar(75)   NOT NULL,
  country                        varchar(3),
  short_bio                      varchar(200),
  long_bio                       text,
  email                          varchar(320),
  website                        varchar,
  avatar_url                     varchar,
  public_profiles                jsonb                   DEFAULT '{}'::jsonb,
  languages                      varchar[]               DEFAULT '{}',
  course_ids                     uuid[]                  DEFAULT '{}',
  state                          varchar(20)             DEFAULT 'disabled',
  slug                           varchar,
  claimable_emails               varchar[]               DEFAULT '{}',
  claimable_public_profiles      jsonb                   DEFAULT '{}'::jsonb,
  claim_code                     varchar(64),
  claim_code_expires_at          timestamptz,
  claimed_at                     timestamptz,
  claimed_by                     varchar,
  teaching_subjects              varchar[]               DEFAULT '{}',
  teaching_at                    varchar[]               DEFAULT '{}',
  created_at                     timestamptz   NOT NULL  DEFAULT NOW(),
  updated_at                     timestamptz   NOT NULL  DEFAULT NOW(),
  marked_as_destroyed_at         timestamptz,
  robots_doindex                 boolean                 DEFAULT false,
  robots_doindex_for_locales     app.locale[]            DEFAULT '{}'::app.locale[],
  canonical_subdomain            varchar(5),
  CONSTRAINT                     state__inclusion CHECK (state IN ('disabled','enabled'))
);

CREATE TABLE app.used_usernames (
  id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  profile_id uuid REFERENCES app.profiles(id) ON DELETE CASCADE NOT NULL,
  username app.username NOT NULL
);

CREATE TABLE app.promo_accounts (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id   bigint REFERENCES app.user_accounts(id) ON DELETE CASCADE CONSTRAINT cntr_promo_accounts_user_account_id UNIQUE,
  certificate_id    uuid REFERENCES app.certificates(id) ON DELETE CASCADE,
  price             numeric(6,2) NOT NULL,
  purchase_date     date  NOT NULL CONSTRAINT purchase_date__less_than CHECK (purchase_date < NOW()),
  order_id          varchar NOT NULL,
  paypal_account    varchar NOT NULL,
  state             varchar NOT NULL DEFAULT 'initial',
  state_info        varchar,
  old_self          json NOT NULL default '{}'::json,
  created_at        timestamptz  DEFAULT NOW() NOT NULL,
  updated_at        timestamptz  DEFAULT NOW() NOT NULL,
  CONSTRAINT price__greater_than CHECK (price >= 0),
  CONSTRAINT price__less_than CHECK (price <= 5000),
  CONSTRAINT paypal_account__email CHECK (paypal_account ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'),
  CONSTRAINT state__inclusion CHECK (state IN ('initial','pending','locked','rejected','approved'))
);

CREATE TABLE app.promo_account_logs (
  id uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  promo_account_id uuid REFERENCES app.promo_accounts(id) ON DELETE CASCADE,
  old jsonb DEFAULT '{}'::jsonb,
  new jsonb DEFAULT '{}'::jsonb,
  role varchar NOT NULL
);

CREATE TABLE app.provider_logos (
  id               uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  direct_upload_id uuid REFERENCES app.direct_uploads(id) NOT NULL,
  provider_id      uuid REFERENCES app.providers(id) NOT NULL
);

CREATE TABLE app.reviews (
  id                uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id   bigint REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  reviewable_id     uuid NOT NULL,
  reviewable_type   varchar NOT NULL,
  rating            numeric(1,0),
  completed         boolean DEFAULT false,
  publish_org       boolean DEFAULT false,
  feedback          varchar,
  state             app.review_state NOT NULL DEFAULT 'pending'::app.review_state,
  created_at        timestamptz  DEFAULT NOW() NOT NULL,
  updated_at        timestamptz  DEFAULT NOW() NOT NULL,
  CONSTRAINT rating__greater_than CHECK (rating >= 1),
  CONSTRAINT rating__less_than CHECK (rating <= 5)
);

CREATE TABLE app.study_lists (
  id                uuid          DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name              varchar(100)  NOT NULL,
  slug              varchar       NOT NULL,
  description       text,
  standard          boolean       DEFAULT false,
  public            boolean       DEFAULT false,
  tags              varchar(60)[] DEFAULT '{}',
  user_account_id   bigint        REFERENCES app.user_accounts (id) ON DELETE CASCADE NOT NULL,
  created_at        timestamptz   DEFAULT NOW() NOT NULL,
  updated_at        timestamptz   DEFAULT NOW() NOT NULL,
  UNIQUE (name, user_account_id),
  UNIQUE (slug, user_account_id)
);

CREATE TABLE app.study_list_entries (
  id                                      uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  course_id                               uuid                    REFERENCES app.courses(id) ON DELETE CASCADE NOT NULL,
  study_list_id                           uuid                    REFERENCES app.study_lists(id) ON DELETE CASCADE NOT NULL,
  position                                integer,
  created_at                              timestamptz             DEFAULT NOW() NOT NULL,
  updated_at                              timestamptz             DEFAULT NOW() NOT NULL,
  UNIQUE(course_id, study_list_id)
);


CREATE TABLE app.slug_histories (
  id         uuid        DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  course_id  uuid        REFERENCES app.courses(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT NOW() NOT NULL,
  updated_at timestamptz DEFAULT NOW() NOT NULL,
  slug       varchar                   NOT NULL
);

CREATE TABLE app.subscriptions (
  id              uuid        DEFAULT public.uuid_generate_v4() UNIQUE NOT NULL PRIMARY KEY,
  digest          boolean     DEFAULT true NOT NULL,
  newsletter      boolean     DEFAULT true NOT NULL,
  promotions      boolean     DEFAULT true NOT NULL,
  recommendations boolean     DEFAULT true NOT NULL,
  reports         boolean     DEFAULT true NOT NULL,
  unsubscribe_reasons jsonb   DEFAULT '{}'::jsonb,
  unsubscribed_at timestamptz,
  profile_id      uuid        REFERENCES app.profiles(id),
  created_at      timestamptz  DEFAULT NOW() NOT NULL
);

-- pgFormatter-ignore

CREATE TABLE app.instructors (
  id                          uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  user_account_id             bigint                  REFERENCES app.user_accounts(id) ON DELETE CASCADE,
  provider_id                 uuid                    REFERENCES app.providers(id)     ON DELETE CASCADE,
  canonical_id                uuid                    REFERENCES app.instructors(id)   ON DELETE SET NULL,
  profile_id                  uuid                    REFERENCES app.profiles(id)      ON DELETE SET NULL,
  destroyed_at                timestamptz,
  distinguished               boolean                 DEFAULT FALSE,
  slug                        varchar,
  name                        varchar       NOT NULL,
  email                       varchar(320),
  website                     varchar,
  country                     varchar(3),
  short_bio                   varchar(200),
  long_bio                    text,
  avatar_url                  varchar,
  languages                   varchar[]               DEFAULT '{}',
  public_profiles             jsonb                   DEFAULT '{}',
  social_profiles             jsonb                   DEFAULT '{}'::jsonb,
  elearning_profiles          jsonb                   DEFAULT '{}'::jsonb,
  claimable_emails            varchar[]               DEFAULT '{}',
  claimable_public_profiles   jsonb                   DEFAULT '{}',
  claim_code                  varchar(64),
  claimed_by                  varchar,
  claim_code_expires_at       timestamptz,
  claimed_at                  timestamptz,
  created_at                  timestamptz   NOT NULL  DEFAULT NOW(),
  updated_at                  timestamptz   NOT NULL  DEFAULT NOW(),
  provider_salt_id            varchar,
  robots_doindex              boolean      DEFAULT false,
  robots_doindex_for_locales  app.locale[] DEFAULT '{}'::app.locale[],
  canonical_subdomain         varchar(5)
);

CREATE TABLE app.organizations (
  id                             uuid                  DEFAULT public.uuid_generate_v1() PRIMARY KEY,
  provider_id                    uuid                  REFERENCES app.providers(id)     ON DELETE CASCADE,
  canonical_id                   uuid                  REFERENCES app.organizations(id) ON DELETE SET NULL,
  enabled                        boolean               NOT NULL  DEFAULT FALSE,
  kind                           app.organization_type NOT NULL,
  slug                           varchar               NOT NULL,
  name                           varchar               NOT NULL,
  parent_ids                     uuid[]                NOT NULL  DEFAULT '{}',
  url                            varchar,
  created_at                     timestamptz           NOT NULL  DEFAULT NOW(),
  updated_at                     timestamptz           NOT NULL  DEFAULT NOW(),
  provider_salt_id               varchar,
  description                    text,
  robots_doindex                 boolean                DEFAULT false,
  robots_doindex_for_locales     app.locale[]           DEFAULT '{}'::app.locale[],
  canonical_subdomain            varchar(5)
);

CREATE TABLE app.ahoy_visits(
  id                 uuid          DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  visit_token        varchar(255)  NOT NULL,
  visitor_token      varchar(255)  NOT NULL,
  started_at         timestamptz,

  -- # user
  user_id            bigint        REFERENCES app.user_accounts(id),

  -- # standard
  ip                 varchar(255),
  user_agent         text,
  referrer           text,
  referring_domain   varchar(255),
  landing_page       text,

  -- # technology
  browser           varchar(255),
  os                varchar(255),
  device_type       varchar(255),

  -- # location
  country           varchar(255),
  region            varchar(255),
  city              text,
  latitude          numeric,
  longitude         numeric,

  -- # utm parameters
  utm_source         varchar(255),
  utm_medium         varchar(255),
  utm_term           varchar(255),
  utm_content        varchar(255),
  utm_campaign       varchar(255)
);

CREATE TABLE app.ahoy_events(
  id                 uuid         DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  visit_id           uuid         NOT NULL REFERENCES app.ahoy_visits(id),
  name               varchar(255),
  properties         jsonb,
  time               timestamptz
);

CREATE OR REPLACE FUNCTION app.validate_offered_by_offeror(
  _id   uuid,
  _type app.offeror_type
) RETURNS boolean AS $$
DECLARE
  result boolean;
BEGIN
  CASE _type
  WHEN 'organization' THEN
    SELECT EXISTS( SELECT 1 FROM app.organizations WHERE organizations.id = _id) INTO result;
  WHEN 'instructor' THEN
    SELECT EXISTS( SELECT 1 FROM app.instructors WHERE instructors.id = _id) INTO result;
  ELSE
    result = FALSE;
  END CASE;

  RETURN result;
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE TABLE app.offered_by (
  id           uuid DEFAULT public.uuid_generate_v1() PRIMARY KEY,
  course_id    uuid                                   REFERENCES app.courses(id) ON DELETE CASCADE,
  offeror_id   uuid,
  offeror_type app.offeror_type,
  role         app.offered_role,
  deleted_at   timestamptz,

  CONSTRAINT validate_offeror CHECK ( app.validate_offered_by_offeror(offeror_id, offeror_type) )
);

CREATE TABLE app.organization_members (
  id              uuid    DEFAULT public.uuid_generate_v1() PRIMARY KEY,
  organization_id uuid    REFERENCES app.organizations(id) ON DELETE CASCADE,
  user_account_id bigint  REFERENCES app.user_accounts(id) ON DELETE CASCADE
);

CREATE TABLE app.topics (
  id                                      uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                                    text,
  key                                     text                    DEFAULT '' NOT NULL,
  meta                                    jsonb,
  created_at                              timestamptz             DEFAULT NOW() NOT NULL,
  updated_at                              timestamptz             DEFAULT NOW() NOT NULL
);

-- pgFormatter-ignore
CREATE TABLE app.redeems (
  id                                      uuid                    DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  status                                  app.redeem_status       DEFAULT 'under_analysis',
  user_account_id                         bigint                  REFERENCES app.user_accounts(id) NOT NULL,
  created_at                              timestamptz             DEFAULT NOW() NOT NULL,
  updated_at                              timestamptz             DEFAULT NOW() NOT NULL
);

-- pgFormatter-ignore
CREATE TABLE app.wallets (
  id              uuid        DEFAULT public.uuid_generate_v4 () PRIMARY KEY,
  user_account_id bigint      REFERENCES app.user_accounts (id),
  paypal_account  varchar,
  created_at      timestamptz DEFAULT NOW() NOT NULL,
  updated_at      timestamptz DEFAULT NOW() NOT NULL,
  CONSTRAINT      paypal_account__email CHECK (paypal_account ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$')
);

CREATE TABLE app.wallet_transactions (
  id                                      uuid                          DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  wallet_id                               uuid                          REFERENCES app.wallets(id),
  amount                                  numeric,
  status                                  app.wallet_transaction_status DEFAULT 'locked',
  status_reason                           varchar(255),
  locked_until                            timestamptz                   NOT NULL,
  description                             varchar(255),
  transactionable_type                    varchar                       NOT NULL,
  transactionable_id                      uuid                          NOT NULL,
  created_at                              timestamptz                   DEFAULT NOW() NOT NULL,
  updated_at                              timestamptz                   DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.ar_internal_metadata (
  key        varchar     PRIMARY KEY,
  value      varchar,
  created_at timestamptz DEFAULT NOW() NOT NULL,
  updated_at timestamptz DEFAULT NOW() NOT NULL
);

CREATE FUNCTION public.que_validate_tags(tags_array jsonb) RETURNS boolean
    LANGUAGE sql
    AS $$
  SELECT bool_and(
    jsonb_typeof(value) = 'string'
    AND
    char_length(value::text) <= 100
  )
  FROM jsonb_array_elements(tags_array)
$$;

CREATE TABLE public.que_jobs (
  id                   BIGSERIAL    PRIMARY KEY,

  priority             smallint     DEFAULT 100 NOT NULL,
  run_at               timestamptz  DEFAULT NOW() NOT NULL,
  job_class            text         NOT NULL,
  error_count          integer      DEFAULT 0 NOT NULL,
  last_error_message   text,
  queue                text         DEFAULT 'default'::text NOT NULL,
  last_error_backtrace text,
  finished_at          timestamptz,
  expired_at           timestamptz,
  args                 jsonb        DEFAULT '[]'::jsonb NOT NULL,
  data                 jsonb        DEFAULT '{}'::jsonb NOT NULL,

  CONSTRAINT error_length
  CHECK (((char_length(last_error_message) <= 500) AND (char_length(last_error_backtrace) <= 10000))),

  CONSTRAINT job_class_length
  CHECK ((char_length(
CASE job_class
  WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'::text THEN ((args -> 0) ->> 'job_class'::text)
  ELSE job_class
END) <= 200)),

  CONSTRAINT queue_length
  CHECK ((char_length(queue) <= 100)),

  CONSTRAINT valid_args
  CHECK ((jsonb_typeof(args) = 'array'::text)),

  CONSTRAINT valid_data
  CHECK (((jsonb_typeof(data) = 'object'::text) AND ((NOT (data ? 'tags'::text)) OR ((jsonb_typeof((data -> 'tags'::text)) = 'array'::text) AND (jsonb_array_length((data -> 'tags'::text)) <= 5) AND public.que_validate_tags((data -> 'tags'::text))))))
)
WITH (fillfactor='90');

-- Required for migration? Maybe....
COMMENT ON TABLE public.que_jobs IS '4';

CREATE UNLOGGED TABLE public.que_lockers (
  pid               int     PRIMARY KEY,
  worker_count      int     NOT NULL,
  worker_priorities int[]   NOT NULL,
  ruby_pid          int     NOT NULL,
  ruby_hostname     text    NOT NULL,
  queues            text[]  NOT NULL,
  listening         boolean NOT NULL,

  CONSTRAINT valid_queues
  CHECK (((array_ndims(queues) = 1) AND (array_length(queues, 1) IS NOT NULL))),

  CONSTRAINT valid_worker_priorities
  CHECK (((array_ndims(worker_priorities) = 1) AND (array_length(worker_priorities, 1) IS NOT NULL)))
);

CREATE TABLE public.que_values (
  key   text  PRIMARY KEY,
  value jsonb DEFAULT '{}'::jsonb NOT NULL,

  CONSTRAINT valid_value
  CHECK ((jsonb_typeof(value) = 'object'::text))
)
WITH (fillfactor='90');

CREATE TABLE IF NOT EXISTS public.schema_migrations (
  version varchar PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS transliterate.symbols
(
  original        varchar PRIMARY KEY,
  transliteration varchar
);

CREATE TABLE api_admin_v1.custom_fields (
  id                     uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                   varchar(255) NOT NULL,
  alias                  varchar(255),
  description            varchar(90),
  data_type              varchar NOT NULL,
  jst                    text,
  admin_account_id       bigint REFERENCES app.admin_accounts(id),
  created_at             timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at             timestamptz  DEFAULT NOW()       NOT NULL
);


CREATE TABLE api_admin_v1.custom_actions (
  id                     uuid DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                   varchar(255) NOT NULL,
  description            varchar(90),
  jsf                    text,
  admin_account_id       bigint REFERENCES app.admin_accounts(id),
  created_at             timestamptz  DEFAULT NOW()       NOT NULL,
  updated_at             timestamptz  DEFAULT NOW()       NOT NULL
);

CREATE TABLE api_admin_v1.tables (
  id                      uuid                      DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  resource                api_admin_v1.resource     NOT NULL,
  name                    varchar(60)               NOT NULL UNIQUE,
  description             varchar(90),
  system                  boolean                   DEFAULT false,
  admin_account_id        bigint                    REFERENCES app.admin_accounts(id),
  created_at              timestamptz               DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz               DEFAULT NOW()       NOT NULL
);

CREATE TABLE api_admin_v1.table_templates (
  id                     uuid               DEFAULT public.uuid_generate_v4() PRIMARY KEY,
  name                   varchar(60)        NOT NULL UNIQUE,
  table_id               uuid               REFERENCES api_admin_v1.tables(id),
  description            varchar(90),
  schema                 varchar            DEFAULT 'api_admin_v1'::varchar NOT NULL,
  default_select         varchar            DEFAULT ''::varchar,
  default_order          varchar            DEFAULT ''::varchar,
  default_filters        jsonb              DEFAULT '{}'::jsonb,
  default_fields         jsonb              NOT NULL,
  admin_account_id       bigint             REFERENCES app.admin_accounts(id),
  created_at             timestamptz        DEFAULT NOW()       NOT NULL,
  updated_at             timestamptz        DEFAULT NOW()       NOT NULL
);

CREATE TABLE api_admin_v1.tables_custom_actions (
  table_id                uuid          REFERENCES api_admin_v1.tables(id),
  custom_action_id        uuid          REFERENCES api_admin_v1.custom_actions(id),
  admin_account_id        bigint        REFERENCES app.admin_accounts(id),
  created_at              timestamptz   DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz   DEFAULT NOW()       NOT NULL
);

CREATE TABLE api_admin_v1.tables_custom_fields (
  table_id                uuid          REFERENCES api_admin_v1.tables(id),
  custom_field_id         uuid          REFERENCES api_admin_v1.custom_fields(id),
  admin_account_id        bigint        REFERENCES app.admin_accounts(id),
  created_at              timestamptz   DEFAULT NOW()       NOT NULL,
  updated_at              timestamptz   DEFAULT NOW()       NOT NULL
);

CREATE OR REPLACE FUNCTION transliterate.to_ascii(
  _text varchar
) RETURNS varchar AS $$
DECLARE
  r record;
BEGIN
  FOR r IN SELECT original, transliteration FROM transliterate.symbols WHERE original IN (
    SELECT chr
      FROM (
        SELECT unnest(regexp_split_to_array(_text, '')) AS chr
      ) x
     WHERE x.chr NOT SIMILAR TO '[a-zA-Z1-9]'
     GROUP BY x.chr
  )
  LOOP
    _text = replace(_text, r.original, r.transliteration);
  END LOOP;

  RETURN trim(_text);
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION transliterate.slugify(
  _text varchar
) RETURNS varchar AS $$
  SELECT trim(
    BOTH '-' FROM regexp_replace(
      lower(
        transliterate.to_ascii( translate($1, '@°', 'a ') )
      ),
      '[^a-z0-9]+',
      '-',
      'g'
    )
  );
$$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION api.domain_verification_token() RETURNS TEXT AS $$
  var [ { token }] = plv8.execute(`
    SELECT MD5(current_setting('request.jwt.claim.sub', true)::text || COALESCE(current_setting('request.header.x-domain-verification-salt',true),public.uuid_generate_v1()::text)::text) AS token
  `);

  return token;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api_developer_v1.courses_user_owns_provider(u_id bigint, p_id uuid) RETURNS boolean AS $$
  var results = plv8.execute(`
    SELECT id FROM app.provider_ownerships
    WHERE user_account_id = ${u_id} AND provider_id = '${p_id}'
    LIMIT 1;`
  );

  return results.length > 0;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api_developer_v1.courses_instead_of_delete() RETURNS trigger AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var user_owns_provider = plv8.find_function("api_developer_v1.courses_user_owns_provider");
  var raise_error = plv8.find_function("raise_error");
  var rescue_error = plv8.find_function("rescue_error");

  var course = OLD;
  var provider_id;

  var result = plv8.execute("SELECT provider_id FROM app.courses WHERE id = $1", [ course.id ])[0]

  if (result) {
    provider_id = result.provider_id;
  } else {
    raise_error(403, 'Unauthorized', 'id is not valid');
  }

  if (!user_owns_provider(current_user_id, provider_id)) {
    raise_error(403, 'Unauthorized', 'id is not valid');
  }

  try {
    return plv8.execute(`
      DELETE FROM app.courses
      WHERE id = '${course.id}';
    `)[0];
  } catch(exception) {
    rescue_error(exception);
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api_developer_v1.courses_instead_of_insert() RETURNS trigger AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var user_owns_provider = plv8.find_function("api_developer_v1.courses_user_owns_provider");
  var raise_error = plv8.find_function("raise_error");
  var rescue_error = plv8.find_function("rescue_error");
  var course = NEW;

  if (!course.provider_id) {
    raise_error(500, 'Incomplete State', 'provider_id is blank');
  }

  if (!user_owns_provider(current_user_id, course.provider_id)) {
    raise_error(403, 'Unauthorized', 'provider_id is not valid');
  }

  try {
    return plv8.execute(`
      INSERT INTO app.courses (
        name,
        slug,
        provider_id
      ) VALUES (
        '${course.name}',
        '${course.slug}',
        '${course.provider_id}'
      );
    `)[0];
  } catch(exception) {
    rescue_error(exception);
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api_developer_v1.courses_instead_of_update() RETURNS trigger AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var user_owns_provider = plv8.find_function("api_developer_v1.courses_user_owns_provider");
  var raise_error = plv8.find_function("raise_error");
  var rescue_error = plv8.find_function("rescue_error");

  var course = NEW;
  var provider_id;

  var result = plv8.execute("SELECT provider_id FROM app.courses WHERE id = $1", [ course.id ])[0]

  if (result) {
    provider_id = result.provider_id;
  } else {
    raise_error(403, 'Unauthorized', 'id is not valid');
  }

  if (!user_owns_provider(current_user_id, provider_id)) {
    raise_error(403, 'Unauthorized', 'id is not valid');
  }

  try {
    return plv8.execute(`
      UPDATE app.courses
      SET name = '${course.name}',
          slug = '${course.slug}'
      WHERE id = '${course.id}';
    `)[0];
  } catch(exception) {
    rescue_error(exception);
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api.domain_ownership_verifications_instead_of_insert() RETURNS trigger AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var rescue_error = plv8.find_function("rescue_error");
  var token = plv8.find_function("api.domain_verification_token");
  var domain_ownership_verification = NEW;

  try {
    // has to return exactly how it's defined on api.domain_ownership_verifications
    var verification = plv8.execute(`
      INSERT INTO app.domain_ownership_verifications (
        user_account_id,
        domain,
        authority_confirmation_status,
        authority_confirmation_token
      ) VALUES (
        ${current_user_id},
        '${domain_ownership_verification.domain}',
        'confirming',
        '${token()}'
      ) RETURNING id, authority_confirmation_status, authority_confirmation_method, authority_confirmation_token, domain, run_count;
    `)[0];

    plv8.execute(`
      SELECT app.enqueue_job(
        'Developers::DomainOwnershipVerificationJob',
        ('["${verification.id}"]')::jsonb
      );
    `);

    return verification;
  } catch(exception) {
    rescue_error(exception);
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api.profiles_instead_of_update() RETURNS trigger AS $$
DECLARE
  exception_sql_state text;
  exception_column_name text;
  exception_constraint_name text;
  exception_table_name text;
  exception_message text;
  exception_detail text;
  exception_hint text;
BEGIN
  IF NEW.user_account_id != OLD.user_account_id THEN
    RAISE invalid_authorization_specification USING message = 'could not change user_account_id';
  END IF;

  IF NEW.user_account_id::bigint <> current_user_id()::bigint THEN
    RAISE insufficient_privilege;
  END IF;

  UPDATE app.profiles
  SET
    name                = NEW.name,
    date_of_birth       = NEW.date_of_birth,
    interests           = NEW.interests,
    preferences         = NEW.preferences,
    username            = NEW.username,
    short_bio           = NEW.short_bio,
    long_bio            = NEW.long_bio,
    instructor          = NEW.instructor,
    public              = NEW.public,
    website             = NEW.website,
    country             = NEW.country,
    course_ids          = NEW.course_ids,
    social_profiles     = NEW.social_profiles,
    elearning_profiles  = NEW.elearning_profiles
  WHERE
    id = OLD.id;

  RETURN NEW;
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE;
  WHEN OTHERS THEN
  GET STACKED DIAGNOSTICS exception_message = MESSAGE_TEXT,
                          exception_detail = PG_EXCEPTION_DETAIL,
                          exception_hint = PG_EXCEPTION_HINT,
                          exception_sql_state = RETURNED_SQLSTATE,
                          exception_column_name = COLUMN_NAME,
                          exception_constraint_name = CONSTRAINT_NAME,
                          exception_table_name = TABLE_NAME;

  IF exception_detail = 'error' THEN
    RAISE EXCEPTION '%', exception_message
      USING DETAIL = exception_detail, HINT = exception_hint;
  ELSE
    -- constraint
    IF exception_sql_state IN ('23514', '23505') AND exception_constraint_name IS NOT NULL THEN
      exception_column_name := REGEXP_REPLACE(exception_constraint_name, '(.*)__(.*)', '\1');
      exception_sql_state := 'constraint';

      exception_detail := (
        CASE exception_column_name
          WHEN 'used_usernames_username_idx' THEN '010001'
          WHEN 'used_usernames_profile_id_username_idx'  THEN '010002'
          ELSE '010000'
        END
      );

    END IF;

    RAISE EXCEPTION '%', exception_message
      USING DETAIL = COALESCE(exception_detail, 'error'), HINT = exception_hint;

  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.provider_ownership_creations_instead_of_insert() RETURNS trigger AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var rescue_error = plv8.find_function("rescue_error");
  var provider_ownership_creation = NEW;

  try {
    // has to return exactly how it's defined on api.provider_ownership_creations
    var verification = plv8.execute(`
      INSERT INTO app.provider_ownership_creations (
        user_account_id,
        domain,
        status
      ) VALUES (
        ${current_user_id},
        '${provider_ownership_creation.domain}',
        'pending'
      ) RETURNING id, status, domain, run_count;
    `)[0];

    plv8.execute(`
      SELECT app.enqueue_job(
        'Developers::ProviderOwnershipCreation',
        ('["${verification.id}"]')::jsonb
      );
    `);

    return verification;
  } catch(exception) {
    rescue_error(exception);
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api.study_lists_instead_of_delete() RETURNS trigger AS $$
DECLARE
  current_user_id     bigint;
  study_list          app.study_lists;
BEGIN

    DELETE FROM app.study_lists
    WHERE id = OLD.id
    AND standard = false;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Can''t delete record %', OLD.id USING HINT = 'Standard lists can''t be deleted';
    END IF;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.study_lists_instead_of_update() RETURNS trigger AS $$
DECLARE
  study_list          app.study_lists;
BEGIN

    UPDATE app.study_lists
    SET name = NEW.name,
      description = NEW.description,
      tags = NEW.tags,
      public = NEW.public
    WHERE id = NEW.id
    RETURNING * INTO study_list;

  RETURN study_list;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.study_lists_instead_of_insert() RETURNS trigger AS $$
DECLARE
  study_list app.study_lists;
BEGIN

  INSERT INTO app.study_lists (
    name,
    slug,
    description,
    user_account_id
  ) VALUES (
    NEW.name,
    transliterate.slugify(NEW.name),
    NEW.description,
    current_setting('request.jwt.claim.sub', true)::bigint
  ) RETURNING * INTO study_list;

  RETURN study_list;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.study_list_entries_instead_of_insert() RETURNS trigger AS $$
DECLARE
  study_list_user_account_id  bigint;
  current_user_id             bigint;
  pos                         integer;
  study_list_entry            app.study_list_entries;
BEGIN
  current_user_id  := current_setting('request.jwt.claim.sub', true)::bigint;

  SELECT user_account_id
    INTO study_list_user_account_id
    FROM app.study_lists
    WHERE id = NEW.study_list_id;

  IF current_user_id <> study_list_user_account_id THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  SELECT COUNT(*)
    INTO pos
    FROM app.study_list_entries
    INNER JOIN app.study_lists ON app.study_list_entries.study_list_id = app.study_lists.id
    WHERE study_list_id = NEW.study_list_id;

  INSERT INTO app.study_list_entries
    (study_list_id, course_id, position)
  VALUES
    (NEW.study_list_id, NEW.course_id, COALESCE(NEW.position,pos))
  RETURNING * INTO study_list_entry;

  RETURN study_list_entry;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.study_list_entries_instead_of_update() RETURNS trigger AS $$
DECLARE
  study_list_entry app.study_list_entries;
BEGIN
  UPDATE app.study_list_entries
  SET position = NEW.position
  WHERE (
      id = NEW.id
    )
    OR
    (
      course_id = NEW.course_id
      AND
      study_list_id = NEW.study_list_id
    )
  RETURNING * INTO study_list_entry;

  RETURN study_list_entry;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.study_list_entries_instead_of_delete() RETURNS trigger AS $$
BEGIN
  DELETE FROM app.study_list_entries
  WHERE (
    id = OLD.id
  ) OR (
    course_id = OLD.course_id
      AND
    study_list_id = OLD.study_list_id
  );
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION
  api_keys.generate_base64_uuid()
RETURNS varchar AS $$
  var [ { uuid } ] = plv8.execute("SELECT encode(decode(replace((public.uuid_generate_v4())::text, '-', ''), 'hex'), 'base64') AS uuid");

  return uuid.replace(/=/g,'').replace(/\+/g, '-').replace(/\//g, '_');
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION api_keys.crypt_secret(api_secret varchar) RETURNS varchar AS $$
  SELECT crypt(api_secret , gen_salt('md5'));
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION api_keys.generate_secret() RETURNS varchar AS $$
  SELECT
    CONCAT(
      api_keys.generate_base64_uuid(),
      api_keys.generate_base64_uuid(),
      api_keys.generate_base64_uuid(),
      api_keys.generate_base64_uuid()
    );
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION
  api_keys.validate(api_key varchar)
  RETURNS bigint AS $$
DECLARE
  user_id bigint;
  api_prefix varchar;
  api_secret varchar;
BEGIN
  SELECT split_part(api_key, '.', 1) INTO api_prefix;
  SELECT split_part(api_key, '.', 2) INTO api_secret;

  SELECT user_account_id
      FROM app.api_keys
      WHERE prefix = api_prefix
      AND   encrypted_secret = crypt(api_secret, encrypted_secret)
      AND   status = 'enabled'
  INTO user_id;

  IF user_id IS NULL THEN
    PERFORM raise_error(401, 'Unauthorized', 'Invalid API Key', 'Check if your API Key is correct or generate a new one');
  END IF;

  RETURN user_id;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION
  api_keys.generate(_user_account_id bigint)
  RETURNS varchar AS $$
DECLARE
  user_id bigint;
  api_key varchar;
  api_prefix varchar;
  api_secret varchar;
  hashed_api_secret varchar;
BEGIN
  -- check if user_account_id exists

  SELECT id FROM app.user_accounts WHERE id = _user_account_id INTO user_id;
  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Invalid User Account ID!';
  END IF;

  -- check if user_account_id isn't blacklisted
  -- TODO!

  -- disables all other API keys belonging to the user_account
  UPDATE app.api_keys SET status = 'disabled', updated_at = NOW() WHERE user_account_id = _user_account_id;

  -- generates relevant data
  SELECT api_keys.generate_prefix() INTO api_prefix;
  SELECT api_keys.generate_secret() INTO api_secret;
  SELECT api_keys.crypt_secret(api_secret) INTO hashed_api_secret;

  -- inserts new api-key in the database
  INSERT INTO app.api_keys
  (
    prefix,
    encrypted_secret,
    user_account_id,
    status
  )
  VALUES (
    api_prefix,
    hashed_api_secret,
    _user_account_id,
    'enabled'
  );

  SELECT CONCAT(api_prefix, '.', api_secret) INTO api_key;

  RETURN api_key;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api_keys.generate_prefix() RETURNS varchar AS $$
  SELECT api_keys.generate_base64_uuid();
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION app.content_type_by_extension(
  filename varchar
) RETURNS varchar AS $$
BEGIN
  CASE
  WHEN lower(filename) ~ '.(jpg|jpeg)$' THEN
    RETURN 'image/jpeg';
  WHEN lower(filename) ~ '.gif$' THEN
    RETURN 'image/gif';
  WHEN lower(filename) ~ '.png$' THEN
    RETURN 'image/png';
  WHEN lower(filename) ~ '.svg$' THEN
    RETURN 'image/svg+xml';
  WHEN lower(filename) ~ '.pdf$' THEN
    RETURN 'application/pdf';
  ELSE
    RETURN 'application/octet-stream';
  END CASE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.currency_index(currency varchar)
RETURNS BIGINT AS $$
BEGIN
  CASE
  WHEN currency = 'USD' THEN
    RETURN 0;
  WHEN currency = 'EUR' THEN
    RETURN 1;
  WHEN currency = 'GPB' THEN
    RETURN 2;
  WHEN currency = 'BRL' THEN
    RETURN 3;
  ELSE
    RETURN 4;
  END CASE;
END;
$$ LANGUAGE plpgsql STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION app.enqueue_job(
  job_class text,
  args jsonb,
  run_at timestamp with time zone default NOW()
)
RETURNS void AS $$
BEGIN
  INSERT INTO public.que_jobs
    (queue, priority, run_at, job_class, args, data)
    VALUES
    (
      'default',
      100,
      run_at,
      job_class,
      args,
      '{}'::jsonb
    );
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION app.fill_sitemaps(
  _sitemaps app.sitemap[]
) RETURNS app.sitemap[] AS $$
  SELECT
    ARRAY_AGG(
      (
        COALESCE(sitemap.id,     public.uuid_generate_v4()),
        COALESCE(sitemap.status, 'unconfirmed'),
        sitemap.url,
        sitemap.type
      )::app.sitemap
    )
  FROM unnest(_sitemaps) AS sitemap
  WHERE
    sitemap.url IS NOT NULL
    AND char_length(sitemap.url) > 0
$$ LANGUAGE sql;

CREATE FUNCTION app.insert_into_preview_course_pricings(pcid uuid, pricing jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO app.preview_course_pricings (
    preview_course_id,
    pricing_type,
    plan_type,
    customer_type,
    price,
    total_price,
    discount,
    currency,
    payment_period_unit,
    payment_period_value,
    trial_period_unit,
    trial_period_value,
    subscription_period_unit,
    subscription_period_value
  ) VALUES (
    pcid,
    (pricing->>'type')::app.pricing,
    COALESCE(pricing->>'plan_type', 'regular')::app.pricing_plan,
    COALESCE(pricing->>'customer_type', 'individual')::app.pricing_customer,
    (pricing->>'price')::numeric(13,2),
    (pricing->>'total_price')::numeric(13,2),
    (pricing->>'discount')::numeric(13,2),
    (pricing->>'currency')::app.iso4217_code,
    (pricing->'payment_period'->>'unit')::app.period_unit,
    (pricing->'payment_period'->>'value')::integer,
    (pricing->'trial_period'->>'unit')::app.period_unit,
    (pricing->'trial_period'->>'value')::integer,
    (pricing->'subscription_period'->>'unit')::app.period_unit,
    (pricing->'subscription_period'->>'value')::integer
  ) ON CONFLICT (
    preview_course_id,
    pricing_type,
    plan_type,
    COALESCE(customer_type, 'unknown'),
    currency,
    COALESCE(payment_period_unit, 'unknown'),
    COALESCE(subscription_period_unit, 'unknown'),
    COALESCE(trial_period_unit, 'unknown')
  ) DO UPDATE SET
    pricing_type              = EXCLUDED.pricing_type,
    plan_type                 = EXCLUDED.plan_type,
    customer_type             = EXCLUDED.customer_type,
    price                     = EXCLUDED.price,
    total_price               = EXCLUDED.total_price,
    discount                  = EXCLUDED.discount,
    currency                  = EXCLUDED.currency,
    payment_period_unit       = EXCLUDED.payment_period_unit,
    payment_period_value      = EXCLUDED.payment_period_value,
    trial_period_unit         = EXCLUDED.trial_period_unit,
    trial_period_value        = EXCLUDED.trial_period_value,
    subscription_period_unit  = EXCLUDED.subscription_period_unit,
    subscription_period_value = EXCLUDED.subscription_period_value;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION app.insert_into_course_pricings(cid uuid, pricing jsonb)
RETURNS void AS $$
BEGIN
  INSERT INTO app.course_pricings (
    course_id,
    pricing_type,
    plan_type,
    customer_type,
    price,
    total_price,
    discount,
    currency,
    payment_period_unit,
    payment_period_value,
    trial_period_unit,
    trial_period_value,
    subscription_period_unit,
    subscription_period_value
  ) VALUES (
    cid,
    (pricing->>'type')::app.pricing,
    COALESCE(pricing->>'plan_type', 'regular')::app.pricing_plan,
    COALESCE(pricing->>'customer_type', 'individual')::app.pricing_customer,
    (pricing->>'price')::numeric(13,2),
    (pricing->>'total_price')::numeric(13,2),
    (pricing->>'discount')::numeric(13,2),
    (pricing->>'currency')::app.iso4217_code,
    (pricing->'payment_period'->>'unit')::app.period_unit,
    (pricing->'payment_period'->>'value')::integer,
    (pricing->'trial_period'->>'unit')::app.period_unit,
    (pricing->'trial_period'->>'value')::integer,
    (pricing->'subscription_period'->>'unit')::app.period_unit,
    (pricing->'subscription_period'->>'value')::integer
  ) ON CONFLICT (
    course_id,
    pricing_type,
    plan_type,
    COALESCE(customer_type, 'unknown'),
    currency,
    COALESCE(payment_period_unit, 'unknown'),
    COALESCE(subscription_period_unit, 'unknown'),
    COALESCE(trial_period_unit, 'unknown')
  ) DO UPDATE SET
    pricing_type              = EXCLUDED.pricing_type,
    plan_type                 = EXCLUDED.plan_type,
    customer_type             = EXCLUDED.customer_type,
    price                     = EXCLUDED.price,
    total_price               = EXCLUDED.total_price,
    discount                  = EXCLUDED.discount,
    currency                  = EXCLUDED.currency,
    payment_period_unit       = EXCLUDED.payment_period_unit,
    payment_period_value      = EXCLUDED.payment_period_value,
    trial_period_unit         = EXCLUDED.trial_period_unit,
    trial_period_value        = EXCLUDED.trial_period_value,
    subscription_period_unit  = EXCLUDED.subscription_period_unit,
    subscription_period_value = EXCLUDED.subscription_period_value;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.merge_sitemaps(
  _old_sitemaps app.sitemap[],
  _new_sitemaps app.sitemap[]
) RETURNS app.sitemap[] AS $$
  SELECT
    ARRAY_AGG(
      COALESCE(old_sitemap, new_sitemap)
    )
  FROM      unnest(_new_sitemaps) AS new_sitemap
  LEFT JOIN unnest(_old_sitemaps) AS old_sitemap ON
    new_sitemap.id = old_sitemap.id
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION app.new_sitemaps(
  _sitemaps app.sitemap[]
) RETURNS app.sitemap[] AS $$
  SELECT
    ARRAY_AGG(
      (
        COALESCE(sitemap.id, public.uuid_generate_v4()),
        'unconfirmed',
        sitemap.url,
        sitemap.type
      )::app.sitemap
    )
  FROM unnest(_sitemaps) AS sitemap
  WHERE
    sitemap.url IS NOT NULL
    AND char_length(sitemap.url) > 0
$$ LANGUAGE sql;

CREATE FUNCTION app.normalize_languages(languages text[]) RETURNS text[] AS $$
DECLARE
  upcased_languages text[];
BEGIN
  WITH

  subtitles AS (
    SELECT DISTINCT unnest(languages) AS subtitle
  ),

  subtitle_arrays AS (
    SELECT regexp_split_to_array(subtitle, '-') AS subtitle_array
    FROM subtitles
  )

  SELECT DISTINCT
    ARRAY_AGG(
      CASE WHEN array_length(subtitle_array, 1) = 2
      THEN subtitle_array[1] || '-' || upper(subtitle_array[2])
      ELSE subtitle_array[1]
      END
    )
  FROM subtitle_arrays
  INTO upcased_languages;

  RETURN upcased_languages;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.price_in_decimal(price text)
  RETURNS DECIMAL AS
$$
BEGIN
   IF $1 = '' THEN  -- special case for empty string like requested
      RETURN 0::DECIMAL(12,2);
   ELSE
      RETURN $1::DECIMAL(12,2);
   END IF;

EXCEPTION WHEN OTHERS THEN
   RETURN NULL;  -- NULL for other invalid input

END
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION app.sign_certificate_s3_fetch(
  id         uuid,
  filename   varchar,
  expires_in int
) RETURNS text AS $$
BEGIN
  RETURN app.sign_s3_fetch(
    '$CERTIFICATE_AWS_REGION',
    '$CERTIFICATE_AWS_HOST',
    '$CERTIFICATE_AWS_BUCKET',
    '$CERTIFICATE_AWS_FOLDER',
    id::varchar || '-' || filename,
    '$CERTIFICATE_AWS_ACCESS_KEY_ID',
    '$CERTIFICATE_AWS_SECRET_ACCESS_KEY',
    expires_in,
    '$CERTIFICATE_AWS_IS_HTTPS'::boolean
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.sign_certificate_s3_upload(
  id         uuid,
  filename   varchar,
  expires_in int
) RETURNS text AS $$
BEGIN
  RETURN app.sign_s3_upload(
    '$CERTIFICATE_AWS_REGION',
    '$CERTIFICATE_AWS_HOST',
    '$CERTIFICATE_AWS_BUCKET',
    '$CERTIFICATE_AWS_FOLDER',
    id::varchar || '-' || filename,
    '$CERTIFICATE_AWS_ACCESS_KEY_ID',
    '$CERTIFICATE_AWS_SECRET_ACCESS_KEY',
    expires_in,
    '$CERTIFICATE_AWS_IS_PUBLIC'::boolean,
    '$CERTIFICATE_AWS_IS_HTTPS'::boolean
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.sign_direct_s3_fetch(
  id         uuid,
  filename   varchar,
  folder     varchar,
  expires_in int
) RETURNS text AS $$
BEGIN
  RETURN app.sign_s3_fetch(
    '$DIRECT_UPLOAD_AWS_REGION',
    '$DIRECT_UPLOAD_AWS_HOST',
    '$DIRECT_UPLOAD_AWS_BUCKET',
    '$DIRECT_UPLOAD_AWS_ROOT_FOLDER' || '/' || folder,
    id::varchar || '-' || filename,
    '$DIRECT_UPLOAD_AWS_ACCESS_KEY_ID',
    '$DIRECT_UPLOAD_AWS_SECRET_ACCESS_KEY',
    expires_in,
    '$DIRECT_UPLOAD_AWS_IS_HTTPS'::boolean
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.sign_direct_s3_upload(
  id         uuid,
  filename   varchar,
  folder     varchar,
  expires_in int
) RETURNS text AS $$
BEGIN
  RETURN app.sign_s3_upload(
    '$DIRECT_UPLOAD_AWS_REGION',
    '$DIRECT_UPLOAD_AWS_HOST',
    '$DIRECT_UPLOAD_AWS_BUCKET',
    '$DIRECT_UPLOAD_AWS_ROOT_FOLDER' || '/' || folder,
    id::varchar || '-' || filename,
    '$DIRECT_UPLOAD_AWS_ACCESS_KEY_ID',
    '$DIRECT_UPLOAD_AWS_SECRET_ACCESS_KEY',
    expires_in,
    '$DIRECT_UPLOAD_AWS_IS_PUBLIC'::boolean,
    '$DIRECT_UPLOAD_AWS_IS_HTTPS'::boolean
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.sign_s3_fetch(
  region            varchar,
  host              varchar,
  bucket            varchar,
  folder            varchar,
  filename          varchar,
  access_key_id     varchar,
  secret_access_key varchar,
  expires_in        int,
  is_https          boolean
) RETURNS text AS $$
DECLARE
  canonical_request_digest text;
  string_to_sign           text;
  content_type             varchar;
  time_string              varchar;
  date_string              varchar;
  key                      bytea;
  query_string             varchar;
  signature                varchar;
  fullpath                 varchar;
  time_now                 timestamptz;
BEGIN
  time_now    = timezone('utc', NOW());
  time_string = to_char(time_now, 'YYYYMMDD"T"HH24MISSZ');
  date_string = to_char(time_now, 'YYYYMMDD');

  query_string = 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
              || '&X-Amz-Credential=' || access_key_id || '%2F' || date_string || '%2F' || region || '%2Fs3%2Faws4_request'
              || '&X-Amz-Date='    || time_string
              || '&X-Amz-Expires=' || expires_in::varchar
              || '&X-Amz-SignedHeaders=host';

  canonical_request_digest = E'GET\n/'
                          || bucket || folder || '/' || filename || E'\n'
                          || query_string
                          || E'\nhost:' || host
                          || E'\n\nhost\n'
                          || 'UNSIGNED-PAYLOAD';

  string_to_sign = E'AWS4-HMAC-SHA256\n'
                || time_string || E'\n'
                || date_string || '/' || region || E'/s3/aws4_request\n'
                || encode(digest(canonical_request_digest, 'sha256'), 'hex');

  key = hmac(date_string,           'AWS4' || secret_access_key, 'sha256');
  key = hmac(region::bytea,         key,                         'sha256');
  key = hmac('s3'::bytea,           key,                         'sha256');
  key = hmac('aws4_request'::bytea, key,                         'sha256');

  signature = encode(hmac(string_to_sign::bytea, key, 'sha256'), 'hex');
  fullpath  = host || '/' || bucket || folder || '/' || filename || '?' || query_string || '&X-Amz-Signature=' || signature;

  IF is_https THEN
    RETURN 'https://' || fullpath;
  ELSE
    RETURN 'http://' || fullpath;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.sign_s3_upload(
  region            varchar,
  host              varchar,
  bucket            varchar,
  folder            varchar,
  filename          varchar,
  access_key_id     varchar,
  secret_access_key varchar,
  expires_in        int,
  is_public         boolean,
  is_https          boolean
) RETURNS text AS $$
DECLARE
  canonical_request_digest text;
  string_to_sign           text;
  acl                      varchar;
  content_type             varchar;
  time_string              varchar;
  date_string              varchar;
  key                      bytea;
  query_string             varchar;
  signature                varchar;
  fullpath                 varchar;
  time_now                 timestamptz;
BEGIN
  time_now    = timezone('utc', NOW());
  time_string = to_char(time_now, 'YYYYMMDD"T"HH24MISSZ');
  date_string = to_char(time_now, 'YYYYMMDD');

  query_string = 'X-Amz-Algorithm=AWS4-HMAC-SHA256'
              || '&X-Amz-Credential=' || access_key_id || '%2F' || date_string || '%2F' || region || '%2Fs3%2Faws4_request'
              || '&X-Amz-Date='    || time_string
              || '&X-Amz-Expires=' || expires_in::varchar
              || '&X-Amz-SignedHeaders=content-type%3Bhost%3Bx-amz-acl';

  content_type = app.content_type_by_extension(filename);

  IF is_public THEN
    acl = 'public-read';
  ELSE
    acl = 'private';
  END IF;

  canonical_request_digest = E'PUT\n/'
                          || bucket || folder || '/' || filename || E'\n'
                          || query_string
                          || E'\ncontent-type:' || content_type
                          || E'\nhost:' || host
                          || E'\nx-amz-acl:' || acl
                          || E'\n\ncontent-type;host;x-amz-acl\n'
                          || 'UNSIGNED-PAYLOAD';

  string_to_sign = E'AWS4-HMAC-SHA256\n'
                || time_string || E'\n'
                || date_string || '/' || region || E'/s3/aws4_request\n'
                || encode(digest(canonical_request_digest, 'sha256'), 'hex');

  key = hmac(date_string,           'AWS4' || secret_access_key, 'sha256');
  key = hmac(region::bytea,         key,                         'sha256');
  key = hmac('s3'::bytea,           key,                         'sha256');
  key = hmac('aws4_request'::bytea, key,                         'sha256');

  signature = encode(hmac(string_to_sign::bytea, key, 'sha256'), 'hex');
  fullpath  = host || '/' || bucket || folder || '/' || filename || '?' || query_string || '&X-Amz-Signature=' || signature;

  IF is_https THEN
    RETURN 'https://' || fullpath;
  ELSE
    RETURN 'http://' || fullpath;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.normalize_name(
  text
) RETURNS text RETURNS NULL ON NULL INPUT AS $$
  SELECT regexp_replace(
    regexp_replace(
      regexp_replace(
        regexp_replace(
          $1,
          '(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|[\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|[\ud83c[\ude32-\ude3a]|[\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])', ''
        ),
        '\s+', ' ', 'g'), '\s+$', ''
      )
    , '^\s+', ''
  );
$$ IMMUTABLE LANGUAGE sql;

CREATE OR REPLACE FUNCTION app.slugify(value varchar)
RETURNS TEXT AS $$
  WITH unaccented AS (
    SELECT unaccent(value) AS value
  ),

  lowercase AS (
    SELECT lower(value) AS value
    FROM unaccented
  ),

  hyphenated AS (
    SELECT regexp_replace(value, '[^a-z0-9\\-_]+', '-', 'gi') AS value
    FROM lowercase
  ),

  trimmed AS (
    SELECT regexp_replace(regexp_replace(value, '\\-+$', ''), '^\\-', '') AS value
    FROM hyphenated
  )

  SELECT value FROM trimmed;
$$ LANGUAGE SQL STRICT IMMUTABLE;

CREATE OR REPLACE FUNCTION app.provider_uuid_generate(
  uuid, variadic varchar[]
) RETURNS uuid AS $$
  WITH coalesced_value_from_array AS (
    SELECT val
    FROM unnest($2) AS val
    WHERE val IS NOT NULL AND val != ''
    LIMIT 1
  )

  SELECT uuid_generate_v5(
    uuid_generate_v3(uuid_nil(), $1::varchar),
    transliterate.slugify(app.normalize_name(coalesced_value_from_array.val))
  )
  FROM coalesced_value_from_array;
$$ VOLATILE LANGUAGE sql;

CREATE OR REPLACE FUNCTION app.text_to_locale(
  _text text
) RETURNS  app.locale AS $$
  DECLARE
    language text := SPLIT_PART(_text, '-',1);
    country text := SPLIT_PART(_text, '-',2);
  BEGIN
    CASE
      WHEN language = 'jp' THEN
        language := 'ja';
      WHEN language = 'iw' THEN
        language := 'he';
      WHEN language = 'haw' THEN
        language := NULL;
      WHEN country = 'HANS' THEN
        country := 'CN';
      WHEN country = 'HANT' THEN
        country := 'TW';
      WHEN country ='LATN' OR country = 'CMN' OR country = '419' THEN
        country := '';
      WHEN _text = 'es-LA' THEN
        language = 'es';
        country := '';
      ELSE
        -- do nothing
    END CASE;
    RETURN ('(' || language || ',' || country || ')')::app.locale ;
  END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION app.subtitles_to_locale(
  _subtitles text[]
) RETURNS app.locale[] AS $$
  SELECT array_remove(array_agg(app.text_to_locale(lang)), NULL)
  FROM unnest(_subtitles) AS lang;
$$ LANGUAGE sql;

CREATE FUNCTION jwt.url_encode(data bytea) RETURNS text
AS $$
  SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$ LANGUAGE sql;

CREATE FUNCTION jwt.algorithm_sign(
  signables text,
  secret    text,
  algorithm text
) RETURNS text
AS $$
  WITH
    alg AS ( SELECT
      CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE ''
      END
    )  -- hmac throws error
  SELECT jwt.url_encode(public.hmac(signables, secret, (select * FROM alg)));
$$ LANGUAGE sql;

CREATE FUNCTION jwt.sign(
  payload json,
  secret text,
  algorithm text DEFAULT 'HS256'
) RETURNS text
AS $$
  WITH
    header AS (
      SELECT jwt.url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8'))
    ),
    payload AS (
      SELECT jwt.url_encode(convert_to(payload::text, 'utf8'))
    ),
    signables AS (
      SELECT (SELECT * FROM header) || '.' || (SELECT * FROM payload)
    )

  SELECT
    (SELECT * FROM signables) ||
    '.' ||
    jwt.algorithm_sign(
      (SELECT * FROM signables),
      secret,
      algorithm
    );
$$ LANGUAGE sql;

CREATE FUNCTION jwt.url_decode(data text) RETURNS bytea
AS $$
WITH
  t   AS ( SELECT translate(data, '-_', '+/') ),
  rem AS ( SELECT length((SELECT * FROM t)) % 4) -- compute padding size
  SELECT decode(
    (SELECT * FROM t) ||
    CASE WHEN (SELECT * FROM rem) > 0
      THEN repeat('=', (4 - (SELECT * FROM rem)))
      ELSE ''
    END,
    'base64'
  );
$$ LANGUAGE sql;

CREATE FUNCTION jwt.verify(
  token     text,
  secret    text,
  algorithm text DEFAULT 'HS256'
) RETURNS table(header json, payload json, valid boolean)
AS $$
  SELECT
    convert_from(jwt.url_decode(r[1]), 'utf8')::json AS header,
    convert_from(jwt.url_decode(r[2]), 'utf8')::json AS payload,
    r[3] = jwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
  FROM regexp_split_to_array(token, '\.') r;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION block_cipher_encode(data jsonb) RETURNS TEXT AS $$
DECLARE
  cipher_key bytea := (SELECT value::bytea FROM settings.secrets WHERE key = 'cipher_key');
  cipher_iv bytea := (SELECT value::bytea FROM settings.secrets WHERE key = 'cipher_iv');
BEGIN
  IF cipher_iv IS NULL OR cipher_key IS NULL THEN
    RAISE EXCEPTION 'Block cipher parameters not configured';
  ELSE
    RETURN encode(convert_to(encrypt_iv((data::text)::bytea, cipher_key, cipher_iv, 'aes-cbc')::text, 'UTF-8'), 'hex');
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION block_cipher_decode(data text) RETURNS JSONB AS $$
DECLARE
  cipher_key bytea := (SELECT value::bytea FROM settings.secrets WHERE key = 'cipher_key');
  cipher_iv bytea := (SELECT value::bytea FROM settings.secrets WHERE key = 'cipher_iv');
BEGIN
  IF cipher_iv IS NULL OR cipher_key IS NULL THEN
    RAISE EXCEPTION 'Block cipher parameters not configured';
  ELSE
    RETURN convert_from(decrypt_iv(convert_from(decode(data, 'hex'), 'UTF-8')::bytea, cipher_key, cipher_iv, 'aes-cbc')::bytea, 'UTF-8')::jsonb;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION current_api_schema() RETURNS TEXT AS $$
var current_schema;
var get_setting = plv8.find_function('get_setting');
var http_method = get_setting('request.method');

if (http_method == 'GET' || http_method == 'POST') {
  current_schema = get_setting('request.header.accept-profile');
} else {
  current_schema = get_setting('request.header.content-profile');
}

return current_schema;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION current_user_by_key() RETURNS bigint AS $$
  var get_setting = plv8.find_function('get_setting');
  var raise_error = plv8.find_function('raise_error');

  if (!get_setting('request.header.x-api-key')) {
    raise_error(401, "Unauthorized", "No API Key provided", "Missing API Key value in the X-API-Key header");
  }

  var [{ user_id }] = plv8.execute(`SELECT api_keys.validate(get_setting('request.header.x-api-key')) AS user_id;`);

  plv8.execute(`SELECT set_config('api.current_user'::text, '${user_id}', true);`);

  return user_id;
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION current_user_id() RETURNS bigint AS $$
  var get_setting = plv8.find_function('get_setting');

  return get_setting('request.jwt.claim.sub');
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION get_setting(setting TEXT, noraise BOOLEAN = true)
RETURNS TEXT AS $$
  var result = plv8.execute(`SELECT current_setting('${setting}', '${noraise || true}') AS setting;`)[0];

  if (result) {
    return result.setting;
  } else {
    return null;
  }
$$ LANGUAGE plv8;

CREATE OR REPLACE FUNCTION public.if_admin(value anyelement) RETURNS anyelement AS $$
BEGIN
  IF current_user = 'admin' THEN
    RETURN value;
  ELSE
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION public.if_user_by_id(id bigint, value anyelement) RETURNS anyelement AS $$
BEGIN
  IF current_user = 'user' AND current_setting('request.jwt.claim.sub', true)::bigint = id THEN
    RETURN value;
  ELSE
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION public.if_user_by_ids(ids bigint[], value anyelement) RETURNS anyelement AS $$
BEGIN
  IF current_user = 'user' AND current_setting('request.jwt.claim.sub', true)::bigint = ANY(ids) THEN
    RETURN value;
  ELSE
    RETURN NULL;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION prerequest() RETURNS VOID AS $$
// functions
var get_setting = plv8.find_function('get_setting');
var raise_error = plv8.find_function('raise_error');

// vars
var custom_error = get_setting('request.header.x-api-error');
var api_key = get_setting('request.header.x-api-key');

var current_api_schema = plv8.find_function('current_api_schema')();

// specific logic to user API
if (current_api_schema === "api") {
  var token = plv8.find_function("api.domain_verification_token");

  plv8.execute(`
    SELECT set_config('response.headers', '${JSON.stringify([
      {
        "X-Domain-Verification-Token": token()
      }
    ])}',true);
  `);
}

// specific logic to developer API
if (current_api_schema === "api_developer_v1") {
  plv8.find_function('current_user_by_key')();

  if (custom_error) {
    switch(custom_error) {
      case "limit.lowerbound":
        raise_error(500, 'API Error', 'Limit Too Low', 'Limit should equal at least 1');
      case "limit.upperbound":
        raise_error(500, 'API Error', 'Limit Too High', 'Limit should equal at most 100');
      case "offset.lowerbound":
        raise_error(500, 'API Error', 'Offset Too Low', 'Offset should equal at least 0');
      case "id.missing":
        raise_error(500, 'API Error', 'Missing ID', 'You should provide an id as a query parameter');
    }
  }
}

$$ LANGUAGE plv8;

CREATE FUNCTION public.que_determine_job_state(job public.que_jobs) RETURNS text
    LANGUAGE sql
    AS $$
  SELECT
    CASE
    WHEN job.expired_at  IS NOT NULL    THEN 'expired'
    WHEN job.finished_at IS NOT NULL    THEN 'finished'
    WHEN job.error_count > 0            THEN 'errored'
    WHEN job.run_at > CURRENT_TIMESTAMP THEN 'scheduled'
    ELSE                                     'ready'
    END
$$;

CREATE FUNCTION public.que_job_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    locker_pid integer;
    sort_key json;
  BEGIN
    -- Don't do anything if the job is scheduled for a future time.
    IF NEW.run_at IS NOT NULL AND NEW.run_at > NOW() THEN
      RETURN null;
    END IF;

    -- Pick a locker to notify of the job's insertion, weighted by their number
    -- of workers. Should bounce pseudorandomly between lockers on each
    -- invocation, hence the md5-ordering, but still touch each one equally,
    -- hence the modulo using the job_id.
    SELECT pid
    INTO locker_pid
    FROM (
      SELECT *, last_value(row_number) OVER () + 1 AS count
      FROM (
        SELECT *, row_number() OVER () - 1 AS row_number
        FROM (
          SELECT *
          FROM public.que_lockers ql, generate_series(1, ql.worker_count) AS id
          WHERE listening AND queues @> ARRAY[NEW.queue]
          ORDER BY md5(pid::text || id::text)
        ) t1
      ) t2
    ) t3
    WHERE NEW.id % count = row_number;

    IF locker_pid IS NOT NULL THEN
      -- There's a size limit to what can be broadcast via LISTEN/NOTIFY, so
      -- rather than throw errors when someone enqueues a big job, just
      -- broadcast the most pertinent information, and let the locker query for
      -- the record after it's taken the lock. The worker will have to hit the
      -- DB in order to make sure the job is still visible anyway.
      SELECT row_to_json(t)
      INTO sort_key
      FROM (
        SELECT
          'job_available' AS message_type,
          NEW.queue       AS queue,
          NEW.priority    AS priority,
          NEW.id          AS id,
          -- Make sure we output timestamps as UTC ISO 8601
          to_char(NEW.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at
      ) t;

      PERFORM pg_notify('que_listener_' || locker_pid::text, sort_key::text);
    END IF;

    RETURN null;
  END
$$;

CREATE FUNCTION public.que_state_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  DECLARE
    row record;
    message json;
    previous_state text;
    current_state text;
  BEGIN
    IF TG_OP = 'INSERT' THEN
      previous_state := 'nonexistent';
      current_state  := public.que_determine_job_state(NEW);
      row            := NEW;
    ELSIF TG_OP = 'DELETE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := 'nonexistent';
      row            := OLD;
    ELSIF TG_OP = 'UPDATE' THEN
      previous_state := public.que_determine_job_state(OLD);
      current_state  := public.que_determine_job_state(NEW);

      -- If the state didn't change, short-circuit.
      IF previous_state = current_state THEN
        RETURN null;
      END IF;

      row := NEW;
    ELSE
      RAISE EXCEPTION 'Unrecognized TG_OP: %', TG_OP;
    END IF;

    SELECT row_to_json(t)
    INTO message
    FROM (
      SELECT
        'job_change' AS message_type,
        row.id       AS id,
        row.queue    AS queue,

        coalesce(row.data->'tags', '[]'::jsonb) AS tags,

        to_char(row.run_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS run_at,
        to_char(NOW()      AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') AS time,

        CASE row.job_class
        WHEN 'ActiveJob::QueueAdapters::QueAdapter::JobWrapper' THEN
          coalesce(
            row.args->0->>'job_class',
            'ActiveJob::QueueAdapters::QueAdapter::JobWrapper'
          )
        ELSE
          row.job_class
        END AS job_class,

        previous_state AS previous_state,
        current_state  AS current_state
    ) t;

    PERFORM pg_notify('que_state', message::text);

    RETURN null;
  END
$$;

-- ex.: select raise_error(500, 'An error message');
CREATE OR REPLACE FUNCTION raise_error(code integer, message text default '', hint text default '', detail text default '') RETURNS void AS $$
  var using_params = [];

  if (message && message.length) {
    using_params.push(`MESSAGE = '${message}'`);
  }

  if (hint && hint.length) {
    using_params.push(`HINT = '${hint}'`);
  }

  if (detail && detail.length) {
    using_params.push(`DETAIL = '${detail}'`);
  }

  plv8.execute(`DO $raise$ BEGIN RAISE SQLSTATE 'PT${code}' ${using_params.length ? "USING " + using_params.join(", ") : ""}; END; $raise$ LANGUAGE PLPGSQL;`)
$$ LANGUAGE plv8;

-- "{\"sqlerrcode\":\"23505\",\"schema_name\":\"app\",\"table_name\":\"courses\",\"column_name\":null,\"datatype_name\":null,\"constraint_name\":\"index_courses_on_slug\",\"detail\":\"Key (slug)=(python-101) already exists.\",\"hint\":null,\"context\":\"SQL statement \\\"\\n      INSERT INTO app.courses (\\n        name,\\n        slug,\\n        provider_id\\n      ) VALUES (\\n        'Python 101',\\n        'python-101',\\n        '1c9153c1-ec3c-4e2e-a33b-4b2daf5c0820'\\n      );\\n    \\\"\",\"internalquery\":null,\"code\":83906754}"
CREATE OR REPLACE FUNCTION rescue_error(exception jsonb)
RETURNS VOID AS $$
  var current_user_id = plv8.find_function("current_user_id")();
  var raise_error = plv8.find_function("raise_error");

  if(exception.sqlerrcode == '23505') {
    raise_error(409, 'Conflict', exception.detail || 'Uniqueness Violation');
  }

  if(exception.sqlerrcode == '42501') {
    if (current_user_id) {
      raise_error(403, 'Unauthorized', 'Insufficient Privileges');
    } else {
      raise_error(401, 'Unauthenticated', 'Insufficient Privileges');
    }
  }

  plv8.elog(ERROR, exception.sqlerrcode);
$$ LANGUAGE plv8;

CREATE FUNCTION settings.get(varchar)
RETURNS varchar
AS $$
  SELECT value
  FROM settings.secrets
  WHERE key = $1
$$ SECURITY DEFINER STABLE LANGUAGE sql;

CREATE FUNCTION settings.set(varchar, varchar)
RETURNS VOID
AS $$
  INSERT INTO settings.secrets (key, value)
  VALUES ($1, $2)
  ON CONFLICT (key) DO UPDATE
  SET value = $2;
$$ SECURITY DEFINER LANGUAGE sql;

CREATE OR REPLACE FUNCTION triggers.domain_ownerships_validate_domain() RETURNS trigger AS $$
var raise_error = plv8.find_function("raise_error");
var [ domain_ownership_verification ] = plv8.execute(`
  SELECT * FROM app.domain_ownership_verifications WHERE id = '${NEW.domain_ownership_verification_id}';
`);

if (!domain_ownership_verification.domain.includes(NEW.domain)) {
  raise_error(500, 'domain_ownerships#domain', 'domain does not match verification');
}

if (NEW.authority_confirmation_method !== domain_ownership_verification.authority_confirmation_method) {
  raise_error(500, 'domain_ownerships#authority_confirmation_method', 'authority_confirmation_method does not match verification');
}

if (domain_ownership_verification.authority_confirmation_status !== "confirmed") {
  raise_error(500, 'domain_ownerships#domain_ownership_verification', 'verification is not confirmed');
}

return NEW;
$$ SECURITY DEFINER STABLE LANGUAGE plv8;

CREATE OR REPLACE FUNCTION triggers.providers_validate_url() RETURNS trigger AS $$
var raise_error = plv8.find_function("raise_error");

if (NEW.url) {
  var result = plv8.execute(`SELECT alias, token FROM ts_debug('${NEW.url}')`).reduce(function(acc, entry) {
    return { ...acc, [entry.alias]: entry.token };
  }, {});

  if (!result.host) {
    raise_error(500, 'providers#url', 'invalid URL', JSON.stringify({ "url": NEW.url }));
  }

  if (NEW.domain) {
    // url has to match domain
    if (!(new RegExp(`^https?\:\/\/${NEW.domain}`)).test(NEW.url)) {
      raise_error(500, 'providers#url', 'URL does not match domain', JSON.stringify({ "url": NEW.url, "domain": NEW.domain }));
    }
  } else {
    // for legacy providers that don't have domain filled in
    NEW.domain = result.host;
  }

} else {
  if (NEW.domain) {
    NEW.url = `https://${NEW.domain}`;
  }
}

var createdAt = (new Date(NEW.created_at)).toISOString();
var DOMAIN_ENFORCEMENT_CUTOFF = '2021-07-01'
var [ { enforce } ] = plv8.execute(`SELECT ('${createdAt}' > '${DOMAIN_ENFORCEMENT_CUTOFF}') AS enforce;`);

if (enforce) {
  if (!NEW.domain) {
    raise_error(500, "providers#domain", "domain cannot be blank");
  }

  if (!NEW.url) {
    raise_error(500, "providers#url", "URL cannot be blank");
  }
}
return NEW;
$$ SECURITY DEFINER STABLE LANGUAGE plv8;

CREATE OR REPLACE FUNCTION triggers.create_provider_organization() RETURNS trigger AS $$
BEGIN
  INSERT INTO app.organizations (
    id,
    provider_id,
    provider_salt_id,
    slug,
    name,
    description,
    kind
  ) VALUES (
    NEW.id,
    NEW.id,
    NEW.id::varchar,
    NEW.slug,
    NEW.name,
    NEW.description,
    'provider'
  );

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE FUNCTION triggers.check_confirmation_status_transition() RETURNS trigger AS $$
BEGIN
  -- illegal transitions
  IF (OLD.authority_confirmation_status = 'confirmed' AND NEW.authority_confirmation_status <> 'confirmed') THEN
    RAISE EXCEPTION 'update failed' USING DETAIL = 'crawler_domain__illegal_transition', HINT = json_build_object('from', OLD.authority_confirmation_status, 'to', NEW.authority_confirmation_status);
  ELSE
    RETURN NEW;
  END IF;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE FUNCTION triggers.check_course_provider_relationship() RETURNS trigger AS $$
BEGIN
  IF (NEW.course_id IS NOT NULL) THEN
    IF (NEW.provider_id IS NOT NULL) THEN
      IF (SELECT provider_id FROM app.courses WHERE id = NEW.course_id) <> NEW.provider_id THEN
        RAISE EXCEPTION 'update failed' USING DETAIL = 'course_provider__do_not_match', HINT = json_build_object('course_id', NEW.course_id, 'provider_id', NEW.provider_id);
      END IF;
    ELSE
      NEW.provider_id := (SELECT provider_id FROM app.courses WHERE id = NEW.course_id);
    END IF;
  END IF;

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE FUNCTION triggers.course_flatten_pricing_models() RETURNS trigger AS $$
DECLARE
  price jsonb;
BEGIN
  DELETE FROM app.course_pricings WHERE course_id = NEW.id;

  IF (NEW.__source_schema__::jsonb)->'content'->>'prices' IS NOT NULL THEN
    FOR price IN SELECT * FROM jsonb_array_elements((NEW.__source_schema__->'content'->>'prices')::jsonb)
    LOOP
      PERFORM app.insert_into_course_pricings(NEW.id, price);
    END LOOP;
  END IF;
  NEW.__source_schema__ = NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.course_keep_slug() RETURNS trigger AS $$
BEGIN
  IF (NEW.published = false) THEN
    RETURN NEW;
  END IF;

  INSERT INTO app.slug_histories (
    course_id, slug
  ) VALUES (
    NEW.id, NEW.slug
  ) ON CONFLICT DO NOTHING;

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE FUNCTION triggers.course_normalize_languages() RETURNS trigger AS $$
BEGIN
  NEW.audio     = app.normalize_languages(NEW.audio);
  NEW.subtitles_text = app.normalize_languages(NEW.subtitles_text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.create_wallet() RETURNS trigger AS $$
BEGIN
  INSERT INTO app.wallets (user_account_id) VALUES (NEW.id);
  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION triggers.create_course_instructors() RETURNS trigger AS $$
DECLARE
  _instructor jsonb;
BEGIN
  IF
    (
      TG_OP = 'UPDATE' AND
      (
        ( NEW.instructors IS NULL AND OLD.instructors IS NULL ) OR
        ( NEW.instructors = '[]'  AND OLD.instructors = '[]'  )
      )
  ) THEN
    RETURN NEW;
  END IF;

  FOR _instructor IN
    SELECT jsonb_array_elements(NEW.instructors)
  LOOP
    IF app.provider_uuid_generate(NEW.provider_id, _instructor->>'id', _instructor->>'name') IS NOT NULL THEN
      INSERT INTO app.instructors (
        id,
        provider_id,
        provider_salt_id,
        slug,
        name
      ) VALUES (
        app.provider_uuid_generate(NEW.provider_id, _instructor->>'id', _instructor->>'name'),
        NEW.provider_id,
        COALESCE(_instructor->>'id', _instructor->>'name'),
        transliterate.slugify(
          app.provider_uuid_generate(NEW.provider_id, _instructor->>'id', _instructor->>'name')
          || '-'
          || COALESCE(_instructor->>'slug', app.normalize_name(_instructor->>'name'))
        ),
        app.normalize_name(_instructor->>'name')
      ) ON CONFLICT  (
        id
      ) DO UPDATE SET
        provider_id      = EXCLUDED.provider_id,
        provider_salt_id = EXCLUDED.provider_salt_id,
        name             = EXCLUDED.name;
    END IF;
  END LOOP;

  INSERT INTO app.offered_by (
    course_id, offeror_id, offeror_type, role
  ) SELECT DISTINCT
      NEW.id,
      app.provider_uuid_generate(NEW.provider_id, params->>'id', params->>'name'),
      'instructor'::app.offeror_type,
      COALESCE(params->>'role', 'owner')::app.offered_role
    FROM jsonb_array_elements(NEW.instructors) AS params
    WHERE app.provider_uuid_generate(NEW.provider_id, params->>'id', params->>'name') IS NOT NULL
  ON CONFLICT  (
    course_id, offeror_id, offeror_type
  ) DO UPDATE SET role = EXCLUDED.role;

  IF TG_OP = 'UPDATE' THEN
    WITH deleted_instructor_ids AS (
      SELECT
        app.provider_uuid_generate(
          NEW.provider_id, old_params->>'id', old_params->>'name'
        ) AS instructor_id
      FROM      jsonb_array_elements(NEW.instructors) AS new_params
      LEFT JOIN jsonb_array_elements(OLD.instructors) AS old_params ON
        app.provider_uuid_generate(
          NEW.provider_id, old_params->>'id', old_params->>'name'
        ) = app.provider_uuid_generate(
          NEW.provider_id, new_params->>'id', new_params->>'name'
        )
      WHERE
        old_params->>'id'   IS NULL AND
        old_params->>'name' IS NULL
    )

    DELETE FROM app.offered_by
    USING deleted_instructor_ids
    WHERE
      course_id    = NEW.id                         AND
      offeror_type = 'instructor'::app.offeror_type AND
      offeror_id   = deleted_instructor_ids.instructor_id;
  END IF;

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.create_subscription() RETURNS trigger AS $$
BEGIN
  INSERT INTO app.subscriptions (profile_id) VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.create_redeem_transaction() RETURNS trigger AS $$
DECLARE
  min_amount numeric;
  wallet_balance numeric;
BEGIN
  SELECT minimum_redeemable_amount INTO min_amount FROM settings.global;

  SELECT SUM(amount) INTO wallet_balance
  FROM app.wallets
  INNER JOIN app.wallet_transactions ON app.wallet_transactions.wallet_id = app.wallets.id
  WHERE user_account_id = NEW.user_account_id;

  IF wallet_balance >= min_amount THEN
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'Insufficient funds. To create a redeem record you need a minimum of %', min_amount;
  END IF;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.approve_redeem_transaction() RETURNS trigger AS $$
DECLARE
  wallet_balance numeric;
  min_amount numeric;
  wallet_id uuid;
BEGIN

  SELECT minimum_redeemable_amount INTO min_amount FROM settings.global;

  SELECT SUM(amount) INTO wallet_balance
  FROM app.wallets
  INNER JOIN app.wallet_transactions ON app.wallet_transactions.wallet_id = app.wallets.id
  WHERE user_account_id = NEW.user_account_id;

	SELECT id INTO wallet_id FROM app.wallets WHERE user_account_id = NEW.user_account_id;

  IF NEW.status = 'approved' AND wallet_balance >= min_amount THEN
    INSERT INTO app.wallet_transactions (
      wallet_id,
      amount,
      transactionable_type,
      transactionable_id
    ) VALUES (
      wallet_id,
      (wallet_balance * -1),
      'Redeem',
      NEW.id
    );
  END IF;
  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.create_study_list() RETURNS trigger AS $$
BEGIN
  INSERT INTO app.study_lists (user_account_id, standard, name, slug) VALUES (NEW.id, true, 'Default', 'default');
  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

-- pgFormatter-ignore
CREATE OR REPLACE FUNCTION triggers.create_wallet_transaction() RETURNS trigger AS $$
DECLARE
  earnable_coins smallint;
  wallet_id uuid;
BEGIN

  SELECT app.enrollments.earnable_coins, app.wallets.id INTO earnable_coins, wallet_id FROM app.enrollments
  INNER JOIN app.user_accounts ON app.enrollments.user_account_id = app.user_accounts.id
  INNER JOIN app.wallets ON app.user_accounts.id = app.wallets.user_account_id
  WHERE app.enrollments.id = NEW.enrollment_id;

  IF wallet_id IS NOT NULL AND earnable_coins <> 0 AND earnable_coins IS NOT NULL THEN
    INSERT INTO app.wallet_transactions (
      wallet_id,
      amount,
      locked_until,
      transactionable_type,
      transactionable_id
    ) VALUES (
      wallet_id,
      (NOW() + interval '45 days'),
      (earnable_coins * SIGN(NEW.earnings_amount)),
      'Enrollment',
      NEW.enrollment_id
    );
  END IF;

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE FUNCTION triggers.encrypt_password() RETURNS trigger
AS $$
BEGIN
  IF NEW.encrypted_password ~* '^\$\d\w\$\d{2}\$[^$]{53}$' THEN
    RETURN NEW;
  END IF;

  IF tg_op = 'INSERT' OR NEW.encrypted_password <> OLD.encrypted_password THEN
    NEW.encrypted_password = crypt(NEW.encrypted_password, gen_salt('bf', 11));
  END IF;

  RETURN NEW;
end
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.forbid() RETURNS trigger AS $$
BEGIN
  PERFORM raise_error(403);

  return NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.gen_compound_ext_id() RETURNS trigger AS $$
BEGIN
  NEW.compound_ext_id = concat(NEW.source,'_',NEW.ext_id);
  return NEW;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.generate_slug_from_name() RETURNS trigger AS $$
BEGIN
  NEW.slug = COALESCE(NEW.slug, transliterate.slugify(NEW.name));
  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.geolocate_record()
RETURNS trigger
AS $$
BEGIN

  -- Enrollment, UserAccount

  IF NEW.tracking_data->>'ip'                    IS NOT NULL AND
     NEW.tracking_data->>'country'               IS NULL AND
     (NEW.tracking_data->>'geolocated')::boolean IS NOT TRUE
  THEN

    PERFORM app.enqueue_job(
      'IpGeolocateJob',
      ('["' || TG_ARGV[0] || '","' || NEW.id || '"]')::jsonb
    );

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.insert_or_add_to_provider() RETURNS trigger AS $$
DECLARE
  _provider        app.providers%ROWTYPE;
  _new_provider_id uuid;
BEGIN
  SELECT * FROM app.providers INTO _provider where providers.name = NEW.__provider_name__;
  IF (NOT FOUND) THEN
    INSERT INTO app.providers (name, published, created_at, updated_at) VALUES (NEW.__provider_name__, false, NOW(), NOW()) RETURNING id INTO _new_provider_id;
    NEW.published = false;
    NEW.provider_id = _new_provider_id;
  ELSE
    NEW.provider_id = _provider.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- CREATE FUNCTION triggers.md5_url() RETURNS trigger AS $$
-- BEGIN
--   NEW.url_md5=md5(NEW.url);
--   return NEW;
-- END
-- $$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.set_content_digest() RETURNS trigger AS $$
  DECLARE
    digest varchar;
  BEGIN
    digest = md5(concat(NEW.body,NEW.title));
  IF OLD.content_digest <> digest THEN
    NEW.content_digest = digest;
    NEW.content_changed_at = NOW();
  END IF;
  return NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.set_default_cover_image() RETURNS trigger AS $$
  DECLARE
    image_id uuid;
  BEGIN
    SELECT id FROM app.images WHERE imageable_id = NEW.id ORDER BY pos, created_at ASC LIMIT 1 INTO image_id;
    IF OLD.cover_image_id IS NULL AND NEW.cover_image_id IS NULL THEN
      NEW.cover_image_id = image_id;
    END IF;
    return NEW;
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.preview_course_flatten_pricing_models() RETURNS trigger AS $$
DECLARE
  price jsonb;
BEGIN
  IF (NEW.__source_schema__::jsonb)->'content'->>'prices' IS NOT NULL THEN
    FOR price IN SELECT * FROM jsonb_array_elements((NEW.__source_schema__->'content'->>'prices')::jsonb)
    LOOP
      PERFORM app.insert_into_preview_course_pricings(NEW.id, price);
    END LOOP;
  END IF;
  NEW.__source_schema__ = NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION triggers.track_updated_at() RETURNS trigger
AS $$
BEGIN
  IF NEW.updated_at IS NULL THEN
    NEW.updated_at := OLD.updated_at;
  ELSE
    IF NEW.updated_at = OLD.updated_at THEN
      NEW.updated_at := NOW();
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.use_username() RETURNS trigger
AS $$
BEGIN
  IF (TG_OP = 'INSERT' AND NEW.username IS NULL) THEN
    RAISE EXCEPTION 'username update failed' USING DETAIL = 'username__cannot_be_null';
  END IF;

  IF (TG_OP = 'UPDATE' AND OLD.username IS NULL AND NEW.username IS NULL) THEN
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' AND OLD.username IS NOT NULL AND NEW.username IS NULL THEN
    RAISE EXCEPTION 'username update failed' USING DETAIL = 'username__cannot_be_erased';
  END IF;

  IF ((TG_OP = 'INSERT' OR (TG_OP = 'UPDATE' AND OLD.username IS NULL)) AND NEW.username IS NOT NULL) OR
     (TG_OP = 'UPDATE' AND OLD.username IS NOT NULL AND NEW.username IS NOT NULL AND OLD.username <> NEW.username) THEN

    IF TG_OP = 'UPDATE' AND OLD.username_changed_at IS NOT NULL AND
      (NOW() - OLD.username_changed_at < '15 days'::interval) THEN
      RAISE EXCEPTION 'username update failed' USING DETAIL = 'username__change_within_update_threshold', HINT = json_build_object('threshold', '15');
    ELSE
      UPDATE app.profiles SET username_changed_at = NOW() WHERE id = NEW.id;
    END IF;

    INSERT INTO app.used_usernames (profile_id, username) VALUES (NEW.id, NEW.username);

    RETURN NEW;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_profiles() RETURNS trigger AS $$
DECLARE
  _platform     text;
  _url          text;
  _host         text;
  _url_path     text;
  _id           text;
  _path_pattern text;
BEGIN
  -- social profiles
  IF (
      NEW.social_profiles IS NOT NULL AND
      NEW.social_profiles <> '{}'
    ) THEN

    FOR _platform, _url IN
       SELECT * FROM jsonb_each_text(NEW.social_profiles)
    LOOP
      WITH parsed AS (
        SELECT alias, token FROM ts_debug(_url)
      )
      SELECT (SELECT token FROM parsed WHERE alias = 'host') AS host,
              (SELECT token FROM parsed WHERE alias = 'url_path') AS url_path
        INTO _host, _url_path;

      IF (_host IS NULL) OR (_url_path IS NULL) THEN
        RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_uri', HINT = json_build_object('value', _url);
      END IF;

      CASE _platform
      WHEN 'behance' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF (_host <> 'behance.net') OR
           (_path_pattern <> '/') OR
           (_id !~ '^(?!.*(?:\/))(?:[A-z\d\-_]){3,20}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'dribbble' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF (_host <> 'dribbble.com') OR
           (_path_pattern <> '/') OR
           (_id !~ '^(?!.*(?:\/))(?:[A-z\d\-_]){2,20}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'facebook' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'facebook.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))(?:(?:(?:[A-z\d])(?:[A-z\d]|[.-](?=[A-z\d])){4,50})|(?:\d{15}))$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'github' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'github.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))[A-z\d](?:[A-z\d]|-(?=[A-z\d])){0,38}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'instagram' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'instagram.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))([A-z\d._](?:(?:[A-z\d._]|(?:\.(?!\.))){2,28}(?:[A-z\d._]))?)$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'linkedin' THEN
        -- /in/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/in/'));
        _id := SUBSTR(_url_path, LENGTH('/in/') + 1);

        IF  (_host <> 'linkedin.com') OR
            (_path_pattern <> '/in/') OR
            (_id !~ '^(?!.*(?:\/))[A-zÀ-ÿ\d](?:[A-zÀ-ÿ\d]|-(?=[A-zÀ-ÿ\d])){2,99}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'pinterest' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'pinterest.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))[A-z\d](?:[A-z\d]|_){2,29}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'reddit' THEN
        -- /user/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/user/'));
        _id := SUBSTR(_url_path, LENGTH('/user/') + 1);

        IF  (_host <> 'reddit.com') OR
            (_path_pattern <> '/user/') OR
            (_id !~ '^(?!.*(?:\/))(?:[A-z\d\-_]){3,20}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'soundcloud' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'soundcloud.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))(?:[a-z\d](?:[a-z\d]|[-_](?=[a-z\d])){2,24})$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'twitter' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'twitter.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))[A-z\d_]{4,15}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'youtube' THEN
        -- /channel/UCasdjfsafkjasdkflj
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/channel/'));
        _id := SUBSTR(_url_path, LENGTH('/channel/') + 1);

        IF  (_host <> 'youtube.com') OR
            (_path_pattern <> '/channel/') OR
            (_id !~ '^(?!.*(?:\/))UC(?:[A-z\d_-]){22}$') THEN
          RAISE EXCEPTION 'social_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      ELSE
        NULL;
      END CASE;
    END LOOP;
  END IF;

  -- elearning profiles
  IF (
      NEW.elearning_profiles IS NOT NULL AND
      NEW.elearning_profiles <> '{}'
    ) THEN

    FOR _platform, _url IN
       SELECT * FROM jsonb_each_text(NEW.elearning_profiles)
    LOOP
      WITH parsed AS (
        SELECT alias, token FROM ts_debug(_url)
      )
      SELECT (SELECT token FROM parsed WHERE alias = 'host') AS host,
              (SELECT token FROM parsed WHERE alias = 'url_path') AS url_path
        INTO _host, _url_path;

      IF (_host IS NULL) OR (_url_path IS NULL) THEN
        RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_uri', HINT = json_build_object('value', _url);
      END IF;

      CASE _platform
      WHEN 'linkedin_learning' THEN
        -- /learning/instructors/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/learning/instructors/'));
        _id := SUBSTR(_url_path, LENGTH('/learning/instructors/') + 1);

        IF  (_host <> 'linkedin.com') OR
            (_path_pattern <> '/learning/instructors/') OR
            (_id !~ '^(?!.*(?:\/))[a-z\d](?:[a-z\d]|-(?=[a-z\d])){2,}$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'masterclass' THEN
        -- /classes/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/classes/'));
        _id := SUBSTR(_url_path, LENGTH('/classes/') + 1);

        IF  (_host <> 'masterclass.com') OR
            (_path_pattern <> '/classes/') OR
            (_id !~ '^(?!.*(?:\/))(?:[a-z\d](?:[a-z\d]|-(?=[a-z\d])){9,})$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'pluralsight' THEN
        -- /authors/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/authors/'));
        _id := SUBSTR(_url_path, LENGTH('/authors/') + 1);

        IF  (_host <> 'pluralsight.com') OR
            (_path_pattern <> '/authors/') OR
            (_id !~ '^(?!.*(?:\/))[a-z\d](?:[a-z\d]|-(?=[a-z\d])){4,}$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'skillshare' THEN
        -- /user/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/user/'));
        _id := SUBSTR(_url_path, LENGTH('/user/') + 1);

        IF  (_host <> 'skillshare.com') OR
            (_path_pattern <> '/user/') OR
            (_id !~ '^(?!.*(?:\/))(?:[a-z\d\-_]{3,30})$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'treehouse' THEN
        -- /thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, 1);
        _id := SUBSTR(_url_path, 2);

        IF  (_host <> 'teamtreehouse.com') OR
            (_path_pattern <> '/') OR
            (_id !~ '^(?!.*(?:\/))(?:[a-z]{3,30})$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      WHEN 'udemy' THEN
        -- /user/thiagobrandam
        _path_pattern := SUBSTR(_url_path, 1, LENGTH('/user/'));
        _id := SUBSTR(_url_path, LENGTH('/user/') + 1);

        IF  (_host <> 'udemy.com') OR
            (_path_pattern <> '/user/') OR
            (_id !~ '^(?!.*(?:\/))[a-z\d\-_]{3,60}$') THEN
          RAISE EXCEPTION 'elearning_profiles update failed' USING DETAIL = 'public_profile__invalid_format', HINT = json_build_object('platform', _platform);
        END IF;
      ELSE
        NULL;
      END CASE;
    END LOOP;
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_promotion() RETURNS trigger AS $$
DECLARE
  locales app.locale[];
  subdomains app.locale[];
  existing_subdomains integer;
BEGIN
  SELECT settings.global.subdomains FROM settings.global LIMIT 1 INTO locales;
  SELECT ARRAY_AGG(DISTINCT f ORDER BY f) FROM UNNEST(NEW.active_subdomains) f INTO subdomains;

  -- valid states
  IF NEW.status IS NOT NULL AND NEW.status NOT IN ('initial','enabled','disabled','expired','awaiting') THEN
    RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'status__invalid', HINT = json_build_object('status', NEW.status);
  END IF;

  -- valid name
  IF LENGTH(NEW.name) = 0 THEN
    RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'name__too_short', HINT = json_build_object('name', NEW.name);
  END IF;

  -- active_subdomains
  IF subdomains IS NULL OR ARRAY_LENGTH(subdomains, 1) = 0 THEN
    subdomains := locales;
  END IF;

  IF NOT (subdomains && locales) THEN
    RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'active_subdomains__invalid', HINT = json_build_object('active_subdomains', subdomains, 'locales', locales);
  END IF;

  -- check for existing overlapping active_subdomains in running promotions
  SELECT COUNT(*) FROM (
    SELECT UNNEST(active_subdomains) AS subdomain FROM app.promotions WHERE status IN ('enabled', 'awaiting') AND provider_id = NEW.provider_id AND id <> NEW.id
  ) asub WHERE subdomain = ANY(subdomains) INTO existing_subdomains;

  IF TG_OP = 'INSERT' THEN
    -- initial is an impossible state
    -- expired can only be reached through update
    IF NEW.status = 'expired' OR NEW.status = 'initial' THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'status__invalid', HINT = json_build_object('status', NEW.status);
    END IF;

    -- ending cannot be set to the past
    IF NEW.ends_at < NOW() THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'ends_at__invalid', HINT = json_build_object('ends_at', NEW.ends_at);
    END IF;

    -- ending cannot be set to before the beginning
    IF NEW.ends_at <= NEW.starts_at THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'ends_at__invalid', HINT = json_build_object('ends_at', NEW.ends_at);
    END IF;

    IF existing_subdomains > 0 AND NEW.status IN ('enabled', 'awaiting') THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'active_subdomains__invalid', HINT = json_build_object('active_subdomains', subdomains, 'locales', locales);
    END IF;

    -- subdomains is uniqued and sorted
    NEW.active_subdomains = subdomains;

    -- if created status with awaiting but already began, create enabled instead
    IF NEW.status = 'awaiting' AND NEW.starts_at < NOW() THEN
      NEW.status = 'enabled';
    END IF;

    -- if created status with enabled but cannot begin yet, create enabled awaiting
    IF NEW.status = 'enabled' AND NEW.starts_at > NOW() THEN
      NEW.status = 'awaiting';
    END IF;

    IF NEW.status IS NULL THEN
      IF NEW.starts_at > NOW() THEN
        NEW.status = 'awaiting';
      ELSE
        NEW.status = 'enabled';
      END IF;
    END IF;

    IF NEW.status = 'enabled' THEN
      NEW.enabled_at = NOW();
    END IF;

    IF NEW.status = 'disabled' THEN
      NEW.disabled_at = NOW();
    END IF;

    IF NEW.status = 'expired' THEN
      NEW.expired_at = NOW();
    END IF;

    IF NEW.status = 'awaiting' THEN
      NEW.awaiting_at = NOW();
    END IF;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    -- cannot change expired
    IF OLD.status = 'expired' THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'updated__invalid', HINT = json_build_object('old_status', OLD.status, 'new_status', NEW.status);
    END IF;

    -- cannot nullify status
    IF OLD.status IS NOT NULL AND NEW.status IS NULL THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'transition__invalid', HINT = json_build_object('old_status', OLD.status, 'new_status', NEW.status);
    END IF;

    -- cannot transition to initial
    IF OLD.status <> 'initial' AND NEW.status = 'initial' THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'transition__invalid', HINT = json_build_object('old_status', OLD.status, 'new_status', NEW.status);
    END IF;

    -- cannot transition to awaiting
    IF OLD.status <> 'awaiting' AND NEW.status = 'awaiting' THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'transition__invalid', HINT = json_build_object('old_status', OLD.status, 'new_status', NEW.status);
    END IF;

    -- can only transition from disabled to enabled if promotion is running
    IF OLD.status = 'disabled' AND NEW.status = 'enabled' AND OLD.ends_at < NOW() THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'transition__invalid', HINT = json_build_object('old_status', OLD.status, 'new_status', NEW.status);
    END IF;

    -- ending cannot be set to the past
    IF OLD.ends_at <> NEW.ends_at AND NEW.ends_at < NOW() THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'ends_at__invalid', HINT = json_build_object('ends_at', NEW.ends_at);
    END IF;

    -- ending cannot be set to before the beginning
    IF OLD.starts_at <> NEW.starts_at AND NEW.ends_at <= NEW.starts_at THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'ends_at__invalid', HINT = json_build_object('ends_at', NEW.ends_at);
    END IF;

    IF existing_subdomains > 0 AND OLD.status NOT IN ('enabled', 'awaiting') AND NEW.status IN ('enabled', 'awaiting') THEN
      RAISE EXCEPTION '% ON % FAILURE', TG_OP, TG_TABLE_NAME USING DETAIL = 'active_subdomains__invalid', HINT = json_build_object('active_subdomains', subdomains, 'locales', locales);
    END IF;

    -- don't let active_subdomains be updated if campaign is disabled
    IF OLD.status IN ('awaiting', 'enabled') AND NEW.status IN ('disabled') THEN
      NEW.active_subdomains =  OLD.active_subdomains;
    END IF;

    IF OLD.status <> NEW.status AND NEW.status = 'enabled' THEN
      NEW.enabled_at = NOW();
    END IF;

    IF OLD.status <> NEW.status AND NEW.status = 'disabled' THEN
      NEW.disabled_at = NOW();
    END IF;

    IF OLD.status <> NEW.status AND NEW.status = 'expired' THEN
      NEW.expired_at = NOW();
    END IF;

    IF OLD.status <> NEW.status AND NEW.status = 'awaiting' THEN
      NEW.awaiting_at = NOW();
    END IF;
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_provider_crawler_urls() RETURNS trigger AS $$
DECLARE
  result boolean;
BEGIN
  IF NEW.urls = OLD.urls THEN
    RETURN NEW;
  END IF;

  IF array_length(NEW.urls, 1) > 50 THEN
    RAISE EXCEPTION 'Invalid URLs' USING HINT = 'urls must have at most 20 elements';
  END IF;

  result = NOT EXISTS (
    SELECT 1 FROM unnest(NEW.urls) AS url
    WHERE NOT EXISTS (
      SELECT 1 FROM app.crawler_domains
      WHERE
        provider_crawler_id = NEW.id
        AND authority_confirmation_status = 'confirmed'
        AND url ~ ('^https?://([a-z0-9\-\_]+\.)*' || regexp_replace(domain, '^www.', '') || '(:\d+)?/')
    )
  );

  IF result = false THEN
    RAISE EXCEPTION 'Invalid URLs' USING HINT = 'All URLs must have verified domains';
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_sitemaps() RETURNS trigger AS $$
DECLARE
  result boolean;
BEGIN
  IF NEW.sitemaps = OLD.sitemaps THEN
    RETURN NEW;
  END IF;

  result = NOT EXISTS (
    SELECT 1 FROM unnest(NEW.sitemaps) AS sitemap
    WHERE NOT EXISTS (
      SELECT 1 FROM app.crawler_domains
      WHERE
        provider_crawler_id = NEW.id
        AND authority_confirmation_status = 'confirmed'
        AND sitemap.url ~ ('^https?://([a-z0-9\-\_]+\.)*' || regexp_replace(domain, '^www.', '') || '(:\d+)?/')
    )
  );

  IF result = false THEN
    RAISE EXCEPTION 'Invalid sitemaps' USING HINT = 'All sitemaps must have verified domains';
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_user_account_ids() RETURNS trigger AS $$
DECLARE
  result boolean;
BEGIN
  IF NEW.user_account_ids = OLD.user_account_ids THEN
    RETURN NEW;
  END IF;

  result = NOT EXISTS (
    SELECT 1 FROM unnest(NEW.user_account_ids) AS provider_user_account_id
    WHERE NOT EXISTS (
      SELECT 1 FROM app.user_accounts
      WHERE
        provider_user_account_id = app.user_accounts.id
    )
  );

  IF result = false THEN
    RAISE EXCEPTION 'Invalid user_account_ids' USING HINT = 'All user account ids must exists';
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.validate_website() RETURNS trigger AS $$
DECLARE
  _protocol text;
  _host     text;
BEGIN
  IF ( NEW.website IS NOT NULL ) THEN
    WITH parsed AS (
      SELECT alias, token FROM ts_debug(NEW.website)
    )
    SELECT (SELECT token FROM parsed WHERE alias = 'protocol') AS host,
            (SELECT token FROM parsed WHERE alias = 'host') AS url_path
      INTO _protocol, _host;

    IF (_protocol IS NULL) OR (_host IS NULL) THEN
      RAISE EXCEPTION 'website update failed' USING DETAIL = 'website__invalid_uri', HINT = json_build_object('value', NEW.website);
    END IF;
  END IF;

  RETURN NEW;
END;
$$ SECURITY DEFINER STABLE LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION triggers.create_course_organizations() RETURNS trigger AS $$
DECLARE
  _organization jsonb;
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO app.offered_by (
      course_id, offeror_id, offeror_type, role
    ) VALUES (
      NEW.id,
      NEW.provider_id,
      'organization',
      'owner'
    );
  END IF;

  IF
    (
      TG_OP = 'UPDATE' AND
      (
        ( NEW.offered_by IS NULL AND OLD.offered_by IS NULL ) OR
        ( NEW.offered_by = '[]'  AND OLD.offered_by = '[]'  )
      )
  ) THEN
    RETURN NEW;
  END IF;

  FOR _organization IN
    SELECT
      org
    FROM jsonb_array_elements(NEW.offered_by) AS org
    WHERE org->>'type' IS NULL OR org->>'type' != 'instructor'
  LOOP
    IF app.provider_uuid_generate(NEW.provider_id, _organization->>'id', _organization->>'name') IS NOT NULL THEN
      INSERT INTO app.organizations (
        id,
        provider_id,
        provider_salt_id,
        slug,
        name,
        kind
      ) VALUES (
        app.provider_uuid_generate(NEW.provider_id, _organization->>'id', _organization->>'name'),
        NEW.provider_id,
        COALESCE(_organization->>'id', _organization->>'name'),
        transliterate.slugify(
          app.provider_uuid_generate(NEW.provider_id, _organization->>'id', _organization->>'name')
          || '-'
          || COALESCE(_organization->>'slug', app.normalize_name(_organization->>'name'))
        ),
        app.normalize_name(_organization->>'name'),
        (COALESCE(_organization->>'type', 'company'))::app.organization_type
      ) ON CONFLICT  (
        id
      ) DO UPDATE SET
        provider_id      = EXCLUDED.provider_id,
        provider_salt_id = EXCLUDED.provider_salt_id,
        name             = EXCLUDED.name,
        kind             = EXCLUDED.kind;
    END IF;
  END LOOP;

  INSERT INTO app.offered_by (
    course_id, offeror_id, offeror_type, role
  ) SELECT DISTINCT
      NEW.id,
      app.provider_uuid_generate(NEW.provider_id, params->>'id', params->>'name'),
      'organization'::app.offeror_type,
      COALESCE(params->>'role', 'owner')::app.offered_role
    FROM jsonb_array_elements(NEW.offered_by) AS params
    WHERE (params->>'type' IS NULL OR params->>'type' != 'instructor') AND app.provider_uuid_generate(NEW.provider_id, params->>'id', params->>'name') IS NOT NULL
  ON CONFLICT  (
    course_id, offeror_id, offeror_type
  ) DO UPDATE SET role = EXCLUDED.role;

  IF TG_OP = 'UPDATE' THEN
    WITH deleted_organization_ids AS (
      SELECT
        app.provider_uuid_generate(
          NEW.provider_id, old_params->>'id', old_params->>'name'
        ) AS organization_id
      FROM      jsonb_array_elements(NEW.offered_by) AS new_params
      LEFT JOIN jsonb_array_elements(OLD.offered_by) AS old_params ON
        app.provider_uuid_generate(
          NEW.provider_id, old_params->>'id', old_params->>'name'
        ) = app.provider_uuid_generate(
          NEW.provider_id, new_params->>'id', new_params->>'name'
        )
      WHERE
        old_params->>'id'   IS NULL AND
        old_params->>'name' IS NULL
    )

    DELETE FROM app.offered_by
    USING deleted_organization_ids
    WHERE
      course_id    = NEW.id                           AND
      offeror_type = 'organization'::app.offeror_type AND
      offeror_id   = deleted_organization_ids.organization_id;
  END IF;

  RETURN NEW;
END
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE TRIGGER encrypt_password
  BEFORE INSERT OR UPDATE
  ON app.admin_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.encrypt_password();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.admin_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.admin_profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.certificates
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.contacts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.course_reviews
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER create_course_instructors
  AFTER INSERT OR UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.create_course_instructors ();

CREATE TRIGGER create_course_organizations
  AFTER INSERT OR UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.create_course_organizations ();

CREATE TRIGGER course_normalize_languages
  BEFORE INSERT OR UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.course_normalize_languages ();

CREATE TRIGGER course_flatten_pricing_models
  AFTER INSERT OR UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.course_flatten_pricing_models ();

CREATE TRIGGER course_keep_slug
  AFTER INSERT OR UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.course_keep_slug ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.courses
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.crawler_domains
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER check_confirmation_status_transition
  BEFORE INSERT OR UPDATE
  ON app.crawler_domains
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.check_confirmation_status_transition();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.crawling_events
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.direct_uploads
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.domain_ownerships
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER domain_ownerships_validate_domain
  BEFORE INSERT OR UPDATE ON app.domain_ownerships
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.domain_ownerships_validate_domain ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.domain_ownership_verifications
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.enrollments
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER check_course_provider_relationship
  BEFORE INSERT OR UPDATE
  ON app.enrollments
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.check_course_provider_relationship();

CREATE TRIGGER geolocate_ip
  AFTER INSERT OR UPDATE
  ON app.enrollments
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.geolocate_record('Enrollment');

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.favorites
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.images
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.landing_pages
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.oauth_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.orphaned_profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.posts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER set_content_digest
  BEFORE INSERT OR UPDATE
  ON app.posts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.set_content_digest();

CREATE TRIGGER set_default_cover_image
  BEFORE INSERT OR UPDATE
  ON app.posts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.set_default_cover_image();


CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.preview_course_images
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.preview_courses
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER course_normalize_languages
  BEFORE INSERT OR UPDATE
  ON app.preview_courses
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.course_normalize_languages();

CREATE TRIGGER preview_course_flatten_pricing_models
  AFTER INSERT OR UPDATE
  ON app.preview_courses
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.preview_course_flatten_pricing_models();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER use_username
  AFTER INSERT OR UPDATE
  ON app.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.use_username();

CREATE TRIGGER validate_profiles
  BEFORE INSERT OR UPDATE
  ON app.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.validate_profiles();

CREATE TRIGGER validate_website
  BEFORE INSERT OR UPDATE
  ON app.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.validate_website();

CREATE TRIGGER create_profiles_subscription
  AFTER INSERT
  ON app.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.create_subscription();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.promo_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.promotions
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER validate_promotion
  BEFORE INSERT OR UPDATE ON app.promotions
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.validate_promotion ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE CONSTRAINT TRIGGER validate_user_account_ids
  AFTER INSERT OR UPDATE
  ON app.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.validate_user_account_ids();

CREATE CONSTRAINT TRIGGER validate_sitemaps
  AFTER INSERT OR UPDATE
  ON app.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.validate_sitemaps();

CREATE CONSTRAINT TRIGGER validate_provider_crawler_urls
  AFTER INSERT OR UPDATE
  ON app.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.validate_provider_crawler_urls();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.providers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER validate_url
  BEFORE INSERT OR UPDATE
  ON app.providers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.providers_validate_url();

CREATE TRIGGER create_provider_organization
  AFTER INSERT
  ON app.providers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.create_provider_organization();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.provider_ownership_creations
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE ON app.provider_ownerships
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.track_updated_at ();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.slug_histories
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.study_lists
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER generate_slug
  BEFORE INSERT
  ON app.study_lists
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.generate_slug_from_name();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.study_list_entries
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();



CREATE TRIGGER set_compound_ext_id
  BEFORE INSERT
  ON app.tracked_actions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.gen_compound_ext_id();

CREATE TRIGGER create_wallet_transaction
  BEFORE INSERT
  ON app.tracked_actions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.create_wallet_transaction();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.tracked_actions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER encrypt_password
  BEFORE INSERT OR UPDATE
  ON app.user_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.encrypt_password();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.user_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER create_wallet
  AFTER INSERT
  ON app.user_accounts
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.create_wallet();

CREATE TRIGGER create_study_list
  AFTER INSERT
  ON app.user_accounts
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.create_study_list();

CREATE TRIGGER geolocate_ip
  AFTER INSERT OR UPDATE
  ON app.user_accounts
  FOR EACH ROW
  EXECUTE PROCEDURE triggers.geolocate_record('UserAccount');

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.instructors
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.organizations
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER create_redeem_transaction
  BEFORE INSERT
  ON app.redeems
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.create_redeem_transaction();

CREATE TRIGGER approve_redeem_transaction
  BEFORE UPDATE
  ON app.redeems
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.approve_redeem_transaction();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.redeems
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();


CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.wallets
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();


CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON app.wallet_transactions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON public.ar_internal_metadata
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER que_job_notify
  AFTER INSERT
  ON public.que_jobs
  FOR EACH ROW
    EXECUTE PROCEDURE public.que_job_notify();

CREATE TRIGGER que_state_notify
  AFTER INSERT OR DELETE OR UPDATE
  ON public.que_jobs
  FOR EACH ROW
    EXECUTE PROCEDURE public.que_state_notify();

CREATE MATERIALIZED VIEW app.provider_pricings AS (
  SELECT  app.courses.provider_id,
          ARRAY_AGG(DISTINCT app.course_pricings.pricing_type) AS membership_types,
          MIN(CASE WHEN app.course_pricings.pricing_type = 'single_course' THEN app.course_pricings.price ELSE app.course_pricings.total_price END) AS min_price,
          MAX(CASE WHEN app.course_pricings.pricing_type = 'single_course' THEN app.course_pricings.price ELSE app.course_pricings.total_price END) AS max_price,
          (MIN(app.course_pricings.trial_period_value) IS NOT NULL) AS has_trial,
          app.course_pricings.currency
  FROM app.courses
  INNER JOIN app.course_pricings ON app.course_pricings.course_id = app.courses.id
  WHERE app.courses.published = 't'
  GROUP BY provider_id, currency
);

CREATE MATERIALIZED VIEW app.instructor_courses AS (
  WITH RECURSIVE instructor_parents(parent_id, child_id) AS (
    SELECT id, id
    FROM app.instructors
  UNION
    SELECT instructor_parents.parent_id, instructors.id
    FROM app.instructors
    INNER JOIN instructor_parents ON
      instructor_parents.parent_id = instructors.canonical_id
  )
  SELECT
    instructor_parents.parent_id AS instructor_id,
    offered_by.course_id         AS course_id,
    offered_by.role              AS role
  FROM instructor_parents
  INNER JOIN app.offered_by ON
    offered_by.deleted_at IS NULL          AND
    offered_by.offeror_type = 'instructor' AND
    offered_by.offeror_id   = instructor_parents.child_id
);

CREATE MATERIALIZED VIEW app.profile_courses AS (
  SELECT
    profiles.id AS profile_id,
    instructor_courses.course_id AS course_id,
    instructor_courses.role AS ROLE
  FROM
    app.profiles
    INNER JOIN app.instructors ON instructors.profile_id =
      app.profiles.id
    INNER JOIN app.instructor_courses ON instructors.id =
      instructor_courses.instructor_id);

-- pgFormatter-ignore
CREATE MATERIALIZED VIEW app.profile_course_summaries AS (
  WITH pre_summaries AS (
    SELECT
      app.profiles.id                                                                                                        AS profile_id,
      COALESCE( ARRAY_AGG(DISTINCT courses.category) FILTER (WHERE courses.category IS NOT NULL ), ARRAY[]::app.category[] ) AS categories,
      COALESCE( ARRAY_AGG(DISTINCT providers.name)   FILTER (WHERE providers.name IS NOT NULL ),   ARRAY[]::varchar[]      ) AS teaching_at,
      COALESCE( ARRAY_AGG(DISTINCT providers.id)     FILTER (WHERE providers.id IS NOT NULL ),     ARRAY[]::uuid[]         ) AS provider_ids,
      COUNT(DISTINCT courses.id)                                                                                             AS courses_count,
      COUNT(DISTINCT courses.id) FILTER ( WHERE courses.published = TRUE and courses.canonical_id IS NULL )                  AS available_courses_count
    FROM app.profiles
    LEFT JOIN app.profile_courses ON
      app.profile_courses.profile_id = app.profiles.id
    LEFT JOIN app.courses ON
      app.profile_courses.course_id = courses.id
    LEFT JOIN app.providers ON
      providers.id = courses.provider_id
    GROUP BY 1
  )

  SELECT
    pre_summaries.*,
    COALESCE(
      ARRAY(SELECT DISTINCT unnest(categories::varchar[]) ORDER BY 1),
      ARRAY[]::varchar[]
    ) AS teaching_subjects
  FROM pre_summaries
);

CREATE MATERIALIZED VIEW app.organization_tree AS (
  WITH RECURSIVE organization_tree (id, parent_ids, canonical_id, children) AS (
    -- start from bottom-level entries
    SELECT id, parent_ids, canonical_id, '{}'::uuid[] AS children
    FROM app.organizations t
    WHERE NOT EXISTS (
      SELECT id
      FROM app.organizations
      WHERE t.id = ANY(parent_ids) OR t.id = canonical_id
    )
    UNION ALL
    SELECT t.id, t.parent_ids, t.canonical_id, organization_tree.children || (
        SELECT array_agg(id)
        FROM app.organizations
        WHERE t.id = ANY(parent_ids) OR t.id = canonical_id
      )
    FROM app.organizations t JOIN organization_tree ON t.id = ANY(organization_tree.parent_ids) OR t.id = organization_tree.canonical_id
  )
  SELECT organization_tree.id, (SELECT array_agg(DISTINCT x) FROM unnest(
    array_accum(organization_tree.children)
  ) t(x)) AS children
  FROM organization_tree
  GROUP BY organization_tree.id
);

CREATE MATERIALIZED VIEW app.organization_courses AS (
  SELECT
    app.organization_tree.id AS organization_id,
    offered_by.course_id     AS course_id,
    offered_by.role          AS role
  FROM app.organization_tree
  INNER JOIN app.offered_by ON
    offered_by.deleted_at IS NULL            AND
    offered_by.offeror_type = 'organization' AND
    (
      offered_by.offeror_id   = ANY(app.organization_tree.children) OR
      offered_by.offeror_id   = app.organization_tree.id
    )
);

CREATE MATERIALIZED VIEW app.organization_countries AS (
  SELECT organization_id, (ARRAY_AGG(country))[1:5] AS codes FROM (
    SELECT app.organization_courses.organization_id AS organization_id, tracking_data->>'country' AS country, count(*) AS count_all
      FROM app.enrollments
      INNER JOIN app.organization_courses ON app.enrollments.course_id = app.organization_courses.course_id
      WHERE tracking_data->>'country' IS NOT NULL
      GROUP BY organization_id, country
      ORDER BY count_all DESC
  ) sq
  GROUP BY organization_id
);

CREATE MATERIALIZED VIEW app.organization_stats AS (
  SELECT organization_id, count(*) AS indexed_courses
  FROM app.organization_courses
  INNER JOIN app.courses ON app.courses.id = app.organization_courses.course_id
  WHERE app.courses.published = 't'
  GROUP BY organization_id
);

CREATE MATERIALIZED VIEW app.organization_pricings AS (
  SELECT
    app.organization_tree.id AS organization_id,
    ARRAY_AGG(DISTINCT app.course_pricings.pricing_type) AS membership_types,
    MIN(CASE WHEN app.course_pricings.pricing_type = 'single_course' THEN app.course_pricings.price ELSE app.course_pricings.total_price END) AS min_price,
    MAX(CASE WHEN app.course_pricings.pricing_type = 'single_course' THEN app.course_pricings.price ELSE app.course_pricings.total_price END) AS max_price,
    (MIN(app.course_pricings.trial_period_value) IS NOT NULL) AS has_trial,
    app.course_pricings.currency
  FROM app.organization_tree
  INNER JOIN app.offered_by ON
    offered_by.deleted_at IS NULL            AND
    offered_by.offeror_type = 'organization' AND
    offered_by.offeror_id   = ANY(app.organization_tree.children)
  INNER JOIN app.courses ON app.courses.id = offered_by.course_id
  INNER JOIN app.course_pricings ON app.course_pricings.course_id = app.courses.id
  WHERE app.courses.published = 't'
  GROUP BY organization_id, currency
);

CREATE MATERIALIZED VIEW app.organization_posts AS (
  SELECT
    app.organization_tree.id AS organization_id,
    app.posts.id             AS post_id
  FROM app.organization_tree
  INNER JOIN app.post_relations ON
    app.post_relations.relation_type = 'Organization' AND
    (
      app.post_relations.relation_id   = ANY(organization_tree.children) OR
      app.post_relations.relation_id   = app.organization_tree.id
    )
  INNER JOIN app.posts ON
    app.post_relations.post_id = app.posts.id
);

CREATE MATERIALIZED VIEW app.search_terms AS (
  SELECT public.uuid_generate_v4() as id, query, entries, NULL as lang FROM (
    SELECT DISTINCT ON (query)
      LOWER(REPLACE(app.ahoy_events.properties->>'query', '"', '')) as query, COUNT(*) as entries
      FROM app.ahoy_events INNER JOIN app.ahoy_visits ON
      app.ahoy_visits.id = app.ahoy_events.visit_id
      WHERE app.ahoy_events.name = 'course_search' AND
            app.ahoy_events.properties->>'query' IS NOT NULL AND
            LENGTH(LOWER(REPLACE(app.ahoy_events.properties->>'query', '"', ''))) > 2 AND
            LENGTH(LOWER(REPLACE(app.ahoy_events.properties->>'query', '"', ''))) <= 20
      GROUP BY query
  ) st ORDER BY entries DESC
);

CREATE OR REPLACE VIEW api.admin_accounts AS
  SELECT
    id,
    email,
    NULL::varchar AS password,
    reset_password_token,
    reset_password_sent_at,
    remember_created_at,
    sign_in_count,
    current_sign_in_at,
    last_sign_in_at,
    current_sign_in_ip,
    last_sign_in_ip,
    confirmation_token,
    confirmed_at,
    confirmation_sent_at,
    unconfirmed_email,
    failed_attempts,
    unlock_token,
    locked_at,
    created_at,
    updated_at,
    preferences
  FROM app.admin_accounts;

CREATE OR REPLACE FUNCTION triggers.api_admin_accounts_view_instead() RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    UPDATE app.admin_accounts
    SET
      email              = NEW.email,
      encrypted_password = crypt(NEW.password, gen_salt('bf', 11))
    WHERE
      id = OLD.id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO app.admin_accounts (
      email,
      encrypted_password
    ) VALUES (
      NEW.email,
      crypt(NEW.password, gen_salt('bf', 11))
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_admin_accounts_view_instead
  INSTEAD OF INSERT OR UPDATE
  ON api.admin_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_admin_accounts_view_instead();

CREATE OR REPLACE VIEW api.certificates AS
  SELECT
    id,
    user_account_id,
    file,
    created_at,
    updated_at,
    app.sign_certificate_s3_fetch(id, file, 3600)  AS fetch_url,
    app.sign_certificate_s3_upload(id, file, 3600) AS upload_url,
    app.content_type_by_extension(file)            AS file_content_type
  FROM app.certificates
  WHERE
    current_user = 'admin' OR (
      current_user = 'user' AND
      current_setting('request.jwt.claim.sub', true)::bigint = user_account_id
    );

CREATE OR REPLACE FUNCTION triggers.api_certificates_view_instead() RETURNS trigger AS $$
DECLARE
  certificate record;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    IF if_admin(TRUE) OR if_user_by_id(NEW.user_account_id, TRUE) THEN
      INSERT INTO app.certificates (
        id,
        user_account_id,
        file
      ) VALUES (
        NEW.id,
        NEW.user_account_id,
        NEW.file
      ) ON CONFLICT (id) DO
        UPDATE set file = NEW.file
        RETURNING * INTO certificate;
    ELSE
      RAISE EXCEPTION 'Unauthorized Request';
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF if_admin(TRUE) OR ( if_user_by_id(OLD.user_account_id, TRUE) AND if_user_by_id(NEW.user_account_id, TRUE) ) THEN
      UPDATE app.certificates
      SET
        user_account_id = NEW.user_account_id,
        file            = NEW.file
      WHERE
        id = OLD.id
      RETURNING * INTO certificate;
    ELSE
      RAISE EXCEPTION 'Unauthorized Request';
    END IF;
  END IF;

  NEW.id                = certificate.id;
  NEW.created_at        = certificate.created_at;
  NEW.updated_at        = certificate.updated_at;
  NEW.fetch_url         = app.sign_certificate_s3_fetch(NEW.id, NEW.file, 3600);
  NEW.upload_url        = app.sign_certificate_s3_upload(NEW.id, NEW.file, 3600);
  NEW.file_content_type = app.content_type_by_extension(NEW.file);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_certificates_view_instead
  INSTEAD OF INSERT OR UPDATE
  ON api.certificates
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_certificates_view_instead();

CREATE OR REPLACE VIEW api.crawler_domains AS
  SELECT COALESCE( if_admin(crawler_domain.id),                            if_user_by_ids(crawler.user_account_ids, crawler_domain.id) ) AS id,
         crawler_domain.provider_crawler_id AS provider_crawler_id,
         crawler_domain.authority_confirmation_status AS authority_confirmation_status,
         COALESCE( if_admin(crawler_domain.authority_confirmation_token),  if_user_by_ids(crawler.user_account_ids, crawler_domain.authority_confirmation_token) ) AS authority_confirmation_token,
         COALESCE( if_admin(crawler_domain.authority_confirmation_method), if_user_by_ids(crawler.user_account_ids, crawler_domain.authority_confirmation_method) ) AS authority_confirmation_method,
         COALESCE( if_admin(crawler_domain.created_at),                    if_user_by_ids(crawler.user_account_ids, crawler_domain.created_at) ) AS created_at,
         COALESCE( if_admin(crawler_domain.updated_at),                    if_user_by_ids(crawler.user_account_ids, crawler_domain.updated_at) ) AS updated_at,
         crawler_domain.domain AS domain,
         COALESCE( if_admin(crawler_domain.authority_confirmation_salt),   if_user_by_ids(crawler.user_account_ids, crawler_domain.authority_confirmation_salt) ) AS authority_confirmation_salt
  FROM app.crawler_domains AS crawler_domain
  LEFT OUTER JOIN app.provider_crawlers AS crawler ON crawler.id = crawler_domain.provider_crawler_id
  ORDER BY id NULLS LAST;

CREATE OR REPLACE FUNCTION triggers.api_crawler_domains_view_instead_of_insert() RETURNS trigger AS $$
DECLARE
  crawler_domain RECORD;
  crawler RECORD;
  current_user_id bigint;
  log_session_id text;
BEGIN
  current_user_id := current_setting('request.jwt.claim.sub', true)::bigint;
  log_session_id := current_setting('request.header.sessionid', true)::text;

  IF if_admin(TRUE) THEN
    INSERT INTO app.crawler_domains (
      provider_crawler_id,
      authority_confirmation_status,
      domain
    ) VALUES (
      NEW.provider_crawler_id,
      COALESCE(NEW.authority_confirmation_status, 'unconfirmed'),
      NEW.domain
    ) RETURNING * INTO crawler_domain;

    RETURN crawler_domain;
  END IF;

  SELECT app.provider_crawlers.* FROM app.crawler_domains
  INNER JOIN app.provider_crawlers ON app.provider_crawlers.id = app.crawler_domains.provider_crawler_id
  WHERE app.crawler_domains.domain = NEW.domain AND app.provider_crawlers.status != 'deleted'
  LIMIT 1 INTO crawler;

  -- check for existing domains
  IF crawler IS NOT NULL THEN
    -- if there's one already for another user
    IF current_user_id != ALL(COALESCE(crawler.user_account_ids, ARRAY[]::int[])) THEN
      RAISE insufficient_privilege
        USING DETAIL = 'error', HINT = 'already_validated';
    -- if there's one already for me
    ELSE
      SELECT app.crawler_domains.* FROM app.crawler_domains
      WHERE app.crawler_domains.domain = NEW.domain
      LIMIT 1 INTO crawler_domain;

      RETURN crawler_domain;
    END IF;
  ELSE
    INSERT INTO app.crawler_domains (
      domain
    ) VALUES (
      NEW.domain
    ) ON CONFLICT ( domain ) DO UPDATE SET authority_confirmation_status = 'unconfirmed'
    RETURNING * INTO crawler_domain;

    IF crawler_domain.id IS NULL THEN
      SELECT * FROM app.crawler_domains
      WHERE app.crawler_domains.domain = NEW.domain
      LIMIT 1 INTO crawler_domain;
    END IF;

    INSERT INTO public.que_jobs
      (queue, priority, run_at, job_class, args, data)
      VALUES
      (
        'default',
        100,
        NOW(),
        'Developers::DomainAuthorityVerificationJob',
        ('["' || crawler_domain.id || '","' || current_user_id  ||  '","' || log_session_id || '"]')::jsonb,
        '{}'::jsonb
      );

    RETURN crawler_domain;
  END IF;
END;
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE TRIGGER api_crawler_domains_view_instead_of_insert
  INSTEAD OF INSERT
  ON api.crawler_domains
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_crawler_domains_view_instead_of_insert();

CREATE OR REPLACE FUNCTION triggers.api_crawler_domains_view_instead_of_update() RETURNS trigger AS $$
DECLARE
  new_record RECORD;
BEGIN
  IF if_admin(TRUE) THEN
    UPDATE app.crawler_domains
    SET
      provider_crawler_id           = NEW.provider_crawler_id,
      authority_confirmation_status = NEW.authority_confirmation_status,
      authority_confirmation_token  = NEW.authority_confirmation_token,
      authority_confirmation_method = NEW.authority_confirmation_method,
      domain                        = NEW.domain
    WHERE
      id = OLD.id
    RETURNING * INTO new_record;

    RETURN new_record;
  END IF;
  RAISE insufficient_privilege;
END;
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE TRIGGER api_crawler_domains_view_instead_of_update
  INSTEAD OF UPDATE
  ON api.crawler_domains
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_crawler_domains_view_instead_of_update();

CREATE OR REPLACE FUNCTION triggers.api_crawler_domains_view_instead_of_delete() RETURNS trigger AS $$
DECLARE
  new_record RECORD;
BEGIN
  IF if_admin(TRUE) THEN
    UPDATE app.crawler_domains
    SET authority_confirmation_status = 'deleted'
    WHERE
      id = OLD.id;

    RETURN OLD;
  END IF;

  SELECT *
  FROM api.provider_crawlers AS crawler
  WHERE
    crawler.id = OLD.provider_crawler_id
  INTO new_record;

  IF NOT FOUND THEN
    RAISE insufficient_privilege;
  END IF;

  RAISE insufficient_privilege;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_crawler_domains_view_instead_of_delete
  INSTEAD OF DELETE
  ON api.crawler_domains
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_crawler_domains_view_instead_of_delete();

CREATE OR REPLACE VIEW api.crawling_events AS
  SELECT *
  FROM app.crawling_events AS event
  WHERE
    (
      current_user = 'user'
      AND EXISTS (
        SELECT 1
        FROM app.provider_crawlers AS crawler
        WHERE
          crawler.status != 'deleted'
          AND event.provider_crawler_id = crawler.id
          AND if_user_by_ids(crawler.user_account_ids, TRUE)
      )
    ) OR current_user = 'admin';

-- all confirmed ownerships end up here
CREATE OR REPLACE VIEW api.domain_ownerships AS
  SELECT
    id,
    domain_ownership_verification_id,
    authority_confirmation_method,
    domain
  FROM app.domain_ownerships
  WHERE user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE OR REPLACE VIEW api.domain_ownership_verifications AS
  SELECT
    id,
    authority_confirmation_status,
    authority_confirmation_method,
    COALESCE(authority_confirmation_token, api.domain_verification_token()) AS authority_confirmation_token,
    domain,
    run_count
  FROM app.domain_ownership_verifications
  WHERE user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE OR REPLACE VIEW api.domain_ownership_verification_logs AS
  SELECT
    id,
    domain_ownership_verification_id,
    log
  FROM app.domain_ownership_verification_logs
  WHERE user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE VIEW api.earnings AS
  SELECT
    tracked_actions.id,
    tracked_actions.sale_amount,
    tracked_actions.earnings_amount,
    tracked_actions.ext_click_date,
    tracked_actions.ext_sku_id,
    tracked_actions.ext_product_name,
    tracked_actions.ext_id,
    tracked_actions.source                             AS affiliate_network,
    providers.name                                     AS provider_name,
    courses.name                                       AS course_name,
    courses.url                                        AS course_url,
    (enrollments.tracking_data->>'country')::text      AS country,
    (enrollments.tracking_data->>'query_string')::text AS qs,
    (enrollments.tracking_data->>'referer')::text      AS referer,
    (enrollments.tracking_data->>'utm_source')::text   AS utm_source,
    (enrollments.tracking_data->>'utm_campaign')::text AS utm_campaign,
    (enrollments.tracking_data->>'utm_medium')::text   AS utm_medium,
    (enrollments.tracking_data->>'utm_term')::text     AS utm_term,
    tracked_actions.created_at
  FROM app.tracked_actions
    LEFT JOIN app.enrollments ON enrollments.id = tracked_actions.enrollment_id
    LEFT JOIN app.courses     ON courses.id     = enrollments.course_id
    LEFT JOIN app.providers   ON providers.id   = courses.provider_id;

CREATE OR REPLACE VIEW api.preview_courses AS
  SELECT course.*
  FROM app.preview_courses AS course
  WHERE
    (
      current_user = 'user'
      AND EXISTS (
        SELECT 1
        FROM app.provider_crawlers AS crawler
        WHERE
          crawler.status != 'deleted'
          AND course.provider_crawler_id = crawler.id
          AND if_user_by_ids(crawler.user_account_ids, TRUE)
      )
    ) OR current_user = 'admin';

CREATE OR REPLACE FUNCTION triggers.api_preview_courses_view_instead_of_insert() RETURNS trigger AS $$
DECLARE
  preview_course RECORD;
  provider_crawler_id uuid;
  provider_id uuid;
  current_user_id bigint;
BEGIN
  current_user_id := current_setting('request.jwt.claim.sub', true)::bigint;
  preview_course := NEW;

  preview_course.id := COALESCE(preview_course.id, public.uuid_generate_v4());
  preview_course.status := 'pending';

  SELECT app.provider_crawlers.id,
         app.provider_crawlers.provider_id
    INTO provider_crawler_id, provider_id
    FROM app.provider_crawlers
    WHERE app.provider_crawlers.id = preview_course.provider_crawler_id
      AND current_user_id = ANY(app.provider_crawlers.user_account_ids)
    LIMIT 1;

  IF provider_crawler_id IS NOT NULL AND provider_id IS NOT NULL THEN
    INSERT INTO app.preview_courses (id, status, url, provider_crawler_id, provider_id)
          VALUES (preview_course.id, preview_course.status, preview_course.url, preview_course.provider_crawler_id, provider_id);

    INSERT INTO public.que_jobs
      (queue, priority, run_at, job_class, args, data)
      VALUES
      (
        'default',
        100,
        NOW(),
        'Developers::PreviewCourseProcessorJob',
        ('["' || provider_crawler_id || '","' || preview_course.id   || '"]')::jsonb,
        '{}'::jsonb
      );

    RETURN preview_course;
  ELSE
    RETURN NULL;
  END IF;

  RAISE insufficient_privilege;
END;
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE TRIGGER api_preview_courses_view_instead_of_insert
  INSTEAD OF INSERT OR UPDATE
  ON api.preview_courses
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_preview_courses_view_instead_of_insert();

CREATE OR REPLACE VIEW api.preview_course_images AS
  SELECT app.preview_course_images.*
  FROM app.preview_course_images
  INNER JOIN api.preview_courses ON api.preview_courses.id = app.preview_course_images.preview_course_id;

CREATE OR REPLACE VIEW api.profiles AS
  SELECT
    id,
    name,
    username,
    short_bio,
    long_bio,
    instructor,
    public,
    country,
    website,
    COALESCE(uploaded_avatar_url, oauth_avatar_url) AS avatar_url,
    date_of_birth,
    interests,
    preferences,
    social_profiles,
    elearning_profiles,
    course_ids
  FROM app.profiles
  WHERE user_account_id = current_setting('request.jwt.claim.sub', true)::bigint
  LIMIT 1;

CREATE VIEW api.profile_courses AS (
  SELECT DISTINCT
    profile_id,
    course_id
  FROM
    app.profile_courses);

CREATE OR REPLACE VIEW api.promo_accounts AS
  SELECT
    app.promo_accounts.id AS id,
    COALESCE( if_admin(app.promo_accounts.user_account_id), if_user_by_id(app.promo_accounts.user_account_id, app.promo_accounts.user_account_id) ) AS user_account_id,
    COALESCE( if_admin(certificate_id),  if_user_by_id(app.promo_accounts.user_account_id, certificate_id)  ) AS certificate_id,
    COALESCE( if_admin(price),           if_user_by_id(app.promo_accounts.user_account_id, price)           ) AS price,
    COALESCE( if_admin(purchase_date),   if_user_by_id(app.promo_accounts.user_account_id, purchase_date)   ) AS purchase_date,
    COALESCE( if_admin(order_id),        if_user_by_id(app.promo_accounts.user_account_id, order_id)        ) AS order_id,
    COALESCE( if_admin(paypal_account),  if_user_by_id(app.promo_accounts.user_account_id, paypal_account)  ) AS paypal_account,
    COALESCE( if_admin(state),           if_user_by_id(app.promo_accounts.user_account_id, state)           ) AS state,
    COALESCE( if_admin(state_info),      if_user_by_id(app.promo_accounts.user_account_id, state_info)      ) AS state_info,
    COALESCE( if_admin(file),            if_user_by_id(app.promo_accounts.user_account_id, file)            ) AS file,
    app.promo_accounts.created_at,
    app.promo_accounts.updated_at
  FROM app.promo_accounts
  INNER JOIN app.certificates ON app.promo_accounts.certificate_id = app.certificates.id;

CREATE OR REPLACE FUNCTION triggers.api_promo_accounts_view_instead() RETURNS trigger AS $$
DECLARE
  cert_id uuid;
  cert_user_account_id bigint;
  cert_file varchar;
  promo_account record;
  exception_sql_state text;
  exception_column_name text;
  exception_constraint_name text;
  exception_table_name text;
  exception_message text;
  exception_detail text;
  exception_hint text;
BEGIN
  promo_account := NEW;

  IF TG_OP = 'INSERT' THEN
    SELECT current_setting('request.header.certificateid', true)::uuid INTO cert_id;
  ELSIF (TG_OP = 'UPDATE' AND if_admin(TRUE) IS NOT NULL) THEN
    cert_id := OLD.certificate_id;
  END IF;

  IF cert_id IS NULL THEN
    RAISE EXCEPTION 'Null certificate'
      USING DETAIL = 'error', HINT = 'promo_accounts.certificate_id.null';
  END IF;

  SELECT app.certificates.user_account_id FROM app.certificates WHERE id = cert_id INTO cert_user_account_id;

  IF if_admin(TRUE) IS NULL AND if_user_by_id(cert_user_account_id, TRUE) IS NULL THEN
    RAISE insufficient_privilege
      USING DETAIL = 'error', HINT = 'promo_accounts.user_account_id.mismatch';
  END IF;

  IF if_admin(TRUE) IS NULL AND if_user_by_id(promo_account.user_account_id, TRUE) IS NULL THEN
    RAISE insufficient_privilege
      USING DETAIL = 'error', HINT = 'promo_accounts.unauthorized';
  END IF;

  SELECT app.certificates.file FROM app.certificates WHERE id = cert_id INTO cert_file;

  IF (TG_OP = 'INSERT') THEN
    INSERT INTO app.promo_accounts (id, user_account_id, certificate_id, price, purchase_date, order_id, paypal_account, state)
    VALUES (COALESCE(promo_account.id, public.uuid_generate_v4()), promo_account.user_account_id, cert_id, promo_account.price, promo_account.purchase_date, promo_account.order_id, promo_account.paypal_account, 'pending')
    ON CONFLICT ON CONSTRAINT cntr_promo_accounts_user_account_id DO
      UPDATE SET certificate_id = EXCLUDED.certificate_id,
                 price = COALESCE(EXCLUDED.price, app.promo_accounts.price),
                 purchase_date = COALESCE(EXCLUDED.purchase_date, app.promo_accounts.purchase_date),
                 order_id = COALESCE(EXCLUDED.order_id, app.promo_accounts.order_id),
                 paypal_account = COALESCE(EXCLUDED.paypal_account, app.promo_accounts.paypal_account),
                 old_self = (SELECT json_agg(json_build_object('price', apc.price, 'purchase_date', apc.purchase_date, 'order_id', apc.order_id, 'paypal_account', apc.paypal_account, 'state', apc.state, 'state_info', apc.state_info))->>0 FROM app.promo_accounts AS apc where apc.id = id)::jsonb
      RETURNING * INTO promo_account;
  ELSIF (TG_OP = 'UPDATE' AND if_admin(TRUE) IS NOT NULL) THEN
    UPDATE app.promo_accounts
       SET state = COALESCE(NEW.state, OLD.state),
           state_info = CASE NEW.state = OLD.state AND NEW.state = 'rejected'
                        WHEN TRUE THEN
                          COALESCE(NEW.state_info, OLD.state_info)
                        ELSE
                          NEW.state_info
                        END,
           old_self = (SELECT json_agg(json_build_object('price', apc.price, 'purchase_date', apc.purchase_date, 'order_id', apc.order_id, 'paypal_account', apc.paypal_account, 'state', apc.state, 'state_info', apc.state_info))->>0 FROM app.promo_accounts AS apc where apc.id = id)::jsonb
        RETURNING * INTO promo_account;
  END IF;

  IF if_admin(TRUE) IS NULL AND promo_account.state IN ('locked', 'approved') THEN
    RAISE EXCEPTION 'Cannot update on locked promo'
      USING DETAIL = 'error', HINT = 'promo_accounts.state.locked';
  END IF;

  IF promo_account.state = 'rejected' AND promo_account.state_info IS NULL THEN
    RAISE EXCEPTION 'Rejected promo cannot have empty state_info'
      USING DETAIL = 'error', HINT = 'promo_accounts.state_info.blank';
  END IF;

  INSERT INTO app.promo_account_logs (promo_account_id, old, new, role)
    VALUES (promo_account.id, promo_account.old_self, json_build_object('price', promo_account.price, 'purchase_date', promo_account.purchase_date, 'order_id', promo_account.order_id, 'paypal_account', promo_account.paypal_account, 'state', promo_account.state, 'state_info', promo_account.state_info), current_user);

  RETURN (
    promo_account.id,
    promo_account.user_account_id,
    promo_account.certificate_id,
    promo_account.price,
    promo_account.purchase_date,
    promo_account.order_id,
    promo_account.paypal_account,
    promo_account.state,
    promo_account.state_info,
    cert_file,
    promo_account.created_at,
    promo_account.updated_at
  );
EXCEPTION
  WHEN insufficient_privilege THEN
    RAISE;
  WHEN OTHERS THEN
  GET STACKED DIAGNOSTICS exception_message = MESSAGE_TEXT,
                          exception_detail = PG_EXCEPTION_DETAIL,
                          exception_hint = PG_EXCEPTION_HINT,
                          exception_sql_state = RETURNED_SQLSTATE,
                          exception_column_name = COLUMN_NAME,
                          exception_constraint_name = CONSTRAINT_NAME,
                          exception_table_name = TABLE_NAME;

  IF exception_detail = 'error' THEN
    RAISE EXCEPTION '%', exception_message
      USING DETAIL = exception_detail, HINT = exception_hint;
  ELSE
    -- constraint
    IF exception_sql_state IN ('23514', '23505') AND exception_constraint_name IS NOT NULL THEN
      exception_column_name := REGEXP_REPLACE(exception_constraint_name, '(.*)__(.*)', '\1');
      exception_sql_state := 'constraint';
    END IF;

    RAISE EXCEPTION '%', exception_message
      USING DETAIL = 'error', HINT = 'promo_accounts.' || COALESCE(exception_sql_state,'error') || '.' || exception_column_name;
  END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER api_promo_accounts_view_instead
  INSTEAD OF INSERT OR UPDATE
  ON api.promo_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_promo_accounts_view_instead();

CREATE OR REPLACE VIEW api.providers AS (
  SELECT
    app.providers.id,
    app.providers.slug,
    app.providers.name,
    app.providers.name_changed_at,
    app.providers.url,
    app.providers.domain,
    app.providers.published
  FROM app.providers
  INNER JOIN app.provider_ownerships ON
    app.providers.id = app.provider_ownerships.provider_id
  WHERE app.provider_ownerships.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint
);

CREATE OR REPLACE VIEW api.provider_crawlers AS
  SELECT *
  FROM app.provider_crawlers
  WHERE
    (
      status != 'deleted' AND if_user_by_ids(user_account_ids, TRUE)
    ) OR current_user = 'admin';

CREATE OR REPLACE FUNCTION triggers.api_provider_crawlers_view_instead_of_insert() RETURNS trigger AS $$
DECLARE
  _provider_id uuid;
  new_record   RECORD;
BEGIN
  IF current_user = 'user' THEN
    INSERT INTO app.providers DEFAULT VALUES RETURNING id INTO _provider_id;

    INSERT INTO app.provider_crawlers (
      provider_id,
      user_account_ids,
      sitemaps
    ) VALUES (
      _provider_id,
      ARRAY[current_setting('request.jwt.claim.sub',true)::bigint],
      '{}'
    ) RETURNING * INTO new_record;

    RETURN new_record;
  END IF;

  IF if_admin(TRUE) THEN
    IF NEW.provider_id IS NOT NULL THEN
      _provider_id = NEW.provider_id;
    ELSE
      INSERT INTO app.providers DEFAULT VALUES RETURNING id INTO _provider_id;
    END IF;

    INSERT INTO app.provider_crawlers (
      user_agent_token,
      provider_id,
      published,
      status,
      user_account_ids,
      sitemaps
    ) VALUES (
      COALESCE(NEW.user_agent_token, public.uuid_generate_v4()),
      _provider_id,
      COALESCE(NEW.published, false),
      COALESCE(NEW.status, 'unverified'),
      COALESCE(NEW.user_account_ids, '{}'),
      COALESCE(app.fill_sitemaps(NEW.sitemaps), '{}')
    ) RETURNING * INTO new_record;

    RETURN new_record;
  END IF;

  RAISE insufficient_privilege;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_provider_crawlers_view_instead_of_insert
  INSTEAD OF INSERT
  ON api.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_provider_crawlers_view_instead_of_insert();

CREATE OR REPLACE FUNCTION triggers.api_provider_crawlers_view_instead_of_update() RETURNS trigger AS $$
DECLARE
  new_record RECORD;
  sitemap app.sitemap;
  user_id bigint;
  user_role varchar;
BEGIN
  user_id := current_setting('request.jwt.claim.sub', true)::bigint;
  user_role := current_setting('request.jwt.claim.role', true)::varchar;

  IF ARRAY_LENGTH(NEW.sitemaps, 1) > 0 AND NEW.sitemaps[1].id IS NOT NULL AND (
    OLD.sitemaps[1].id IS NULL OR
    OLD.sitemaps[1].id <> NEW.sitemaps[1].id
  ) THEN
    sitemap :=
      ( '(' || NEW.sitemaps[1].id  ||  ','
            || 'unverified'    ||  ','
            || NEW.sitemaps[1].url ||  ','
            || 'unknown'       ||  ')'
      )::app.sitemap;
  END IF;

  IF user_role = 'user' AND user_id = ANY(OLD.user_account_ids) THEN
    IF sitemap.id IS NOT NULL THEN
      UPDATE app.provider_crawlers
      SET
        user_account_ids = NEW.user_account_ids,
        sitemaps         = ARRAY[sitemap]::app.sitemap[]
      WHERE
        id = OLD.id
      RETURNING * INTO new_record;

      INSERT INTO public.que_jobs
        (queue, priority, run_at, job_class, args, data)
        VALUES
        (
          'default',
          100,
          NOW(),
          'Developers::SitemapVerificationJob',
          ('["' || OLD.id || '","' || sitemap.id  || '"]')::jsonb,
          '{}'::jsonb
        );
    ELSE
      UPDATE app.provider_crawlers
      SET
        user_account_ids = NEW.user_account_ids,
        urls             = NEW.urls
      WHERE
        id = OLD.id
      RETURNING * INTO new_record;

      INSERT INTO public.que_jobs
        (queue, priority, run_at, job_class, args, data)
        VALUES
        (
          'default',
          100,
          NOW(),
          'Developers::ProviderCrawlerSetupJob',
          ('["' || OLD.id || '"]')::jsonb,
          '{}'::jsonb
        );
    END IF;

    RETURN new_record;
  END IF;

  IF user_role = 'admin' THEN
    UPDATE app.provider_crawlers
    SET
      user_agent_token = NEW.user_agent_token,
      provider_id      = NEW.provider_id,
      published        = NEW.published,
      status           = NEW.status,
      user_account_ids = NEW.user_account_ids,
      sitemaps         = NEW.sitemaps,
      urls             = NEW.urls
    WHERE
      id = OLD.id
    RETURNING * INTO new_record;

    RETURN new_record;
  END IF;

  RAISE insufficient_privilege;
END;
$$ SECURITY DEFINER LANGUAGE plpgsql;

CREATE TRIGGER api_provider_crawlers_view_instead_of_update
  INSTEAD OF UPDATE
  ON api.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_provider_crawlers_view_instead_of_update();

CREATE OR REPLACE FUNCTION triggers.api_provider_crawlers_view_instead_of_delete() RETURNS trigger AS $$
DECLARE
  new_record RECORD;
BEGIN
  IF if_admin(TRUE) OR if_user_by_ids(OLD.user_account_ids, TRUE) THEN
    UPDATE app.provider_crawlers
    SET status = 'deleted'
    WHERE
      id = OLD.id
    RETURNING * INTO new_record;

    RETURN OLD;
  END IF;

  RAISE insufficient_privilege;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_provider_crawlers_view_instead_of_delete
  INSTEAD OF DELETE
  ON api.provider_crawlers
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_provider_crawlers_view_instead_of_delete();

CREATE OR REPLACE VIEW api.provider_logos AS
  SELECT
    app.provider_logos.id as id,
    app.provider_logos.provider_id as provider_id,
    app.direct_uploads.file as file,
    app.direct_uploads.user_account_id as user_account_id,
    app.direct_uploads.created_at as created_at,
    app.direct_uploads.updated_at as updated_at,
    app.sign_direct_s3_fetch(app.direct_uploads.id, app.direct_uploads.file, 'provider_logos/' || app.provider_logos.provider_id::varchar, 3600)  AS fetch_url,
    app.sign_direct_s3_upload(app.direct_uploads.id, app.direct_uploads.file, 'provider_logos/' || app.provider_logos.provider_id::varchar, 3600) AS upload_url,
    app.content_type_by_extension(app.direct_uploads.file)                              AS file_content_type
  FROM app.provider_logos
  INNER JOIN app.direct_uploads ON app.direct_uploads.id = app.provider_logos.direct_upload_id
  WHERE
    current_user = 'admin' OR (
      current_user = 'user' AND
      current_setting('request.jwt.claim.sub', true)::bigint = app.direct_uploads.user_account_id
    );

CREATE OR REPLACE FUNCTION triggers.api_provider_logos_view_instead() RETURNS trigger AS $$
DECLARE
  current_user_id bigint;
  direct_upload app.direct_uploads;
  provider_logo app.provider_logo;
  filename varchar;
  file_content_type varchar;
  fetch_url text;
  upload_url text;
BEGIN
  current_user_id   := current_setting('request.jwt.claim.sub', true)::bigint;
  filename          := NEW.file;

  IF (TG_OP = 'INSERT') THEN
    INSERT INTO app.direct_uploads (
      id,
      user_account_id,
      file
    ) VALUES (
      NEW.id,
      current_user_id,
      filename
    ) ON CONFLICT (id) DO
      UPDATE set file = filename
      RETURNING * INTO direct_upload;
  ELSIF (TG_OP = 'UPDATE') THEN
    UPDATE app.direct_uploads
    SET
      user_account_id   = current_user_id,
      file              = filename
    WHERE
      id = OLD.id
    RETURNING * INTO direct_upload;
  END IF;

  file_content_type := app.content_type_by_extension(filename);
  fetch_url         := app.sign_direct_s3_fetch(direct_upload.id, filename, 'provider_logos/' || NEW.provider_id::varchar, 3600);
  upload_url        := app.sign_direct_s3_upload(direct_upload.id, filename, 'provider_logos/' || NEW.provider_id::varchar, 3600);

  INSERT INTO app.provider_logos (
    direct_upload_id,
    provider_id
  ) VALUES (
    direct_upload.id,
    NEW.provider_id
  ) ON CONFLICT (provider_id) DO
    UPDATE set direct_upload_id = direct_upload.id;

  SELECT app.provider_logos.id INTO provider_logo FROM app.provider_logos WHERE app.provider_logos.provider_id = NEW.provider_id;
  provider_logo.provider_id := NEW.provider_id;
  provider_logo.file := filename;
  provider_logo.user_account_id := current_user_id;
  provider_logo.created_at := direct_upload.created_at;
  provider_logo.updated_at := direct_upload.updated_at;
  provider_logo.fetch_url := fetch_url;
  provider_logo.upload_url := upload_url;
  provider_logo.file_content_type := file_content_type;

  RETURN provider_logo;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_provider_logos_view_instead
  INSTEAD OF INSERT OR UPDATE
  ON api.provider_logos
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_provider_logos_view_instead();

-- CREATE TABLE app.provider_ownership_creations (
--   id                            uuid                                   DEFAULT    public.uuid_generate_v1() PRIMARY KEY,
--   user_account_id               bigint                                 REFERENCES app.user_accounts(id) ON DELETE CASCADE,
--   status                        app.provider_ownership_creation_status DEFAULT    'initial'::app.provider_ownership_creation_status NOT NULL,
--   created_at                    timestamptz                            DEFAULT    NOW()         NOT NULL,
--   updated_at                    timestamptz                            DEFAULT    NOW()         NOT NULL,
--   domain                        app.domain                             NOT NULL,
--   run_count                     bigint                                 DEFAULT 0
-- );
CREATE OR REPLACE VIEW api.provider_ownership_creations AS
  SELECT
    id,
    status,
    domain
  FROM app.provider_ownership_creations
  WHERE app.provider_ownership_creations.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE OR REPLACE VIEW api.provider_ownerships AS
  SELECT
    app.provider_ownerships.id,
    app.provider_ownerships.provider_id,
    app.domain_ownerships.domain
  FROM app.provider_ownerships
  INNER JOIN app.domain_ownerships
    ON app.domain_ownerships.id = app.provider_ownerships.domain_ownership_id
  WHERE app.provider_ownerships.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

-- pgFormatter-ignoreV
CREATE OR REPLACE VIEW api.study_lists AS
  SELECT *
  FROM app.study_lists
  WHERE app.study_lists.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

-- pgFormatter-ignoreV
CREATE OR REPLACE VIEW api.study_list_entries AS
  SELECT app.study_list_entries.id,
  course_id,
  study_list_id,
  position,
  app.study_list_entries.created_at,
  app.study_list_entries.updated_at FROM app.study_list_entries
  INNER JOIN app.study_lists ON app.study_list_entries.study_list_id = app.study_lists.id
  WHERE app.study_lists.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE OR REPLACE FUNCTION triggers.api_study_list_entries_view_instead_of_tg_op() RETURNS trigger AS $$
DECLARE
  current_user_id         bigint;
  study_list_id           uuid;
  study_list_entry_id     uuid;
  study_list_entry        app.study_list_entries;
BEGIN
  current_user_id  := current_setting('request.jwt.claim.sub', true)::bigint;
  study_list_entry := NEW;

  IF current_user_id IS NOT NULL THEN
    IF (TG_OP = 'INSERT') THEN
      -- Check if referenced study_list belongs to current user
      SELECT id FROM app.study_lists
      WHERE id = NEW.study_list_id
        AND user_account_id = current_user_id
      INTO study_list_id;

      IF study_list_id IS NULL THEN
        -- Retrieve default list (standard = true) if study_list_id is null
        SELECT id FROM app.study_lists
        WHERE user_account_id = current_user_id
          AND standard = true
        INTO study_list_id;

        INSERT INTO app.study_list_entries (study_list_id, course_id, position)
        VALUES (study_list_id, NEW.course_id, NEW.position)
        RETURNING * INTO study_list_entry;
      ELSE
        -- Insert into provided study_list, if it actually belongs to current user
        INSERT INTO app.study_list_entries (study_list_id, course_id, position)
        VALUES (study_list_id, NEW.course_id, NEW.position)
        RETURNING * INTO study_list_entry;
      END IF;
    END IF;

    IF (TG_OP = 'UPDATE' OR TG_OP = 'DELETE') THEN
      SELECT app.study_list_entries.id INTO study_list_entry_id FROM app.study_list_entries
      INNER JOIN app.study_lists ON app.study_list_entries.study_list_id = app.study_lists.id
      WHERE (app.study_list_entries.id = NEW.id AND user_account_id = current_user_id)
        OR (user_account_id = current_user_id AND app.study_list_entries.study_list_id = NEW.study_list_id AND app.study_list_entries.course_id = NEW.course_id);

      IF study_list_entry_id IS NOT NULL THEN
        IF (TG_OP = 'UPDATE') THEN
          UPDATE app.study_list_entries SET position = NEW.position WHERE id = study_list_entry_id;
          study_list_entry = NEW;
        END IF;

        IF (TG_OP = 'DELETE') THEN
          DELETE FROM app.study_list_entries WHERE id = study_list_entry_id;
          study_list_entry = OLD;
        END IF;
      END IF;
    END IF;
  ELSE
    RAISE EXCEPTION 'Not authorized' USING HINT = 'You need to be logged in';
  END IF;

  RETURN study_list_entry;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_study_list_entries_view_instead_of_tg_op
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON api.study_list_entries
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_study_list_entries_view_instead_of_tg_op();

CREATE OR REPLACE VIEW api.user_accounts AS
  SELECT
    id,
    email,
    NULL::varchar                                                                           AS password,
    COALESCE( if_admin(reset_password_token),   if_user_by_id(id, reset_password_token)   ) AS reset_password_token,
    COALESCE( if_admin(reset_password_sent_at), if_user_by_id(id, reset_password_sent_at) ) AS reset_password_sent_at,
    COALESCE( if_admin(remember_created_at),    if_user_by_id(id, remember_created_at)    ) AS remember_created_at,
    COALESCE( if_admin(sign_in_count),          if_user_by_id(id, sign_in_count)          ) AS sign_in_count,
    COALESCE( if_admin(current_sign_in_at),     if_user_by_id(id, current_sign_in_at)     ) AS current_sign_in_at,
    COALESCE( if_admin(last_sign_in_at),        if_user_by_id(id, last_sign_in_at)        ) AS last_sign_in_at,
    COALESCE( if_admin(current_sign_in_ip),     if_user_by_id(id, current_sign_in_ip)     ) AS current_sign_in_ip,
    COALESCE( if_admin(last_sign_in_ip),        if_user_by_id(id, last_sign_in_ip)        ) AS last_sign_in_ip,
    COALESCE( if_admin(tracking_data),          if_user_by_id(id, tracking_data)          ) AS tracking_data,
    COALESCE( if_admin(confirmation_token),     if_user_by_id(id, confirmation_token)     ) AS confirmation_token,
    COALESCE( if_admin(confirmed_at),           if_user_by_id(id, confirmed_at)           ) AS confirmed_at,
    COALESCE( if_admin(confirmation_sent_at),   if_user_by_id(id, confirmation_sent_at)   ) AS confirmation_sent_at,
    COALESCE( if_admin(unconfirmed_email),      if_user_by_id(id, unconfirmed_email)      ) AS unconfirmed_email,
    COALESCE( if_admin(failed_attempts),        if_user_by_id(id, failed_attempts)        ) AS failed_attempts,
    COALESCE( if_admin(unlock_token),           if_user_by_id(id, unlock_token)           ) AS unlock_token,
    COALESCE( if_admin(locked_at),              if_user_by_id(id, locked_at)              ) AS locked_at,
    COALESCE( if_admin(destroyed_at),           if_user_by_id(id, destroyed_at)           ) AS destroyed_at,
    COALESCE( if_admin(autogen_email_for_oauth),if_user_by_id(id, autogen_email_for_oauth)) AS autogen_email_for_oauth,
    created_at,
    updated_at
  FROM app.user_accounts;

CREATE OR REPLACE FUNCTION triggers.api_user_accounts_view_instead() RETURNS trigger AS $$
BEGIN
  IF if_admin(TRUE) IS NULL AND if_user_by_id(NEW.id, TRUE) IS NULL THEN
    RAISE insufficient_privilege;
  END IF;

  UPDATE app.user_accounts
  SET
    email              = NEW.email,
    encrypted_password = crypt(NEW.password, gen_salt('bf', 11))
  WHERE
    id = OLD.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_user_accounts_view_instead
  INSTEAD OF UPDATE
  ON api.user_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_user_accounts_view_instead();

CREATE OR REPLACE VIEW api.instructor_courses AS (
  SELECT DISTINCT
    instructor_id,
    course_id
  FROM app.instructor_courses
);

CREATE VIEW api.organization_courses AS (
  SELECT DISTINCT
    organization_id,
    course_id
  FROM app.organization_courses
);

CREATE OR REPLACE VIEW api.settings AS
SELECT
  *
FROM
  settings.global
LIMIT 1;

-- pgFormatter-ignore
CREATE OR REPLACE VIEW api.redeems AS
  SELECT *
  FROM app.redeems
  WHERE user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE OR REPLACE FUNCTION triggers.api_redeems_view_instead_of_insert() RETURNS trigger AS $$
DECLARE
  current_user_id bigint;
  redeem          app.redeems%ROWTYPE;
BEGIN
  current_user_id := current_setting('request.jwt.claim.sub', true)::bigint;

  IF current_user_id IS NOT NULL THEN
    SELECT *
    FROM app.redeems
    WHERE app.redeems.user_account_id = current_user_id
    AND app.redeems.status = 'under_analysis'
    LIMIT 1
    INTO redeem;

    IF redeem IS NULL THEN
      INSERT INTO app.redeems (user_account_id) VALUES (current_user_id) RETURNING * INTO redeem;
    END IF;
  END IF;

  RETURN redeem;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_redeems_view_instead_of_insert
  INSTEAD OF INSERT
  ON api.redeems
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_redeems_view_instead_of_insert();

-- pgFormatter-ignore
CREATE OR REPLACE VIEW api.wallets AS
  SELECT
  paypal_account,
  COALESCE(SUM(amount), 0) AS balance
  FROM app.wallets
  LEFT JOIN app.wallet_transactions ON app.wallet_transactions.wallet_id = app.wallets.id
  WHERE app.wallets.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint
  AND app.wallet_transactions.status = 'settled'
  GROUP BY user_account_id, paypal_account;

CREATE OR REPLACE FUNCTION triggers.api_wallets_view_instead_of_update() RETURNS trigger AS $$
DECLARE
  current_user_id bigint;
  wallet_id       uuid;
BEGIN
  current_user_id := current_setting('request.jwt.claim.sub', true)::bigint;

  IF current_user_id IS NOT NULL THEN
    SELECT id FROM app.wallets WHERE app.wallets.user_account_id = current_user_id LIMIT 1 INTO wallet_id;

    IF wallet_id IS NULL THEN
      INSERT INTO app.wallets (user_account_id) VALUES (current_user_id) RETURNING id INTO wallet_id;
    END IF;

    UPDATE app.wallets SET paypal_account = NEW.paypal_account WHERE id = wallet_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_wallets_view_instead_of_update
  INSTEAD OF INSERT OR UPDATE
  ON api.wallets
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_wallets_view_instead_of_update();

-- pgFormatter-ignore
CREATE OR REPLACE VIEW api.wallet_transactions AS
  SELECT app.wallet_transactions.*
  FROM app.wallet_transactions
  INNER JOIN app.wallets
    ON app.wallets.id = app.wallet_transactions.wallet_id
  WHERE app.wallets.user_account_id = current_setting('request.jwt.claim.sub', true)::bigint;

CREATE MATERIALIZED VIEW bi.sales AS (
  SELECT
    DATE_TRUNC('day', tracked_actions.ext_click_date)::date as date,
    enrollments.tracking_data->>'utm_source' AS utm_source,
    enrollments.tracking_data->>'utm_medium' AS utm_medium,
    enrollments.tracking_data->>'utm_campaign' AS utm_campaign,
    tracked_actions.source AS payment_source,
    providers.name AS provider,
    enrollments.tracking_data->>'country' AS country,
    (courses.locale).language AS course_language,
    courses.category AS course_category,
    SUM(tracked_actions.earnings_amount) FILTER (WHERE tracked_actions.earnings_amount > 0) AS gross_revenue,
    SUM(tracked_actions.earnings_amount) FILTER (WHERE tracked_actions.earnings_amount < 0) AS refunded_amount,
    SUM(tracked_actions.earnings_amount) AS net_income,
    COUNT(tracked_actions.id) FILTER (WHERE tracked_actions.earnings_amount > 0) AS num_sales,
    COUNT(tracked_actions.id) FILTER (WHERE tracked_actions.earnings_amount < 0) AS num_refunds
  FROM
    app.tracked_actions
  INNER JOIN
    app.enrollments ON tracked_actions.enrollment_id = enrollments.id
  LEFT JOIN
    app.courses ON enrollments.course_id = courses.id
  INNER JOIN
    app.providers ON enrollments.provider_id = providers.id
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
  ORDER BY 1
);

CREATE MATERIALIZED VIEW bi.exit_clicks AS (

  SELECT
    DATE_TRUNC('day', enrollments.created_at)::date as date,
    enrollments.tracking_data->>'utm_source' AS utm_source,
    enrollments.tracking_data->>'utm_medium' AS utm_medium,
    enrollments.tracking_data->>'utm_campaign' AS utm_campaign,
    providers.name AS provider,
    enrollments.tracking_data->>'country' AS country,
    (courses.locale).language AS course_language,
    courses.category AS course_category,
    COUNT(DISTINCT enrollments.tracking_cookies->>'id') AS unique_clicks
  FROM
    app.enrollments
  LEFT JOIN
    app.courses ON enrollments.course_id = courses.id
  INNER JOIN
    app.providers ON enrollments.provider_id = providers.id
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
  ORDER BY 1

);

CREATE OR REPLACE VIEW api_admin_v1.admin_accounts AS
  SELECT
    id,
    email,
    NULL::varchar AS password,
    reset_password_token,
    reset_password_sent_at,
    remember_created_at,
    sign_in_count,
    current_sign_in_at,
    last_sign_in_at,
    current_sign_in_ip,
    last_sign_in_ip,
    confirmation_token,
    confirmed_at,
    confirmation_sent_at,
    unconfirmed_email,
    failed_attempts,
    unlock_token,
    locked_at,
    created_at,
    updated_at,
    preferences
  FROM app.admin_accounts;

CREATE OR REPLACE FUNCTION triggers.api_admin_accounts_view_instead() RETURNS trigger AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    UPDATE app.admin_accounts
    SET
      email              = NEW.email,
      encrypted_password = crypt(NEW.password, gen_salt('bf', 11))
    WHERE
      id = OLD.id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO app.admin_accounts (
      email,
      encrypted_password
    ) VALUES (
      NEW.email,
      crypt(NEW.password, gen_salt('bf', 11))
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_admin_accounts_view_instead
  INSTEAD OF INSERT OR UPDATE
  ON api_admin_v1.admin_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_admin_accounts_view_instead();

CREATE OR REPLACE VIEW api_admin_v1.user_accounts AS
  SELECT
    id,
    email,
    NULL::varchar AS password,
    reset_password_token,
    reset_password_sent_at,
    remember_created_at,
    sign_in_count,
    current_sign_in_at,
    last_sign_in_at,
    current_sign_in_ip,
    last_sign_in_ip,
    tracking_data,
    confirmation_token,
    confirmed_at,
    confirmation_sent_at,
    unconfirmed_email,
    failed_attempts,
    unlock_token,
    locked_at,
    destroyed_at,
    autogen_email_for_oauth,
    created_at,
    updated_at
  FROM app.user_accounts;

CREATE OR REPLACE FUNCTION triggers.api_user_accounts_view_instead() RETURNS trigger AS $$
BEGIN
  IF if_admin(TRUE) IS NULL THEN
    RAISE insufficient_privilege;
  END IF;

  UPDATE app.user_accounts
  SET
    email              = NEW.email,
    encrypted_password = crypt(NEW.password, gen_salt('bf', 11))
  WHERE
    id = OLD.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER api_user_accounts_view_instead
  INSTEAD OF UPDATE
  ON api_admin_v1.user_accounts
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.api_user_accounts_view_instead();

CREATE OR REPLACE VIEW api_admin_v1.posts AS
  SELECT
    id,
    slug,
    body,
    tags,
    meta,
    content_digest,
    published_at,
    content_changed_at,
    admin_account_id,
    cover_image_id,
    original_post_id,
    created_at,
    updated_at
  FROM app.posts;

CREATE OR REPLACE VIEW api_admin_v1.courses AS (
  SELECT *
  FROM app.courses
);

CREATE OR REPLACE VIEW api_admin_v1.contacts AS (
  SELECT *
  FROM app.contacts
);

CREATE OR REPLACE VIEW api_admin_v1.providers AS (
  SELECT *
  FROM app.providers
);

CREATE OR REPLACE VIEW api_admin_v1.tracked_actions AS
  SELECT
    id,
    sale_amount,
    earnings_amount,
    payload,
    enrollment_id,
    status,
    source,
    compound_ext_id,
    ext_id,
    ext_sku_id,
    ext_product_name,
    created_at,
    updated_at
  FROM app.tracked_actions;

CREATE OR REPLACE VIEW api_admin_v1.enrollments AS (
  SELECT *
  FROM app.enrollments
);

CREATE OR REPLACE VIEW api_admin_v1.promotions AS (
  SELECT *
  FROM app.promotions
);

CREATE OR REPLACE VIEW api_admin_v1.organizations AS (
  SELECT *
  FROM app.organizations
);

CREATE OR REPLACE VIEW api_admin_v1.instructors AS (
  SELECT *
  FROM app.instructors
);

CREATE OR REPLACE VIEW api_admin_v1.faqs AS (
  SELECT *
  FROM app.faqs
);

CREATE OR REPLACE VIEW api_admin_v1.schemas AS (
  SELECT
    table_name,
    column_name,
    data_type
  FROM
    information_schema.columns
  WHERE
    table_schema = 'api_admin_v1'
);

CREATE OR REPLACE VIEW api_admin_v1.topics AS (
  SELECT *
  FROM app.topics
);

CREATE OR REPLACE VIEW api_developer_v1.courses AS (
  SELECT app.courses.*
  FROM app.courses
  INNER JOIN app.providers ON
    app.providers.id = app.courses.provider_id
  INNER JOIN app.provider_ownerships ON
    app.providers.id = app.provider_ownerships.provider_id
  WHERE app.provider_ownerships.user_account_id = current_setting('api.current_user', true)::bigint
);

CREATE OR REPLACE VIEW api_developer_v1.providers AS (
  SELECT app.providers.*
  FROM app.providers
  INNER JOIN app.provider_ownerships ON
    app.providers.id = app.provider_ownerships.provider_id
  WHERE app.provider_ownerships.user_account_id = current_setting('api.current_user', true)::bigint
);



CREATE TRIGGER api_domain_ownership_verifications_instead_of_insert
  INSTEAD OF INSERT
  ON api.domain_ownership_verifications
  FOR EACH ROW
    EXECUTE PROCEDURE api.domain_ownership_verifications_instead_of_insert();

CREATE TRIGGER api_profiles_instead_of_update
  INSTEAD OF UPDATE
  ON api.profiles
  FOR EACH ROW
    EXECUTE PROCEDURE api.profiles_instead_of_update();

CREATE TRIGGER api_provider_ownerships_instead_of_anything
  INSTEAD OF INSERT OR UPDATE OR DELETE
  ON api.provider_ownerships
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.forbid();

-- Each TG_OP (INSERT/UPDATE/DELETE) has its separate trigger
CREATE TRIGGER api_study_lists_instead_of_insert
  INSTEAD OF INSERT
  ON api.study_lists
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_lists_instead_of_insert();

CREATE TRIGGER api_study_lists_instead_of_update
  INSTEAD OF UPDATE
  ON api.study_lists
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_lists_instead_of_update();

CREATE TRIGGER api_study_lists_instead_of_delete
  INSTEAD OF DELETE
  ON api.study_lists
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_lists_instead_of_delete();

-- Each TG_OP (INSERT/UPDATE/DELETE) has its separate trigger
CREATE TRIGGER api_study_list_entries_instead_of_insert
  INSTEAD OF INSERT
  ON api.study_list_entries
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_list_entries_instead_of_insert();

CREATE TRIGGER api_study_list_entries_instead_of_update
  INSTEAD OF UPDATE
  ON api.study_list_entries
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_list_entries_instead_of_update();

CREATE TRIGGER api_study_list_entries_instead_of_delete
  INSTEAD OF DELETE
  ON api.study_list_entries
  FOR EACH ROW
  EXECUTE PROCEDURE api.study_list_entries_instead_of_delete();


CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.custom_actions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.custom_fields
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.table_templates
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.tables
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.tables_custom_actions
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

CREATE TRIGGER track_updated_at
  BEFORE UPDATE
  ON api_admin_v1.tables_custom_fields
  FOR EACH ROW
    EXECUTE PROCEDURE triggers.track_updated_at();

-- Each TG_OP (INSERT/UPDATE/DELETE) has its separate trigger
CREATE TRIGGER api_developer_v1_courses_instead_of_insert
  INSTEAD OF INSERT
  ON api_developer_v1.courses
  FOR EACH ROW
  EXECUTE PROCEDURE api_developer_v1.courses_instead_of_insert();

CREATE TRIGGER api_developer_v1_courses_instead_of_update
  INSTEAD OF UPDATE
  ON api_developer_v1.courses
  FOR EACH ROW
  EXECUTE PROCEDURE api_developer_v1.courses_instead_of_update();

CREATE TRIGGER api_developer_v1_courses_instead_of_delete
  INSTEAD OF DELETE
  ON api_developer_v1.courses
  FOR EACH ROW
  EXECUTE PROCEDURE api_developer_v1.courses_instead_of_delete();

CREATE INDEX que_jobs_args_gin_idx
ON public.que_jobs
USING gin (args jsonb_path_ops);

CREATE INDEX que_jobs_data_gin_idx
ON public.que_jobs
USING gin (data jsonb_path_ops);

CREATE INDEX que_poll_idx
ON public.que_jobs
USING btree (queue, priority, run_at, id)
WHERE ((finished_at IS NULL) AND (expired_at IS NULL));

CREATE UNIQUE INDEX index_admin_accounts_on_confirmation_token
ON app.admin_accounts
USING btree (confirmation_token);

CREATE UNIQUE INDEX index_admin_accounts_on_email
ON app.admin_accounts
USING btree (email);

CREATE UNIQUE INDEX index_admin_accounts_on_reset_password_token
ON app.admin_accounts
USING btree (reset_password_token);

CREATE UNIQUE INDEX index_admin_accounts_on_unlock_token
ON app.admin_accounts
USING btree (unlock_token);

CREATE INDEX index_admin_profiles_on_admin_account_id
ON app.admin_profiles
USING btree (admin_account_id);

CREATE UNIQUE INDEX cached_nlped_queries_query_idx ON app.cached_nlped_queries (LOWER(query));

CREATE UNIQUE INDEX index_course_reviews_on_user_account_id_and_course_id
ON app.course_reviews
USING btree (user_account_id, course_id);

CREATE INDEX index_course_pricings_on_course_id
ON app.course_pricings
USING btree (course_id);

CREATE UNIQUE INDEX index_course_pricing_uniqueness
ON app.course_pricings
USING btree (
              course_id,
              pricing_type,
              plan_type,
              COALESCE(customer_type, 'unknown'),
              currency,
              COALESCE(payment_period_unit, 'unknown'),
              COALESCE(subscription_period_unit, 'unknown'),
              COALESCE(trial_period_unit, 'unknown')
            );

-- pgFormatter-ignore
CREATE INDEX index_courses_on_dataset_sequence
ON app.courses
USING btree (dataset_sequence);

CREATE UNIQUE INDEX index_courses_on_global_sequence
ON app.courses
USING btree (global_sequence);

CREATE INDEX index_courses_on_provider_id
ON app.courses
USING btree (provider_id);

CREATE INDEX index_courses_on_provider_id_published
ON app.courses
USING btree (provider_id)
WHERE published = true;

CREATE UNIQUE INDEX index_courses_on_slug
ON app.courses
USING btree (slug)
WHERE published = true;

CREATE UNIQUE INDEX index_courses_on_url
ON app.courses
USING btree (url)
WHERE published = true;

CREATE INDEX index_courses_on_up_to_date_id
ON app.courses
USING btree (up_to_date_id);

CREATE INDEX index_courses_on_area
ON app.courses
USING btree (area)
WHERE published = true;

CREATE INDEX index_courses_on_published
ON app.courses
USING btree (published);

CREATE UNIQUE INDEX app_crawler_domains_unique_domain_idx ON app.crawler_domains ( domain );

CREATE UNIQUE INDEX index_domain_ownership_domain_and_user
ON app.domain_ownerships
USING btree (user_account_id, domain);

CREATE UNIQUE INDEX index_domain_verification_confirming
ON app.domain_ownership_verifications
USING btree (user_account_id)
WHERE authority_confirmation_status = 'confirming'::app.authority_confirmation_status;

CREATE UNIQUE INDEX index_domain_verification_confirmed
ON app.domain_ownership_verifications
USING btree (user_account_id, domain)
WHERE authority_confirmation_status = 'confirmed'::app.authority_confirmation_status;

CREATE INDEX index_enrollments_on_course_id
ON app.enrollments
USING btree (course_id);

CREATE INDEX index_enrollments_on_provider_id
ON app.enrollments
USING btree (provider_id);

CREATE INDEX index_enrollments_on_tracking_data
ON app.enrollments
USING gin (tracking_data);

CREATE INDEX index_enrollments_on_user_account_id
ON app.enrollments
USING btree (user_account_id);

CREATE INDEX index_favorites_on_course_id
ON app.favorites
USING btree (course_id);

CREATE INDEX index_favorites_on_user_account_id
ON app.favorites
USING btree (user_account_id);

CREATE UNIQUE INDEX index_faqs_on_question
ON app.faqs
USING btree (question);

-- forbid duplicate faqs for a given faqable
CREATE UNIQUE INDEX index_faqables_on_faq
ON app.faqables
USING btree (faq_id, faqed_id, faqed_type);

-- forbid duplicate positioning for a given faqable
CREATE UNIQUE INDEX index_faqables_on_position
ON app.faqables
USING btree (faqed_id, faqed_type, position);

CREATE UNIQUE INDEX index_forum_posts_on_external_id
ON app.forum_posts
USING btree (external_id);

CREATE INDEX index_forum_recommendations_on_course_id
ON app.forum_recommendations
USING btree (course_id);

CREATE INDEX index_forum_recommendations_on_forum_post_id
ON app.forum_recommendations
USING btree (forum_post_id);

CREATE INDEX index_images_on_imageable_type_and_imageable_id
ON app.images
USING btree (imageable_type, imageable_id);

CREATE UNIQUE INDEX index_landing_pages_on_slug
ON app.landing_pages
USING btree (slug);

CREATE INDEX index_oauth_accounts_on_user_account_id
ON app.oauth_accounts
USING btree (user_account_id);

CREATE UNIQUE INDEX index_orphaned_profiles_on_user_account_id
ON app.orphaned_profiles
USING btree (user_account_id);

CREATE INDEX index_orphaned_profiles_on_name
ON app.orphaned_profiles
USING btree (name);

CREATE INDEX index_post_relations_on_post_id
ON app.post_relations
USING btree (post_id);

CREATE INDEX index_post_relations_on_relation_fields
ON app.post_relations
USING btree (relation_id, relation_type);

CREATE UNIQUE INDEX index_post_relations_unique
ON app.post_relations
USING btree (relation_id, relation_type, post_id);

CREATE INDEX index_posts_on_admin_account_id
ON app.posts
USING btree (admin_account_id);

CREATE INDEX index_posts_on_original_post_id
ON app.posts
USING btree (original_post_id);

CREATE INDEX index_posts_on_cover_image_id
ON app.posts
USING btree (cover_image_id);

CREATE UNIQUE INDEX index_posts_on_slug
ON app.posts
USING btree (slug);

CREATE INDEX index_posts_on_tags
ON app.posts
USING gin (tags);

CREATE INDEX index_preview_course_pricings_on_preview_course_id
ON app.preview_course_pricings
USING btree (preview_course_id);

CREATE UNIQUE INDEX index_preview_course_pricing_uniqueness
ON app.preview_course_pricings
USING btree (
              preview_course_id,
              pricing_type,
              plan_type,
              COALESCE(customer_type, 'unknown'),
              currency,
              COALESCE(payment_period_unit, 'unknown'),
              COALESCE(subscription_period_unit, 'unknown'),
              COALESCE(trial_period_unit, 'unknown')
            );

CREATE INDEX index_profiles_on_user_account_id
ON app.profiles
USING btree (user_account_id);

CREATE UNIQUE INDEX index_profiles_on_username
ON app.profiles
USING btree (_username);

CREATE UNIQUE INDEX profiles_username_idx
ON app.profiles (username);

CREATE INDEX index_profile_courses_on_profile_and_course_id
  ON app.profile_courses USING btree (profile_id,
  course_id);

CREATE UNIQUE INDEX index_promo_accounts_on_user_account_id
ON app.promo_accounts
USING btree (user_account_id);

CREATE INDEX index_promotions_on_provider_id_and_status
ON app.promotions
USING btree (provider_id, status);

CREATE UNIQUE INDEX index_provider_logos_on_direct_upload_id
ON app.provider_logos
USING btree (direct_upload_id);

CREATE UNIQUE INDEX index_provider_logos_on_provider_id
ON app.provider_logos
USING btree (provider_id);

CREATE UNIQUE INDEX index_providers_on_name
ON app.providers
USING btree (name);

CREATE UNIQUE INDEX index_providers_on_slug
ON app.providers
USING btree (slug);

CREATE INDEX index_providers_on_old_id
ON app.providers
USING btree (old_id)
WHERE old_id IS NOT NULL;

CREATE UNIQUE INDEX index_providers_on_domain
ON app.providers
USING btree (domain)
WHERE domain IS NOT NULL AND published = true;

CREATE UNIQUE INDEX index_providers_on_url
ON app.providers
USING btree (url)
WHERE url IS NOT NULL AND published = true;

CREATE UNIQUE INDEX index_provider_ownerships_on_user_and_provider
ON app.provider_ownerships
USING btree (user_account_id, provider_id);

CREATE UNIQUE INDEX index_provider_ownership_creation_pending
ON app.provider_ownership_creations
USING btree (user_account_id)
WHERE status = 'pending'::app.provider_ownership_creation_status;

CREATE UNIQUE INDEX index_provider_ownership_creation_succeeded
ON app.provider_ownership_creations
USING btree (user_account_id, domain)
WHERE status = 'succeeded'::app.provider_ownership_creation_status;

CREATE UNIQUE INDEX index_slug_histories_on_course_id_and_slug
ON app.slug_histories
USING btree (course_id, slug);

CREATE INDEX index_subscriptions_on_profiles_id
ON app.subscriptions
USING btree (profile_id);

CREATE INDEX index_study_lists_on_user_account_id
ON app.study_lists
USING btree (user_account_id);

CREATE INDEX index_study_lists_on_tags
ON app.study_lists
USING gin (tags);

CREATE INDEX index_study_lists_on_slugs
ON app.study_lists
USING btree (slug);

CREATE UNIQUE INDEX index_study_lists_unique_user_account_id_per_standard
ON app.study_lists
USING btree (user_account_id)
WHERE standard = true;

CREATE INDEX index_study_list_entries_on_course_id
ON app.study_list_entries
USING btree (course_id);

CREATE INDEX index_study_list_entries_on_study_list_id
ON app.study_list_entries
USING btree (study_list_id);

CREATE UNIQUE INDEX index_study_list_entries_course_study_list_uniqueness
ON app.study_list_entries
USING btree (course_id, study_list_id);

CREATE UNIQUE INDEX index_tracked_actions_on_compound_ext_id
ON app.tracked_actions
USING btree (compound_ext_id);

CREATE INDEX index_tracked_actions_on_enrollment_id
ON app.tracked_actions
USING btree (enrollment_id);

CREATE INDEX index_tracked_actions_on_payload
ON app.tracked_actions
USING gin (payload);

CREATE INDEX index_tracked_actions_on_status
ON app.tracked_actions
USING btree (status);

CREATE UNIQUE INDEX used_usernames_username_idx
ON app.used_usernames (username);

CREATE UNIQUE INDEX used_usernames_profile_id_username_idx
ON app.used_usernames (profile_id, username);

CREATE UNIQUE INDEX index_user_accounts_on_confirmation_token
ON app.user_accounts
USING btree (confirmation_token);

CREATE UNIQUE INDEX index_user_accounts_on_email
ON app.user_accounts
USING btree (email);

CREATE UNIQUE INDEX index_user_accounts_on_reset_password_token
ON app.user_accounts
USING btree (reset_password_token);

CREATE UNIQUE INDEX index_user_accounts_on_unlock_token
ON app.user_accounts
USING btree (unlock_token);

CREATE UNIQUE INDEX index_wallets_on_user_account_id_unique
  ON app.wallets USING btree (user_account_id);

CREATE INDEX index_instructors_on_user_account_id ON
  app.instructors USING btree (user_account_id);

CREATE INDEX index_instructors_on_name ON app.instructors
  USING btree (name);

CREATE UNIQUE INDEX
  index_instructors_on_provider_id_and_slug ON
  app.instructors USING btree (provider_id, slug);

CREATE UNIQUE INDEX index_instructors_on_slug ON
  app.instructors USING btree (slug);

-- useful for ilike queries on slug
CREATE INDEX index_gin_instructors_on_slug ON
  app.instructors USING gin (slug gin_trgm_ops);

CREATE UNIQUE INDEX index_offered_by_on_course_and_offeror
ON app.offered_by
USING btree (course_id, offeror_id, offeror_type);

CREATE INDEX index_instructor_courses_on_instructor_and_course_id
ON app.instructor_courses
USING btree (instructor_id, course_id);

CREATE INDEX index_organization_courses_on_organization_and_course_id
ON app.organization_courses
USING btree (organization_id, course_id);

CREATE INDEX ahoy_events_visit_id_index ON app.ahoy_events (visit_id);
CREATE INDEX ahoy_events_name_index ON app.ahoy_events (name);
CREATE INDEX ahoy_events_time_index ON app.ahoy_events (time);
CREATE INDEX ahoy_events_properties_index ON app.ahoy_events USING gin (properties jsonb_path_ops);

CREATE UNIQUE INDEX ahoy_visits_visit_token_index ON app.ahoy_visits (visit_token);
CREATE UNIQUE INDEX ahoy_visits_id_index ON app.ahoy_visits (id);

CREATE UNIQUE INDEX index_topics_on_key
ON app.topics
USING btree (key);

CREATE UNIQUE INDEX index_reviews_on_user_account_id_and_reviewable
ON app.reviews
USING btree (user_account_id, reviewable_id, reviewable_type);

CREATE INDEX index_exit_clicks_on_date
ON bi.exit_clicks
USING btree (date);

CREATE INDEX index_sales_on_date
ON bi.sales
USING btree (date);

CREATE ROLE "anonymous" LOGIN;

GRANT USAGE ON SCHEMA jwt        TO "anonymous";
GRANT USAGE ON SCHEMA settings   TO "anonymous";
GRANT USAGE ON SCHEMA api_developer_v1  TO "anonymous";
GRANT USAGE ON SCHEMA api_keys   TO "anonymous";
GRANT USAGE ON SCHEMA app        TO "anonymous";

GRANT SELECT, INSERT, UPDATE, DELETE ON app.courses           TO "anonymous";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_developer_v1.courses     TO "anonymous";
GRANT SELECT, UPDATE                 ON app.providers         TO "anonymous";
GRANT SELECT, UPDATE                 ON api_developer_v1.providers   TO "anonymous";

GRANT SELECT ON ALL TABLES IN SCHEMA api_keys TO "anonymous";
GRANT SELECT ON app.api_keys                  TO "anonymous";

CREATE USER marketing WITH PASSWORD '$MARKETING_PASSWORD';

GRANT CONNECT ON DATABASE $POSTGRES_DB    TO "marketing";
GRANT USAGE   ON SCHEMA app               TO "marketing";
GRANT USAGE   ON SCHEMA bi                TO "marketing";
GRANT SELECT  ON ALL TABLES IN SCHEMA app TO "marketing";
GRANT SELECT  ON ALL TABLES IN SCHEMA bi  TO "marketing";

ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT ON TABLES TO "marketing";
ALTER DEFAULT PRIVILEGES IN SCHEMA bi  GRANT SELECT ON TABLES TO "marketing";

-- pgFormatter-ignore
CREATE ROLE "user" LOGIN;

GRANT USAGE ON SCHEMA api           TO "user";
GRANT USAGE ON SCHEMA app           TO "user";
GRANT USAGE ON SCHEMA jwt           TO "user";
GRANT USAGE ON SCHEMA settings      TO "user";
GRANT USAGE ON SCHEMA transliterate TO "user";

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO "user";

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES  ON public.que_jobs                       TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES  ON public.que_lockers                    TO "user";
GRANT USAGE,  SELECT                              ON SEQUENCE que_jobs_id_seq                                            TO "user";

GRANT SELECT, INSERT, UPDATE, DELETE             ON app.certificates                       TO "user";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.course_reviews                     TO "user";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.crawler_domains                    TO "user";
GRANT SELECT                                     ON app.crawling_events                    TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.direct_uploads                     TO "user";
GRANT SELECT                                     ON app.domain_ownerships                  TO "user";
GRANT SELECT, INSERT                             ON app.domain_ownership_verifications     TO "user";
GRANT SELECT                                     ON app.domain_ownership_verification_logs TO "user";
GRANT SELECT                                     ON app.faqables                           TO "user";
GRANT SELECT                                     ON app.faqs                               TO "user";
GRANT SELECT, REFERENCES                         ON app.orphaned_profiles                  TO "user";
GRANT SELECT, INSERT,         DELETE             ON app.preview_courses                    TO "user";
GRANT SELECT, INSERT,         DELETE             ON app.preview_course_images              TO "user";
GRANT SELECT,         UPDATE                     ON app.profiles                           TO "user";
GRANT SELECT,         UPDATE                     ON app.providers                          TO "user";
GRANT SELECT                                     ON app.provider_ownerships                TO "user";
GRANT SELECT, INSERT                             ON app.provider_ownership_creations       TO "user";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.promo_accounts                     TO "user";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.promo_account_logs                 TO "user";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.providers                          TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.provider_crawlers                  TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.provider_logos                     TO "user";
GRANT SELECT, INSERT                             ON app.redeems                            TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.reviews                            TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.study_lists                        TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.study_list_entries                 TO "user";
GRANT SELECT,         UPDATE,         REFERENCES ON app.user_accounts                      TO "user";
GRANT SELECT, INSERT                             ON app.used_usernames                     TO "user";
GRANT SELECT, INSERT, UPDATE                     ON app.wallets                            TO "user";
GRANT SELECT                                     ON app.wallet_transactions                TO "user";
GRANT SELECT                                     ON transliterate.symbols                  TO "user";


GRANT SELECT, INSERT, UPDATE, DELETE ON api.certificates                       TO "user";
GRANT SELECT, INSERT, UPDATE         ON api.crawler_domains                    TO "user";
GRANT SELECT                         ON api.crawling_events                    TO "user";
GRANT SELECT                         ON api.domain_ownerships                  TO "user";
GRANT SELECT, INSERT                 ON api.domain_ownership_verifications     TO "user";
GRANT SELECT                         ON api.domain_ownership_verification_logs TO "user";
GRANT SELECT, INSERT,         DELETE ON api.preview_courses                    TO "user";
GRANT SELECT, INSERT,         DELETE ON api.preview_course_images              TO "user";
GRANT SELECT,         UPDATE         ON api.profiles                           TO "user";
GRANT SELECT, INSERT, UPDATE         ON api.promo_accounts                     TO "user";
GRANT SELECT,         UPDATE         ON api.providers                          TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.provider_crawlers                  TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.provider_logos                     TO "user";
GRANT SELECT                         ON api.provider_ownerships                TO "user";
GRANT SELECT, INSERT                 ON api.provider_ownership_creations       TO "user";
GRANT SELECT, INSERT                 ON api.redeems                            TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.study_lists                        TO "user";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.study_list_entries                 TO "user";
GRANT SELECT,         UPDATE         ON api.user_accounts                      TO "user";
GRANT SELECT                         ON api.settings                           TO "user";
GRANT SELECT, INSERT, UPDATE         ON api.wallets                            TO "user";
GRANT SELECT                         ON api.wallet_transactions                TO "user";

-- pgFormatter-ignore
CREATE ROLE "admin" LOGIN;

GRANT USAGE ON SCHEMA api           TO "admin";
GRANT USAGE ON SCHEMA app           TO "admin";
GRANT USAGE ON SCHEMA jwt           TO "admin";
GRANT USAGE ON SCHEMA api_admin_v1  TO "admin";

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO "admin";

GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.admin_accounts        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.admin_profiles        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.certificates          TO "admin";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.courses               TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.course_reviews        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.crawler_domains       TO "admin";
GRANT SELECT                                     ON app.crawling_events       TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.direct_uploads        TO "admin";
GRANT SELECT, INSERT,         DELETE, REFERENCES ON app.enrollments           TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.favorites             TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.faqables              TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.faqs                  TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.images                TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.landing_pages         TO "admin";
GRANT SELECT,         UPDATE, DELETE, REFERENCES ON app.oauth_accounts        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.orphaned_profiles     TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.posts                 TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.post_relations        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.preview_courses       TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.preview_course_images TO "admin";
GRANT SELECT, INSERT, UPDATE,         REFERENCES ON app.profiles              TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.promo_accounts        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.promo_account_logs    TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.providers             TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.provider_crawlers     TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.provider_logos        TO "admin";
GRANT SELECT, INSERT                             ON app.redeems               TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.reviews               TO "admin";
GRANT SELECT                                     ON app.tracked_actions       TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE             ON app.used_usernames        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.user_accounts         TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.wallets               TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON app.wallet_transactions   TO "admin";

GRANT SELECT, INSERT, UPDATE, DELETE ON api.admin_accounts        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.certificates          TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.crawler_domains       TO "admin";
GRANT SELECT                         ON api.crawling_events       TO "admin";
GRANT SELECT                         ON api.earnings              TO "admin";
GRANT SELECT, INSERT,         DELETE ON api.preview_courses       TO "admin";
GRANT SELECT, INSERT,         DELETE ON api.preview_course_images TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.promo_accounts        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.provider_crawlers     TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api.provider_logos        TO "admin";
GRANT SELECT, INSERT                 ON api.redeems               TO "admin";
GRANT SELECT,         UPDATE, DELETE ON api.user_accounts         TO "admin";
GRANT SELECT, INSERT, UPDATE         ON api.wallets               TO "admin";
GRANT SELECT                         ON api.wallet_transactions   TO "admin";

GRANT SELECT                         ON api_admin_v1.schemas                TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.table_templates        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.tables                 TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.custom_fields          TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.tables_custom_fields   TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.custom_actions         TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.tables_custom_actions  TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.admin_accounts         TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.posts                  TO "admin";
GRANT SELECT, INSERT, UPDATE         ON api_admin_v1.providers              TO "admin";
GRANT SELECT,         UPDATE, DELETE ON api_admin_v1.user_accounts          TO "admin";
GRANT SELECT                         ON api_admin_v1.enrollments            TO "admin";
GRANT SELECT                         ON api_admin_v1.tracked_actions        TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.topics                 TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.organizations          TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.instructors            TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.faqs                   TO "admin";
GRANT SELECT, INSERT, UPDATE, DELETE ON api_admin_v1.contacts               TO "admin";

CREATE ROLE "authenticator" NOINHERIT LOGIN PASSWORD '$AUTHENTICATOR_PASSWORD';

GRANT "user"      TO "authenticator";
GRANT "admin"     TO "authenticator";
GRANT "anonymous" TO "authenticator";

GRANT USAGE ON SCHEMA api      TO "authenticator";
GRANT USAGE ON SCHEMA jwt      TO "authenticator";
GRANT USAGE ON SCHEMA settings TO "authenticator";

GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA app TO "authenticator";

GRANT SELECT ON app.user_accounts, app.admin_accounts TO "authenticator";

CREATE USER stitch WITH PASSWORD '$STITCHDATA_PASSWORD';

GRANT CONNECT ON DATABASE $POSTGRES_DB    TO "stitch";
GRANT CREATE  ON DATABASE $POSTGRES_DB    TO "stitch";
GRANT CREATE  ON SCHEMA bi                TO "stitch";
GRANT USAGE   ON SCHEMA bi                TO "stitch";

INSERT INTO app.forums (name, slug, url) VALUES
('Hacker News', 'hacker-news', 'https://news.ycombinator.com/'),
('Stack Overflow', 'stack-overflow', 'https://stackoverflow.com/');

INSERT INTO public.schema_migrations(version) VALUES
  ('20190819000000'),
  ('20210416120544'),
  ('20210521192013'),
  ('20210528005719'),
  ('20210528205711'),
  ('20210601141744'),
  ('20210607125358'),
  ('20210607140358'),
  ('20210607173602'),
  ('20210607183405'),
  ('20210608000417'),
  ('20210608115321'),
  ('20210608143355'),
  ('20210608182035'),
  ('20210608182715'),
  ('20210614150007'),
  ('20210629094657'),
  ('20210629141739'),
  ('20210707140104'),
  ('20210707205227'),
  ('20210720151640'),
  ('20210720210645'),
  ('20210721201131'),
  ('20210723211046');

INSERT INTO settings.secrets (key, value) VALUES ('cipher_key', '$CIPHER_KEY');
INSERT INTO settings.secrets (key, value) VALUES ('cipher_iv', '$CIPHER_IV');

INSERT INTO settings.global (subdomains, minimum_redeemable_amount) VALUES ('{"(en,)","(es,)","(pt,BR)","(ja,)","(de,)","(fr,)"}',20);

BEGIN;

-- CUSTOM FIELDS
-- Country Flag
INSERT INTO api_admin_v1.custom_fields(id, name, data_type, alias, description, jst)
  VALUES
  (
    'ef020e75-d605-4252-8aef-80261c0230fa',
    'tracking_data.country',
    'text',
    'tracking_data.country',
    'Shows the country flag',
    'return `<svg class=\"h1em w1em\"><use xlink:href=#country-flags-${(slotProps.record.tracking_data.country || "n/a").toLowerCase()} /></svg>`;'
  );

-- Browser & OS
INSERT INTO api_admin_v1.custom_fields(id, name, data_type, alias, description, jst)
  VALUES
  (
    '829588fe-3f50-48db-b4b8-313ec2512844',
    'tracking_data.user_agent',
    'text',
    'tracking_data.user_agent',
    'Shows the user agent using the format [browser:os]',
    'return `${slotProps.record.tracking_data.user_agent.browser}:${slotProps.record.tracking_data.user_agent.os}`;'
  );

-- Preferred Languages
INSERT INTO api_admin_v1.custom_fields(id, name, data_type, alias, description, jst)
  VALUES
  (
    '4d998755-286c-4ef0-a022-fd3a007688c3',
    'tracking_data.preferred_languages',
    'text',
    'tracking_data.preferred_languages',
    'Shows the browser languages',
    'return slotProps.record.tracking_data.preferred_languages.join(",");'
  );

-- Course URL
INSERT INTO api_admin_v1.custom_fields(id, name, data_type, alias, description, jst)
  VALUES
  (
    '2e70660c-b211-4a57-be4a-fdf9f42e43f9',
    'course.url',
    'text',
    'course.url',
    'Shows course.url as a link',
    'return if (!!slotProps.record.course) { return `<a target="_blank" href=${slotProps.record.course.url}>${slotProps.record.course.url}</a>` };'
  );

-- META RESOURCES
-- Table Templates
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    '851cc0eb-21c5-4dfa-b31d-a9314467d923',
    'table_templates',
    'system:table_templates',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_select,default_order)
  VALUES (
    'system:table_templates',
    '851cc0eb-21c5-4dfa-b31d-a9314467d923',
    '[
      {"name": "id",                                "alias": "id"},
      {"name": "name",                              "alias": "name"},
      {"name": "table_id",                          "alias": "table_id"},
      {"name": "description",                       "alias": "description"},
      {"name": "schema",                            "alias": "schema"},
      {"name": "default_fields",                    "alias": "default_fields"},
      {"name": "default_select",                    "alias": "default_select"},
      {"name": "default_order",                     "alias": "default_order"},
      {"name": "default_filter",                    "alias": "default_filter"},
      {"name": "admin_account_id",                  "alias": "admin_account_id"},
      {"name": "admin_account.email",               "alias": "admin_account.email"},
      {"name": "admin_account.name",                "alias": "admin_account.name"},
      {"name": "created_at",                        "alias": "created_at"},
      {"name": "updated_at",                        "alias": "updated_at"}
    ]',
    'select=*,admin_account:admin_accounts(email,name)',
    'order=name.asc'
  );

-- Tables
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    '738bd708-43c8-4f4c-acb5-3ab103c1ac20',
    'tables',
    'system:tables',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_select,default_order)
  VALUES (
    'system:tables',
    '738bd708-43c8-4f4c-acb5-3ab103c1ac20',
    '[
      {"name": "id",                                "alias": "id"},
      {"name": "resource",                          "alias": "resource"},
      {"name": "name",                              "alias": "name"},
      {"name": "description",                       "alias": "description"},
      {"name": "system",                            "alias": "system"},
      {"name": "admin_account_id",                  "alias": "admin_account_id"},
      {"name": "admin_account.email",               "alias": "admin_account.email"},
      {"name": "admin_account.name",                "alias": "admin_account.name"},
      {"name": "created_at",                        "alias": "created_at"},
      {"name": "updated_at",                        "alias": "updated_at"}
    ]',
    'select=*,admin_account:admin_accounts(email,name)',
    'order=name.asc'
  );

-- Custom Fields
INSERT INTO api_admin_v1.tables (id, resource, name, system)
  VALUES (
    'e7b0d810-0417-4b50-8490-00627ab5fd07',
    'custom_fields',
    'system:custom_fields',
    true
  );

INSERT INTO api_admin_v1.table_templates (name, table_id, default_fields, default_select, default_order)
  VALUES (
    'system:custom_fields',
    'e7b0d810-0417-4b50-8490-00627ab5fd07',
    '[
      {"name": "id",                                "alias": "id"},
      {"name": "name",                              "alias": "name"},
      {"name": "alias",                             "alias": "alias"},
      {"name": "description",                       "alias": "description"},
      {"name": "data_type",                         "alias": "data_type"},
      {"name": "jst",                               "alias": "jst"},
      {"name": "admin_account_id",                  "alias": "admin_account_id"},
      {"name": "admin_account.email",               "alias": "admin_account.email"},
      {"name": "admin_account.name",                "alias": "admin_account.name"},
      {"name": "created_at",                        "alias": "created_at"},
      {"name": "updated_at",                        "alias": "updated_at"}
    ]',
    'select=*,admin_account:admin_accounts(email,name)',
    'order=name.asc'
  );

-- tables_custom_fields
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    'e4e72de9-bb42-4319-9b16-a53f980a4358',
    'tables_custom_fields',
    'system:tables_custom_fields',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_select,default_order)
  VALUES (
    'system:tables_custom_fields',
    'e4e72de9-bb42-4319-9b16-a53f980a4358',
    '[
      {"name": "table_id",                                "alias": "id"},
      {"name": "custom_field_id",                         "alias": "id"},
      {"name": "table.name",                              "alias": "table.name"},
      {"name": "custom_field.name",                       "alias": "custom_field.name"}
    ]',
    'select=*,table:tables(name),custom_field:custom_fields(name)',
    'order=created_at.desc'
  );

-- Enrollments
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    'enrollments',
    'system:enrollments',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_select,default_order)
  VALUES (
    'system:enrollments',
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    '[
      {"name": "id",                                "alias": "id"},
      {"name": "course.name",                       "alias": "course.name"},
      {"name": "course.url",                        "alias": "course.url"},
      {"name": "tracked_url",                       "alias": "tracked_url"},
      {"name": "tracking_data.ip",                  "alias": "tracking_data.ip"},
      {"name": "tracking_data.utm_source",          "alias": "tracking_data.utm_source"},
      {"name": "tracking_data.utm_campaign",        "alias": "tracking_data.utm_campaign"},
      {"name": "tracking_data.utm_medium",          "alias": "tracking_data.utm_medium"},
      {"name": "tracking_data.gclid",               "alias": "tracking_data.gclid"},
      {"name": "tracking_data.referer",             "alias": "tracking_data.referer"},
      {"name": "provider.name",                     "alias": "provider.name"},
      {"name": "course.name",                       "alias": "course.name"},
      {"name": "user_account.email",                "alias": "user_account.email"},
      {"name": "created_at",                        "alias": "created_at"},
      {"name": "updated_at",                        "alias": "updated_at"}
    ]',
    'select=*,provider:providers(name),course:courses(name, url),user_account:user_accounts(id,email)',
    'order=created_at.desc'
  );


INSERT INTO api_admin_v1.tables_custom_fields (table_id, custom_field_id)
  VALUES (
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    '2e70660c-b211-4a57-be4a-fdf9f42e43f9'
  );

INSERT INTO api_admin_v1.tables_custom_fields (table_id, custom_field_id)
  VALUES (
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    'ef020e75-d605-4252-8aef-80261c0230fa'
  );

INSERT INTO api_admin_v1.tables_custom_fields (table_id, custom_field_id)
  VALUES (
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    '829588fe-3f50-48db-b4b8-313ec2512844'
  );

INSERT INTO api_admin_v1.tables_custom_fields (table_id, custom_field_id)
  VALUES (
    '6f3e84c3-2735-485c-97d0-b9c6605c8067',
    '4d998755-286c-4ef0-a022-fd3a007688c3'
  );

-- Promotions
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    '0fbcdd6e-0a09-4d9e-bc91-02226e89e4aa',
    'promotions',
    'system:promotions',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_order)
  VALUES (
    'promotions',
    '0fbcdd6e-0a09-4d9e-bc91-02226e89e4aa',
    '[
      {"name": "id",                    "alias": "id"},
      {"name": "name",                  "alias": "name"},
      {"name": "headline",              "alias": "headline"},
      {"name": "status",                "alias": "status"},
      {"name": "starts_at",             "alias": "starts_at"},
      {"name": "ends_at",               "alias": "ends_at"},
      {"name": "terms_and_conditions",  "alias": "terms_and_conditions"},
      {"name": "created_at",            "alias": "created_at"},
      {"name": "updated_at",            "alias": "updated_at"}
    ]',
    'order=name.asc'
  );


-- Topics
INSERT INTO api_admin_v1.tables (id,resource,name,system)
  VALUES (
    '31f72a9b-3b1b-446d-bf42-2c6b6a816760',
    'topics',
    'system:topics',
    true
  );

INSERT INTO api_admin_v1.table_templates (name,table_id,default_fields,default_select,default_order)
  VALUES (
    'topics',
    '31f72a9b-3b1b-446d-bf42-2c6b6a816760',
    '[
      {"name": "id", "alias": "id"},
      {"name": "name", "alias": "name"},
      {"name": "key", "alias": "key"},
      {"name": "featured", "alias": "featured"},
      {"name": "popularity", "alias": "popularity"},
      {"name": "description", "alias": "description"},
      {"name": "created_at", "alias": "created_at"},
      {"name": "updated_at", "alias": "updated_at"}
    ]',
    'select=*',
    'order=name.asc'
  );


COMMIT;


-- here for debugging purposes
CREATE SCHEMA IF NOT EXISTS "pgdiff";

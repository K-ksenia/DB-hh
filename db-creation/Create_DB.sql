CREATE TYPE user_type AS ENUM (
    'SEEKER',
    'RECRUITER'
);

CREATE TYPE visibility_status AS ENUM (
    'ALL INTERNET',
    'NOBODY',
    'REGISTERED',
    'BY REFERENCE'
);

CREATE TYPE busyness_type AS ENUM (
    'FULL_TIME',
    'PART_TIME',
    'FLEXIBLE',
    'REMOTE'
);

CREATE TYPE interaction_status AS ENUM (
    'WHATCHED',
    'NOTWHATCHED',
    'INVITED',
    'REJECTED'
);

CREATE TYPE interaction_type AS ENUM (
    'REPLY',
    'INVITE'
);

CREATE TABLE account (
    account_id SERIAL PRIMARY KEY,
    login varchar(30) UNIQUE NOT NULL,
    password text NOT NULL,
    registration_time timestamptz NOT NULL,
    last_login_time timestamptz,
    account_type user_type NOT NULL
);

CREATE TABLE resume (
    resume_id SERIAL PRIMARY KEY,
    account_id int REFERENCES account NOT NULL,
    full_name varchar(256) NOT NULL,
    position varchar(256) NOT NULL,
    date_of_birth date,
    city varchar(60) NOT NULL,
    salary int4range,                -- Вилка ЗП
    busyness busyness_type,
    publication_begin_time timestamptz NOT NULL, -- Время размещения
    publication_end_time timestamptz,     -- Время окончания публикации
    status visibility_status NOT NULL,
    active bool NOT NULL
);

CREATE TABLE experience (
    experience_id SERIAL PRIMARY KEY,
    resume_id int REFERENCES resume NOT NULL,
    position varchar(256) NOT NULL,
    company_name varchar(256) NOT NULL,
    begin_time date NOT NULL,
    end_time date
);

CREATE TABLE company (
    company_id SERIAL PRIMARY KEY,
    company_name varchar(256) NOT NULL,
    description text,
    registration_time timestamptz NOT NULL
);

CREATE TABLE recruiter (
    recruiter_id SERIAL PRIMARY KEY,
    account_id int REFERENCES account NOT NULL,
    company_id int REFERENCES company NOT NULL,
    begin_time timestamptz NOT NULL,
    end_time timestamptz 
);

CREATE TABLE vacancy (
    vacancy_id SERIAL PRIMARY KEY,
    recruiter_id int REFERENCES recruiter NOT NULL,
    company_id int REFERENCES company NOT NULL,        --?
    position varchar(256) NOT NULL,
    description text,
    salary int4range,                -- Вилка ЗП
    busyness busyness_type,             -- Требуемая занятость
    required_experience real,         -- Требуемый опыт работы в годах
    publication_begin_time timestamptz NOT NULL,     -- Время размещения
    publication_end_time timestamptz,                 -- Время окончания публикации
    status visibility_status NOT NULL,
    active bool NOT NULL
);

CREATE TABLE interaction (
    interaction_id SERIAL PRIMARY KEY,
    resume_id int REFERENCES resume NOT NULL,
    vacancy_id int REFERENCES vacancy NOT NULL,
    publication_time timestamptz NOT NULL,
    interaction_type interaction_type NOT NULL,
    status interaction_status NOT NULL
);

CREATE TABLE message (
    message_id SERIAL PRIMARY KEY,
    interaction_id int REFERENCES interaction NOT NULL,
    message_text text NOT NULL,
    sender user_type NOT NULL,
    sending_time timestamptz NOT NULL
);

CREATE TABLE skill (
    skill_id SERIAL PRIMARY KEY,
    skill_name varchar(128) NOT NULL,
    confirmed bool NOT NULL
);

CREATE TABLE skill_to_resume (
    skill_to_resume_id SERIAL PRIMARY KEY,
    skill_id int REFERENCES skill NOT NULL,
    resume_id int REFERENCES resume NOT NULL
);

CREATE TABLE skill_to_vacancy (
    skill_to_vacancy_id SERIAL PRIMARY KEY,
    skill_id int REFERENCES skill NOT NULL,
    vacancy_id int REFERENCES vacancy NOT NULL
);
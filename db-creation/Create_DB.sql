CREATE TYPE user_type AS ENUM (
    'Seeker',
    'Recruiter'
);

CREATE TYPE visibility_status AS ENUM (
    'Видно всему интернету',
    'Не видно никому',
    'Видно зарегистрированным',
    'Видно только по ссылке'
);

CREATE TYPE busyness_type AS ENUM (
    'Full_time',
    'Part_time',
    'Flexible',
    'Remote'
);

CREATE TYPE interaction_status AS ENUM (
    'Whatched',
    'NotWhatched',
    'Invited',
    'Rejected'
);

CREATE TYPE interaction_type AS ENUM (
    'Reply',
    'Invite'
);

CREATE TABLE Account (
    account_id SERIAL PRIMARY KEY,
    login varchar(30) UNIQUE NOT NULL,
    password varchar(30) NOT NULL,
    registration_time timestamptz NOT NULL,
    last_login_time timestamptz,
    account_type user_type NOT NULL
);

CREATE TABLE Resume (
    resume_id SERIAL PRIMARY KEY,
    account_id int REFERENCES Account NOT NULL,
    position varchar(256) NOT NULL,
    full_name varchar(256) NOT NULL,
    age int,
    city varchar(60) NOT NULL,
    salary int4range,                -- Вилка ЗП
    experience real,                 -- Опыт работы в годах
    busyness busyness_type,
    publication_begin_time timestamptz NOT NULL, -- Время размещения
    publication_end_time timestamptz,     -- Время окончания публикации
    status visibility_status NOT NULL,
    valid bool NOT NULL
);

CREATE TABLE Company (
    company_id SERIAL PRIMARY KEY,
    company_name varchar(256) NOT NULL,
    description text,
    registration_time timestamptz,
    sphere varchar(128)[]
);

CREATE TABLE Recruiter (
    recruiter_id SERIAL PRIMARY KEY,
    account_id int REFERENCES Account NOT NULL,
    company_id int REFERENCES Company NOT NULL,
    begin_time timestamptz NOT NULL,
    end_time timestamptz 
);

CREATE TABLE Vacancy (
    vacancy_id SERIAL PRIMARY KEY,
    recruiter_id int REFERENCES Recruiter NOT NULL,
    company_id int REFERENCES Company NOT NULL,        --?
    position varchar(30) NOT NULL,
    description text,
    salary int4range,                -- Вилка ЗП
    required_experience real,         -- Требуемый опыт работы в годах
    publication_begin_time timestamptz NOT NULL,     -- Время размещения
    publication_end_time timestamptz,                 -- Время окончания публикации
    status visibility_status NOT NULL,
    valid bool NOT NULL
);

CREATE TABLE Interaction (
    interaction_id SERIAL PRIMARY KEY,
    resume_id int REFERENCES Resume NOT NULL,
    vacancy_id int REFERENCES Vacancy NOT NULL,
    publication_time timestamptz NOT NULL,
    interaction_type interaction_type NOT NULL,
    status interaction_status NOT NULL
);

CREATE TABLE Message (
    message_id SERIAL PRIMARY KEY,
    interaction_id int REFERENCES Interaction NOT NULL,
    message_text text NOT NULL,
    sender user_type NOT NULL,
    sending_time timestamptz NOT NULL
);

CREATE TABLE Skill (
    skill_id SERIAL PRIMARY KEY,
    skill_name varchar(128) NOT NULL,
    valid bool NOT NULL
);

CREATE TABLE Skills_to_Resume (
    skills_to_resume_id SERIAL PRIMARY KEY,
    skill_id int REFERENCES Skill NOT NULL,
    resume_id int REFERENCES Resume NOT NULL
);

CREATE TABLE Skills_to_Vacancy (
    skills_to_vacancy_id SERIAL PRIMARY KEY,
    skill_id int REFERENCES Skill NOT NULL,
    vacancy_id int REFERENCES Vacancy NOT NULL
);
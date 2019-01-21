CREATE EXTENSION pgcrypto;

INSERT INTO account (
    login,
    password,
    registration_time,
    account_type
) VALUES ('petrovpetya@gmail.com', crypt('123451988', gen_salt('bf')), '2018-11-01 12:00:00', 'SEEKER'),
('sirsidr@yandex.ru', crypt('qwert12345', gen_salt('bf')), '2018-11-02 12:00:00', 'SEEKER'),
('subaru15@gmail.com', crypt('2ue23oi', gen_salt('bf')), '2018-11-03 12:00:00', 'SEEKER'),
('lolik@gmail.com', crypt('nfjs111', gen_salt('bf')), '2018-11-04 12:00:00', 'SEEKER'),
('bolek@gmail.com', crypt('qwerty', gen_salt('bf')), '2018-11-04 13:00:00', 'SEEKER'),
('lampard@gmail.com', crypt('22041985', gen_salt('bf')), '2018-11-05 12:00:00', 'RECRUITER'),
('nitochka@gmail.com', crypt('alskjd', gen_salt('bf')), '2018-11-06 12:00:00', 'RECRUITER'),
('fernando@gmail.com', crypt('zxcvb', gen_salt('bf')), '2018-11-07 12:00:00', 'RECRUITER'),
('ledokol@gmail.com', crypt('lenin1917', gen_salt('bf')), '2018-11-10 12:00:00', 'RECRUITER'),
('lesorub@gmail.com', crypt('grozniy1547', gen_salt('bf')), '2018-11-17 12:00:00', 'RECRUITER')
;

INSERT INTO resume (
    account_id,
    full_name,
    position,
    date_of_birth,
    city,
    salary,                -- Вилка ЗП
    busyness,
    publication_begin_time, -- Время размещения
    status,
    active
) VALUES (1, 
    'Петров Петр Петрович',
    'Разработчик машинного обучения', 
    '1990-11-05', 
    'Москва', 
    INT4RANGE(95000,120000), 
    'FULL_TIME', 
    '2018-12-01 00:21:46+03', 
    'ALL INTERNET', 
    TRUE),
(1, 
    'Петров Петр Петрович',
    'Разработчик Python', 
    '1990-11-05', 
    'Москва', 
    INT4RANGE(90000,110000), 
    'FULL_TIME', 
    '2018-12-01 00:48:46+03', 
    'ALL INTERNET', 
    TRUE),
(2, 
    'Сидоров Сидр Cидорович', 
    'Руководитель складской логистики', 
    '1980-01-09', 
    'Москва', 
    INT4RANGE(55000,70000), 
    'PART_TIME', 
    '2018-12-02 14:21:46+03', 
    'REGISTERED', 
    TRUE),
(3, 
    'Маремшаов Азамат Рашидович',
    'Педагог музыкальной школы', 
    '1991-04-09', 
    'Москва', 
    INT4RANGE(40000,90000), 
    'PART_TIME', 
    '2018-05-03 08:21:46+03', 
    'REGISTERED', 
    TRUE),
(4, 
    'Польский Лелек', 
    'Мультипликатор', 
    '1984-11-05', 
    'Москва', 
    INT4RANGE(60000,80000), 
    'PART_TIME', 
    '2018-12-04 12:21:46+03', 
    'ALL INTERNET', 
    TRUE),
(5, 
    'Польский Болек', 
    'Мультипликатор', 
    '1984-11-05', 
    'Москва', 
    INT4RANGE(60000,80000), 
    'PART_TIME', 
    '2018-12-04 12:43:46+03', 
    'ALL INTERNET', 
    TRUE)
;

INSERT INTO experience (
    resume_id,
    position,
    company_name,
    begin_time,
    end_time
) VALUES (1, 'Разработчик стажер', 'ООО Битые стекла', '2010-09-01', '2011-08-31'),
(1, 'Разработчик Python', 'ООО Битые огурцы', '2011-09-01', NULL),
(2, 'Логистик', 'ЗАО Логичные логти', '2008-09-01', NULL),
(3, 'Билетер', 'Театр Киноактера', '2010-09-01', '2014-12-31'),
(3, 'Артист оркестра', 'Военный оркестр ВВС', '2016-08-01', '2017-10-11'),
(4, 'Актер', 'Польский мультфильм', '1995-02-01', NULL)
;

INSERT INTO company (
    company_name,
    description,
    registration_time
) VALUES ('Яндекс', 
    'Яндекс — ведущая российская интернет-компания, владеющая самой популярной в России поисковой системой и интернет-порталом.',
    '2006-11-23'),
('Тинькофф', 
    'Tinkoff.ru — компания, которая задает тренды на финансовом рынке', 
    '2016-10-20'),
('ДШИ №14', 'Детская школа искусств №14', '2011-05-04')
;

INSERT INTO recruiter (
    account_id,
    company_id,
    begin_time
) VALUES (6, 1, '2017-05-04'),
(7, 2, '2017-05-04'),
(8, 3, '2018-05-04'),
(9, 2, '2018-05-04'),
(10, 1, '2018-05-04')
;

INSERT INTO vacancy (
    recruiter_id,
    company_id,
    position,
    description,
    salary,                 -- Вилка ЗП
    required_experience,    -- Требуемый опыт работы в годах
    publication_begin_time, -- Время размещения
    status,
    active
) VALUES (1, 1, 
    'Разработчик Яндекс.Музыки', 
    'Требования:
    знание C# и .Net Framework;
    знание алгоритмов и структур данных;
    опыт UWP/Windows Phone или WPF;',
    NULL,
    4,
    '2018-05-10',
    'REGISTERED',
    TRUE),
(1, 1, 
    'Аналитик', 
    'Вам предстоит:
    формулировать вопросы, относящиеся к нашему бизнесу, и отвечать на них, пользуясь фактами и цифрами;
    готовить аналитические отчеты об операционной деятельности компании;
    разрабатывать алгоритмы и модели для развития нашего сервиса.',
    NULL,
    2,
    '2018-08-10',
    'REGISTERED',
    TRUE),
(2, 2, 
    'Разработчик машинного обучения', 
    'Требования:
    знание методов машинного обучения и статистики;
    алгоритмическая подготовка;
    знание Java и/или C++;
    базовые знания SQL;
    базовые знания Python (будут плюсом).',
    INT4RANGE(90000,120000),
    4,
    '2018-12-10',
    'ALL INTERNET',
    TRUE),
(3, 3, 
    'Педагог музыкальной школы', 
    'Требования:
    высшее профессиональное образование в сфере музыки;
    опыт работы с детьми;
    навык общения с родителями;',
    INT4RANGE(20000,50000),
    1,
    '2018-05-29',
    'ALL INTERNET',
    TRUE),
(4, 2, 
    'Руководитель складской логистики', 
    'Требования:
    Высшее образование
    Опыт руководства складским комплексом от 3-х лет
    Навыки внедрения WMS-систем с адресным хранением.
    Английский язык на разговорном уровне.
    Отличное знание бизнес-процессов склада
    Успешный опыт выполнения KPI складского комплекса',
    NULL,
    3,
    '2018-11-23',
    'REGISTERED',
    TRUE),
(5, 1, 
    'Fullstack разработчик (Python)', 
    'Требования:
    уверенное знание как минимум одного из языков: Python/JS;
    опыт работы с фреймворками (Flask/Angular);
    опыт работы с системами сборки и управления пакетами;
    знание HTML/CSS;
    опыт работы с базами данных MySQL и MongoDB;',
    NULL,
    2,
    '2018-11-15',
    'ALL INTERNET',
    TRUE),
(5, 1, 
    'Разработчик Python', 
    'Требования:
    Опыт программирования на Python 1.5+ года и знание его экосистемы
    Опыт проектирования и реализации (хотя бы в составе команды) коммерческих web-приложений
    Глубокое понимание принципов ООП и шаблонов проектирования
    Опыт работы с реляционными СУБД (у нас PostgreSQL)
    Опыт работы с git, linux
    Умение быстро разбираться в сложных технических вопросах
    Умение работать по формальной методологии разработки (Agile)',
    NULL,
    1.5,
    '2018-11-29',
    'ALL INTERNET',
    TRUE)
;

INSERT INTO interaction (
    resume_id,
    vacancy_id,
    publication_time,
    interaction_type,
    status
) VALUES (1,3, '2018-12-11', 'REPLY', 'NOTWHATCHED'),
(2,7, '2018-12-02', 'INVITE', 'WHATCHED'),
(3,5, '2018-11-25', 'REPLY', 'NOTWHATCHED'),
(4,4, '2018-12-11', 'INVITE', 'NOTWHATCHED'),
(2,6, '2018-12-01', 'INVITE', 'NOTWHATCHED')
;

INSERT INTO message (
    interaction_id,
    message_text,
    sender,
    sending_time
) VALUES (1, 'Добрый день! Меня заинтересовала представленная Вами вакансия. С уважением, Петр', 'SEEKER', '2018-12-11 12:21:46+03'),
(2, 'Здравствуйте, Петр! Ваше резюме показалось нам очень интересным. Если наше предложение Вам интересно, свяжитесь со мной, пожалуйста. С уважением, Анна', 'RECRUITER', '2018-12-02 12:21:46+03'),
(3, 'Здравствуйте! Меня заинтересовала представленная Вами вакансия. С уважением, Сидр', 'SEEKER', '2018-12-25 12:21:46+03'),
(4, 'Добрый день, Азамат! Ваше резюме показалось нам очень интересным. Если наше предложение Вам интересно, свяжитесь со мной, пожалуйста. С уважением, Виктория', 'RECRUITER', '2018-12-11 12:21:46+03'),
(5, 'Добрый день! Ваше резюме показалось нам очень интересным. С уважением, Яндекс', 'SEEKER', '2018-12-01 12:21:46+03'),
(1, 'Добрый день! Ваша кандидатура нам оч интересна! Вам удобно будет придти на собеседование завтра в 15:00? С уважением, Софья', 'SEEKER', '2018-12-11 15:21:46+03')
;

INSERT INTO skill (
    skill_name,
    confirmed
) VALUES ('Коммуникабельность', TRUE),
('Ответственность', TRUE),
('Многозадачность', TRUE),
('Уверенность в себе', TRUE),
('Организованность', TRUE),
('Пунктуальность', TRUE)
;

INSERT INTO skill_to_resume (
    skill_id,
    resume_id
) VALUES (1,1),
(2,1),
(3,1),
(5,1),
(2,2),
(3,2),
(4,2),
(1,3),
(3,3),
(6,3)
;

INSERT INTO skill_to_vacancy (
    skill_id,
    vacancy_id
) VALUES (1,1),
(2,1),
(3,1),
(5,1),
(2,2),
(3,2),
(4,2),
(1,3),
(3,3),
(6,3)
;
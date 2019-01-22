-----СЦЕНАРИЙ СО СТОРОНЫ СОИСКАТЕЛЯ------

-- Регистрация соискателя на сайте
INSERT INTO account (login, password, registration_time, account_type
) VALUES ('usermail@gmail.com', crypt('userpassword', gen_salt('bf')), CURRENT_TIMESTAMP, 'SEEKER');


-- Авторизация соискателя
UPDATE account SET last_login_time=CURRENT_TIMESTAMP WHERE login='usermail@gmail.com' AND password = crypt('userpassword', password);
-- Этим запросом можем проверять совпадение пароля (Авторизация проходит, если запрос возвращает TRUE)
SELECT (password = crypt('userpassword', password)) AS auth_check FROM account WHERE login='usermail@gmail.com';


-- Создание резюме
INSERT INTO resume (account_id, full_name, position, date_of_birth, city, salary, busyness, publication_begin_time, status, active) 
	VALUES (1,  'Фамилия Имя Отчество', 'Название должности',  '1990-11-05',  'Город',  INT4RANGE(55000,80000),  'FULL_TIME',  CURRENT_TIMESTAMP,  'ALL INTERNET',  TRUE);
-- Подлинковываем скиллы
INSERT INTO skill_to_resume (skill_id,resume_id) VALUES (1,1), (2,1), (3,1), (5,1);
-- Создаем и подлинковываем дополнительный скилл, созданный соискателем
WITH created_skill AS (INSERT INTO skill (skill_name, confirmed) VALUES ('Находчивость', FALSE) RETURNING skill_id)
INSERT INTO skill_to_resume (skill_id,resume_id) VALUES ((SELECT skill_id FROM created_skill), 1);
-- Подлинковываем опыт работы
INSERT INTO experience (resume_id, position, company_name, begin_time, end_time) 
VALUES (1, 'Грибник', 'ООО Грибные поля', '2007-03-01', '2013-04-15'),
(1, 'Переводчик китайского', 'ООО Чайна нечайна', '2013-05-01', NULL);

-- Удаление резюме
UPDATE resume SET publication_end_time = CURRENT_TIMESTAMP, active = FALSE WHERE resume_id=1 


-- 5. Поиск вакансий соискателем
-- * Параметры busyness, city, salary, required_experience, publication_begin_time, company_name задаются соискателем при поиске
-- * Если какой-то параметр пользователем не задан, то опускаем в запросе наложение на него условия
-- Четкий поиск - искать строго по заданным параметрам)
SELECT company_name, position, salary FROM vacancy JOIN company USING (company_id) 
WHERE (busyness = 'FULL_TIME') 
AND city = 'Москва'
AND salary && int4range(80000, 100000)
AND required_experience <= 2 
AND publication_begin_time > '2018-11-01'
AND (status = 'ALL INTERNET' OR status = 'REGISTERED')
AND active = TRUE
AND company_name = 'Яндекс';
-- Нечеткий поиск - искать по заданным параметрам, а также выдавать те результаты, у которых данный параметр не задан вовсе 
-- (Например, не указана ЗП. Это ведь не означает, что она непременно не удовлетворяет нашей))
SELECT company_name, position, salary FROM vacancy JOIN company USING (company_id) 
WHERE (busyness = 'FULL_TIME' OR busyness IS NULL) 
AND city = 'Москва'
AND (salary && int4range(80000, 100000) OR salary is NULL)
AND required_experience <= 2 
AND publication_begin_time > '2018-11-01'
AND (status = 'ALL INTERNET' OR status = 'REGISTERED')
AND active = TRUE
AND company_name = 'Яндекс';


-- Просмотр выбранной соискателем вакансии 
SELECT company_name, position, vacancy.description, salary, required_experience, publication_begin_time 
FROM vacancy JOIN company USING (company_id) 
WHERE vacancy_id = 1;


-- Просмотр информации о компании
SELECT company_name, description FROM company WHERE company_id=1;


-- Просмотр всех вакансий компании
SELECT company_id, position, description, city, salary, busyness, required_experience, publication_begin_time
FROM vacancy
WHERE company_id=1;


-- Отправка соискателем отклика на вакансию
INSERT INTO interaction (resume_id, vacancy_id, publication_time, interaction_type, status) 
VALUES (1, 1, CURRENT_TIMESTAMP, 'REPLY', 'NOTWHATCHED');


-- Просмотр всех приглашений по выбранному резюме
SELECT position, (SELECT company_name FROM company c WHERE c.company_id=v.company_id), publication_time 
FROM interaction JOIN vacancy v USING(vacancy_id)
WHERE resume_id=1 AND interaction_type='INVITE';

-- Просмотр приглашения соискателем
UPDATE interaction SET status='WHATCHED' WHERE interaction_id=1;


-- Отправка соискателем сообщения компании
INSERT INTO message (interaction_id, message_text, sender, sending_time) 
VALUES (1, 'Добрый день! Текст сообщения от соискателя...', 'SEEKER', CURRENT_TIMESTAMP);


-- Просмотр соискателем всех диалогов 
SELECT MAX(sending_time), position, company_name
FROM message 
JOIN interaction USING (interaction_id) 
JOIN vacancy USING (vacancy_id)
JOIN company USING (company_id)
WHERE resume_id=1
GROUP BY interaction_id, position, company_name;


-- Просмотр переписки по определенному отклику/приглашению
SELECT sending_time, message_text 
FROM message 
JOIN interaction USING (interaction_id) 
WHERE interaction_id=1;


------------------------------------------------------------------------------------------------------------------------------------------------------------
-----СЦЕНАРИЙ СО СТОРОНЫ РАБОТОДАТЕЛЯ------

-- Регистрация рекрутера на сайте
INSERT INTO account (login, password, registration_time, account_type
) VALUES ('hrmail@gmail.com', crypt('hrpassword', gen_salt('bf')), CURRENT_TIMESTAMP, 'RECRUITER');


-- Авторизация рекрутера
UPDATE account SET last_login_time=CURRENT_TIMESTAMP WHERE login='hrmail@gmail.com' AND password = crypt('hrpassword', password);
-- Этим запросом можем проверять совпадение пароля (Авторизация проходит, если запрос возвращает TRUE)
SELECT (password = crypt('hrpassword', password)) AS auth_check FROM account WHERE login='hrmail@gmail.com';
-- Авторизация проходит, если запрос возвращает TRUE


-- Регистрация компании на сайте
INSERT INTO company (company_name, description, registration_time) 
VALUES ('Введенное имя компании', 'Введенное описание компании.', CURRENT_TIMESTAMP);


-- Прикрепление рекрутера к компании
INSERT INTO recruiter (account_id, company_id, begin_time) 
VALUES (2, 1, CURRENT_TIMESTAMP);


-- Отобразить все компании рекрутера
SELECT company_name FROM company JOIN recruiter USING (company_id)
WHERE account_id=2;


-- Отобразить всех рекрутеров компании
SELECT login, company_name
FROM company JOIN recruiter USING (company_id)
JOIN account USING (account_id)
WHERE company_id=1;


-- Создание вакансии
INSERT INTO vacancy (recruiter_id, company_id, position, description, city, salary, busyness, required_experience, publication_begin_time, status, active) 
VALUES (1, 1, 'Название должности', 'Описание должности', 'Город', INT4RANGE(60000,80000), 'FULL_TIME', 4, CURRENT_TIMESTAMP, 'ALL INTERNET', TRUE);
-- Подлинковываем скиллы
INSERT INTO skill_to_vacancy (skill_id, vacancy_id) VALUES (1,1), (3,1), (5,1);
-- Создаем и подлинковываем дополнительный скилл, созданный рекрутером
WITH created_skill AS (INSERT INTO skill (skill_name, confirmed) VALUES ('Мозговитость', FALSE) RETURNING skill_id)
INSERT INTO skill_to_vacancy (skill_id, vacancy_id) VALUES ((SELECT skill_id FROM created_skill), 1);


-- Удаление вакансии
UPDATE vacancy SET publication_end_time = CURRENT_TIMESTAMP, active = FALSE WHERE vacancy_id=1;


-- Поиск резюме рекрутером
-- * Параметры busyness, city, salary, publication_begin_time задаются рекрутером при поиске
-- * Если какой-то параметр пользователем не задан, то опускаем в запросе наложение на него условия
-- Четкий поиск - искать строго по заданным параметрам)
SELECT full_name, position, salary FROM resume
WHERE (busyness = 'FULL_TIME') 
AND city = 'Москва'
AND salary && int4range(80000, 100000) 
AND publication_begin_time > '2018-11-01'
AND (status = 'ALL INTERNET' OR status = 'REGISTERED')
AND active = TRUE;
-- Нечеткий поиск - искать по заданным параметрам, а также выдавать те результаты, у которых данный параметр не задан вовсе 
SELECT full_name, position, salary FROM resume 
WHERE (busyness = 'FULL_TIME' OR busyness IS NULL) 
AND city = 'Москва'
AND (salary && int4range(80000, 100000) OR salary is NULL)
AND publication_begin_time > '2018-11-01'
AND (status = 'ALL INTERNET' OR status = 'REGISTERED')
AND active = TRUE;


-- Просмотр выбранного рекрутером резюме 
SELECT full_name, position, city, salary, busyness, publication_begin_time
FROM resume
WHERE resume_id = 1;
-- Опыт работы отдельно дергаем
SELECT experience.position, company_name, begin_time, end_time
FROM experience JOIN resume USING(resume_id)
WHERE resume_id = 1;
-- Скиллы тоже
SELECT skill_name 
FROM skill_to_resume JOIN skill USING(skill_id)
WHERE resume_id = 1;


-- Отправка рекрутером приглашения автору резюме
INSERT INTO interaction (resume_id, vacancy_id, publication_time, interaction_type, status) 
VALUES (1, 1, CURRENT_TIMESTAMP, 'INVITE', 'NOTWHATCHED');


-- Просмотр всех откликов по выбранной вакансии
SELECT account_id, full_name, position, publication_time 
FROM interaction JOIN resume v USING(resume_id)
WHERE vacancy_id=1 AND interaction_type='REPLY';


-- Просмотр отклика работодателем
UPDATE interaction SET status='WHATCHED' WHERE interaction_id=2;


-- Принять отклик
UPDATE interaction SET status='INVITED' WHERE interaction_id=2;


-- Отклонить отклик
UPDATE interaction SET status='REJECTED' WHERE interaction_id=2;


-- Отправка рекрутером сообщения соискателю
INSERT INTO message (interaction_id, message_text, sender, sending_time) 
VALUES (2, 'Добрый день! Текст сообщения от работадателя...', 'RECRUITER', CURRENT_TIMESTAMP);


-- Просмотр рекрутером всех диалогов по выбранной вакансии
SELECT MAX(sending_time), position, full_name
FROM message 
JOIN interaction USING (interaction_id) 
JOIN resume USING (resume_id)
WHERE vacancy_id=1
GROUP BY interaction_id, position, full_name;


-- Просмотр переписки по определенному отклику/приглашению
-- Запрос аналогичен тому, что у соискателя
SELECT sending_time, message_text 
FROM message 
JOIN interaction USING (interaction_id) 
WHERE interaction_id=2;


------------------------------------------------------------------------------------------------------------------------------------------------------------
-----ОБЩЕЕ------

-- Смена пароля у аккаунта
UPDATE account SET password = crypt('new_userpassword', password) WHERE login = 'usermail@gmail.com' AND password = crypt('userpassword', password);

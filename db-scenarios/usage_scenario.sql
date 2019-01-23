-----СЦЕНАРИЙ СО СТОРОНЫ СОИСКАТЕЛЯ------

-- Регистрация соискателя на сайте
INSERT INTO account (login, password, registration_time, account_type
) VALUES ('usermail@gmail.com', crypt('userpassword', gen_salt('bf')), CURRENT_TIMESTAMP, 'APPLICANT');


-- Авторизация соискателя
UPDATE account SET last_login_time=CURRENT_TIMESTAMP WHERE login='usermail@gmail.com' AND password = crypt('userpassword', password);

-- Этим запросом можем проверять совпадение пароля (Авторизация проходит, если запрос возвращает TRUE)
SELECT (password = crypt('userpassword', password)) AS auth_check FROM account WHERE login='usermail@gmail.com';


-- Создание резюме
INSERT INTO resume (account_id, full_name, position, date_of_birth, city, salary, busyness, publication_begin_time, visibility_status, active) 
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
UPDATE resume SET publication_end_time = CURRENT_TIMESTAMP, active = FALSE WHERE resume_id=1; 


-- 5. Поиск вакансий соискателем
-- * Параметры busyness, city, salary, required_experience, company_name задаются соискателем при поиске
-- * Если какой-то параметр пользователем не задан, то опускаем в запросе наложение на него условия
-- Четкий поиск - искать строго по заданным параметрам)
SELECT company_name, position, salary FROM vacancy JOIN company USING (company_id) 
WHERE (busyness = 'FULL_TIME') 
AND city = 'Москва'
AND salary && int4range(80000, 100000)
AND (required_experience = '0-1' OR required_experience = '1-3')
AND (visibility_status = 'ALL INTERNET' OR visibility_status = 'REGISTERED')
AND active = TRUE
AND company_name = 'Яндекс'
ORDER BY publication_begin_time DESC;
-- Нечеткий поиск - искать по заданным параметрам, а также выдавать те результаты, у которых данный параметр не задан вовсе 
-- (Например, не указана ЗП. Это ведь не означает, что она непременно не удовлетворяет нашей))
SELECT company_name, position, salary FROM vacancy JOIN company USING (company_id) 
WHERE (busyness = 'FULL_TIME' OR busyness IS NULL) 
AND city = 'Москва'
AND (salary && int4range(80000, 100000) OR salary is NULL)
AND (required_experience = '0-1' OR required_experience = '1-3')
AND (visibility_status = 'ALL INTERNET' OR visibility_status = 'REGISTERED')
AND active = TRUE
AND company_name = 'Яндекс'
ORDER BY publication_begin_time DESC;


-- Просмотр выбранной соискателем вакансии 
SELECT company_name, position, vacancy.description, salary, required_experience, publication_begin_time, active
FROM vacancy JOIN company USING (company_id) 
WHERE vacancy_id = 1;
-- Скиллы отдельно дергаем
SELECT skill_name 
FROM skill_to_vacancy JOIN skill USING(skill_id)
WHERE vacancy_id = 1;


-- Просмотр информации о компании
SELECT company_name, description FROM company WHERE company_id=1;


-- Просмотр всех вакансий компании
SELECT company_id, position, description, city, salary, busyness, required_experience, publication_begin_time
FROM vacancy
WHERE company_id=1 AND active = TRUE;


-- Отправка соискателем отклика на вакансию
INSERT INTO interaction (resume_id, vacancy_id, publication_time, interaction_type, status) 
VALUES (1, 1, CURRENT_TIMESTAMP, 'REPLY', 'NOTWHATCHED');


-- Просмотр всех резюме соискателя + количество непрочитанных приглашений
SELECT full_name, position, city, salary, publication_begin_time, 
(SELECT COUNT(*) FROM interaction i WHERE status='NOTWHATCHED' AND i.resume_id=r.resume_id
	GROUP BY interaction_id) AS not_watched_count
FROM resume r
WHERE account_id=1 AND active = TRUE
ORDER BY publication_begin_time DESC;


-- Просмотр всех приглашений по выбранному резюме
SELECT position, (SELECT company_name FROM company c WHERE c.company_id=v.company_id), publication_time, status
FROM interaction JOIN vacancy v USING(vacancy_id)
WHERE resume_id=1 AND interaction_type='INVITE' AND active = TRUE
ORDER BY publication_time;


-- Показать только непросмотренные приглашения (аналогично можно посмотреть просмотренные, отклоненные или принятые)
SELECT position, (SELECT company_name FROM company c WHERE c.company_id=v.company_id), publication_time
FROM interaction JOIN vacancy v USING(vacancy_id)
WHERE resume_id=1 AND interaction_type='INVITE' AND status='NOTWHATCHED' AND active = TRUE
ORDER BY publication_time;


-- Просмотр приглашения соискателем
UPDATE interaction SET status='WHATCHED' WHERE interaction_id=1;


-- Отправка соискателем сообщения компании
INSERT INTO message (interaction_id, message_text, account_id, sending_time, status) 
VALUES (1, 'Добрый день! Текст сообщения от соискателя...', 1, CURRENT_TIMESTAMP, 'NOTWHATCHED');


-- Просмотр соискателем всех диалогов 
SELECT MAX(sending_time) AS sending_time, position, company_name, active,
(SELECT COUNT(*) FROM message m2 WHERE status='NOTWHATCHED' AND m2.interaction_id=m1.interaction_id
	GROUP BY interaction_id) AS not_watched_count
FROM message m1
JOIN interaction USING (interaction_id) 
JOIN vacancy USING (vacancy_id)
JOIN company USING (company_id)
WHERE resume_id=1
GROUP BY interaction_id, position, company_name, active
ORDER BY sending_time;


------------------------------------------------------------------------------------------------------------------------------------------------------------
-----СЦЕНАРИЙ СО СТОРОНЫ РАБОТОДАТЕЛЯ------

-- Регистрация рекрутера на сайте
INSERT INTO account (login, password, registration_time, account_type
) VALUES ('hrmail@gmail.com', crypt('hrpassword', gen_salt('bf')), CURRENT_TIMESTAMP, 'RECRUITER');


-- Авторизация рекрутера
UPDATE account SET last_login_time=CURRENT_TIMESTAMP WHERE login='hrmail@gmail.com' AND password = crypt('hrpassword', password);

-- Этим запросом можем проверять совпадение пароля (Авторизация проходит, если запрос возвращает TRUE)
SELECT (password = crypt('hrpassword', password)) AS auth_check FROM account WHERE login='hrmail@gmail.com';


-- Регистрация компании на сайте
INSERT INTO company (company_name, description, registration_time) 
VALUES ('Введенное имя компании', 'Введенное описание компании.', CURRENT_TIMESTAMP);


-- Прикрепление рекрутера к компании
INSERT INTO recruiter (account_id, company_id, active) 
VALUES (2, 1, TRUE);

-- Открепление рекрутера от компании
UPDATE recruiter SET active = FALSE
WHERE (account_id=2 AND company_id=1;


-- Отобразить все компании рекрутера
SELECT company_name FROM company JOIN recruiter USING (company_id)
WHERE account_id=2;


-- Отобразить всех рекрутеров компании
SELECT login, company_name
FROM company JOIN recruiter USING (company_id)
JOIN account USING (account_id)
WHERE company_id = 1 AND active = TRUE;


-- Создание вакансии
INSERT INTO vacancy (recruiter_id, company_id, position, description, city, salary, busyness, required_experience, publication_begin_time, visibility_status, active) 
VALUES (1, 1, 'Название должности', 'Описание должности', 'Город', INT4RANGE(60000,80000), 'FULL_TIME', '0-1', CURRENT_TIMESTAMP, 'ALL INTERNET', TRUE);
-- Подлинковываем скиллы
INSERT INTO skill_to_vacancy (skill_id, vacancy_id) VALUES (1,1), (3,1), (5,1);
-- Создаем и подлинковываем дополнительный скилл, созданный рекрутером
WITH created_skill AS (INSERT INTO skill (skill_name, confirmed) VALUES ('Мозговитость', FALSE) RETURNING skill_id)
INSERT INTO skill_to_vacancy (skill_id, vacancy_id) VALUES ((SELECT skill_id FROM created_skill), 1);


-- Удаление вакансии
UPDATE vacancy SET publication_end_time = CURRENT_TIMESTAMP, active = FALSE WHERE vacancy_id = 1;


-- Поиск резюме рекрутером
-- * Параметры busyness, city, salary задаются рекрутером при поиске
-- * Если какой-то параметр пользователем не задан, то опускаем в запросе наложение на него условия
-- Четкий поиск - искать строго по заданным параметрам)
SELECT full_name, position, salary FROM resume
WHERE (busyness = 'FULL_TIME') 
AND city = 'Москва'
AND salary && int4range(80000, 100000) 
AND (visibility_status = 'ALL INTERNET' OR visibility_status = 'REGISTERED')
AND active = TRUE
ORDER BY publication_begin_time DESC;
-- Нечеткий поиск - искать по заданным параметрам, а также выдавать те результаты, у которых данный параметр не задан вовсе 
SELECT full_name, position, salary FROM resume 
WHERE (busyness = 'FULL_TIME' OR busyness IS NULL) 
AND city = 'Москва'
AND (salary && int4range(80000, 100000) OR salary is NULL)
AND (visibility_status = 'ALL INTERNET' OR visibility_status = 'REGISTERED')
AND active = TRUE
ORDER BY publication_begin_time DESC;


-- Просмотр выбранного рекрутером резюме 
SELECT full_name, position, city, salary, busyness, publication_begin_time, active
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


-- Просмотр всех вакансий рекрутера + количество непрочитанных откликов
SELECT position, city, salary, required_experience, publication_begin_time, 
(SELECT company_name FROM company c WHERE c.company_id=v.company_id) AS company_name,
(SELECT COUNT(*) FROM interaction i WHERE status='NOTWHATCHED' AND i.vacancy_id=v.vacancy_id
	GROUP BY interaction_id) AS not_watched_count
FROM vacancy v
WHERE recruiter_id=1 AND active = TRUE
ORDER BY publication_begin_time DESC;


-- Просмотр всех откликов по выбранной вакансии
SELECT account_id, full_name, position, publication_time, status
FROM interaction JOIN resume USING(resume_id)
WHERE vacancy_id=1 AND interaction_type='REPLY';


-- Показать только непросмотренные отклики (аналогично можно посмотреть просмотренные, отклоненные или принятые)
SELECT account_id, full_name, position, publication_time
FROM interaction JOIN resume USING(resume_id)
WHERE vacancy_id=1 AND interaction_type='REPLY' AND status='NOTWHATCHED' AND active = TRUE;


-- Просмотр отклика работодателем
UPDATE interaction SET status='WHATCHED' WHERE interaction_id=2;


-- Принять отклик
UPDATE interaction SET status='INVITED' WHERE interaction_id=2;


-- Отклонить отклик
UPDATE interaction SET status='REJECTED' WHERE interaction_id=2;


-- Отправка рекрутером сообщения соискателю
INSERT INTO message (interaction_id, message_text, account_id, sending_time, status) 
VALUES (2, 'Добрый день! Текст сообщения от работадателя...', 2, CURRENT_TIMESTAMP, 'NOTWHATCHED');


-- Просмотр рекрутером всех диалогов по выбранной вакансии
SELECT MAX(sending_time) AS sending_time, position, full_name, active,
(SELECT COUNT(*) FROM message m2 WHERE status='NOTWHATCHED' AND m2.interaction_id=m1.interaction_id
	GROUP BY interaction_id) AS not_watched_count
FROM message m1
JOIN interaction USING (interaction_id) 
JOIN resume USING (resume_id)
WHERE vacancy_id=1
GROUP BY interaction_id, position, full_name, active
ORDER BY sending_time;


------------------------------------------------------------------------------------------------------------------------------------------------------------
-----ОБЩЕЕ------

-- Смена пароля у аккаунта
UPDATE account SET password = crypt('new_userpassword', password) WHERE login = 'usermail@gmail.com' AND password = crypt('userpassword', password);


-- Просмотр нового сообщения
UPDATE message SET status='WHATCHED' WHERE message_id=1;


-- Просмотр переписки по определенному отклику/приглашению
SELECT sending_time, message_text, (SELECT login FROM account c WHERE c.account_id=m.account_id)
FROM message m
JOIN interaction USING (interaction_id) 
WHERE interaction_id=2;
-- Cтавим всем новым сообшениям в этой переписке статус "Просмотрено"
WITH not_watched_messages AS (SELECT message_id
FROM message JOIN interaction USING (interaction_id) 
WHERE interaction_id=2 AND message.status='NOTWHATCHED')
UPDATE message SET status='WHATCHED' WHERE message_id IN (SELECT message_id FROM not_watched_messages);


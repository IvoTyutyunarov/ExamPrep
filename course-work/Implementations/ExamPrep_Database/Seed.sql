-- ====================
-- Users
-- ====================
INSERT INTO dbo.[User] (email, password_hash, first_name, last_name, role, institution, country)
VALUES
('student1@example.com', 'hash1', 'Ivan', 'Ivanov', 'Student', 'Plovdiv University', 'BG'),
('student2@example.com', 'hash2', 'Petar', 'Petrov', 'Student', 'Sofia University', 'BG'),
('student3@example.com', 'hash3', 'Maria', 'Georgieva', 'Student', 'Varna University', 'BG'),
('student4@example.com', 'hash4', 'Anna', 'Dimitrova', 'Student', 'Plovdiv University', 'BG'),
('student5@example.com', 'hash5', 'Georgi', 'Stoyanov', 'Student', 'Plovdiv University', 'BG'),
('student6@example.com', 'hash6', 'Elena', 'Petrova', 'Student', 'Sofia University', 'BG'),
('student7@example.com', 'hash7', 'Stefan', 'Kostov', 'Student', 'Varna University', 'BG'),
('student8@example.com', 'hash8', 'Nikola', 'Nikolov', 'Student', 'Plovdiv University', 'BG'),
('student9@example.com', 'hash9', 'Kristina', 'Ivanova', 'Student', 'Sofia University', 'BG'),
('student10@example.com', 'hash10', 'Miroslav', 'Petkov', 'Student', 'Varna University', 'BG'),
('instructor1@example.com', 'hash11', 'Petar', 'Petrov', 'Instructor', 'Plovdiv University', 'BG'),
('instructor2@example.com', 'hash12', 'Maria', 'Dimitrova', 'Instructor', 'Sofia University', 'BG'),
('instructor3@example.com', 'hash13', 'Georgi', 'Stoyanov', 'Instructor', 'Varna University', 'BG'),
('admin@example.com', 'hash14', 'Admin', 'User', 'Admin', NULL, 'BG');

-- ====================
-- Courses
-- ====================
INSERT INTO dbo.Course (title, description, subject, level, created_by)
VALUES
('Mathematics: Analysis I','Подготовка по Математически анализ','Mathematics','Intermediate', 11),
('Physics: Mechanics','Подготовка за изпити по механика','Physics','Beginner', 12),
('Computer Science: Programming','Подготовка по програмиране','Computer Science','Beginner', 13);

-- ====================
-- Tests
-- ====================
INSERT INTO dbo.Test (course_id, title, description, time_limit_minutes, pass_percentage, max_attempts, is_published)
VALUES
(1, 'Analysis I - Test 1', 'Тест за практика по Analysis I', 60, 70, 5, 1),
(1, 'Analysis I - Test 2', 'Тест за практика по Analysis I', 45, 70, 5, 1),
(2, 'Mechanics - Test 1', 'Основен тест по механика', 50, 60, 3, 1),
(2, 'Mechanics - Test 2', 'Разширен тест по механика', 60, 65, 3, 1),
(3, 'Programming - Test 1', 'Тест за основи на програмирането', 45, 70, 5, 1),
(3, 'Programming - Test 2', 'Тест за цикли и функции', 60, 75, 5, 1);

-- ====================
-- Questions
-- ====================
INSERT INTO dbo.Question (author_id, text, type, difficulty, points)
VALUES
(11, 'Какъв е границата на функцията f(x)=x^2 при x->0?', 'MCQ', 2, 2),
(11, 'Кое е правилното интегрално преобразуване на sin(x)?', 'MCQ', 3, 3),
(12, 'Каква е формулата за ускорение при равномерно движение?', 'MCQ', 1, 1.5),
(12, 'Коя е третата Нютонова аксиома?', 'MCQ', 2, 2),
(13, 'Какво връща функцията print() в Python?', 'MCQ', 1, 1),
(13, 'Кой оператор се използва за цикъл for в C#?', 'MCQ', 1, 1),
(11, 'Решете диференциалното уравнение y=2x', 'Open', 3, 4),
(12, 'Какъв е законът на запазване на енергията?', 'Open', 2, 3),
(13, 'Напишете функция, която връща квадратен корен', 'Open', 2, 3);

-- ====================
-- Options (за MCQ)
-- ====================
INSERT INTO dbo.[Option] (question_id, text, is_correct, order_index)
VALUES
(1, '0', 1, 1),
(1, '1', 0, 2),
(1, 'Няма граница',0,3),
(2, '-cos(x)+C',1,1),
(2, 'cos(x)+C',0,2),
(2, 'sin(x)+C',0,3),
(3, 'a = F/m',1,1),
(3, 'a = m/F',0,2),
(4, 'Третата Нютонова аксиома е F=ma',0,1),
(4, 'На всяко действие има равно по големина и противоположно по посока противодействие',1,2),
(5, 'Нищо',0,1),
(5, 'None',1,2),
(6, 'for',1,1),
(6, 'foreach',0,2);

-- ====================
-- TestQuestion (Test - Question)
-- ====================
INSERT INTO dbo.TestQuestion (test_id, question_id, question_order)
VALUES
(1,1,1),(1,2,2),(1,7,3),
(2,1,1),(2,2,2),(2,7,3),
(3,3,1),(3,4,2),(3,8,3),
(4,3,1),(4,4,2),(4,8,3),
(5,5,1),(5,6,2),(5,9,3),
(6,5,1),(6,6,2),(6,9,3);

-- ====================
-- Enrollment (User - Course)
-- ====================
INSERT INTO dbo.Enrollment (user_id, course_id)
VALUES
(1,1),(2,1),(3,1),(4,1),(5,1),
(1,2),(6,2),(7,2),(8,2),(9,2),
(2,3),(3,3),(10,3);

-- ====================
-- Attempts
-- ====================
INSERT INTO dbo.Attempt (test_id, user_id, started_at, finished_at, total_score, percent_score, passed, duration_seconds)
VALUES
(1,1,'2025-12-01 10:00','2025-12-01 10:50',4,66.7,0,3000),
(1,2,'2025-12-01 11:00','2025-12-01 11:45',5,83.3,1,2700),
(2,3,'2025-12-02 09:00','2025-12-02 09:40',5,71.4,1,2400),
(3,1,'2025-12-03 14:00','2025-12-03 14:35',3,100,1,2100),
(5,10,'2025-12-04 16:00','2025-12-04 16:40',4,80,1,2400),
(6,2,'2025-12-05 12:00','2025-12-05 12:50',5,90,1,3000);

-- ====================
-- Answers
-- ====================
INSERT INTO dbo.Answer (attempt_id, question_id, option_id, given_text, is_correct, time_taken_seconds)
VALUES
-- Attempt 1
(1,1,1,NULL,1,60),
(1,2,1,NULL,1,90),
(1,7,NULL,'y=x^2 + C',1,120),

-- Attempt 2
(2,1,2,NULL,0,50),
(2,2,1,NULL,1,70),
(2,7,NULL,'y=x^2',0,90),

-- Attempt 3
(3,3,1,NULL,1,80),
(3,4,2,NULL,1,100),
(3,8,NULL,'E = mc^2',1,120),

-- Attempt 4
(4,3,1,NULL,1,60),
(4,4,2,NULL,1,90),
(4,8,NULL,'Energy conserved',1,90),

-- Attempt 5
(5,5,2,NULL,1,50),
(5,6,1,NULL,1,70),
(5,9,NULL,'sqrt(x)',1,120),

-- Attempt 6
(6,5,2,NULL,1,60),
(6,6,1,NULL,1,80),
(6,9,NULL,'math.sqrt(x)',1,120);

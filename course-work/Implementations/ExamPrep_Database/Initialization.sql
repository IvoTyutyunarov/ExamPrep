Create database ExamPrep

Use ExamPrep


CREATE TABLE dbo.[User] (
    user_id        INT IDENTITY(1,1) PRIMARY KEY,
    email          NVARCHAR(255) NOT NULL UNIQUE,
    password_hash  NVARCHAR(512) NOT NULL,
    first_name     NVARCHAR(100),
    last_name      NVARCHAR(100),
    role           NVARCHAR(50) NOT NULL, -- 'Student','Instructor','Admin'
    registration_date DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    last_login     DATETIME2 NULL,
    institution    NVARCHAR(255) NULL,
    country        NVARCHAR(100) NULL,
    profile_picture_url NVARCHAR(1000) NULL,
    is_active      BIT NOT NULL DEFAULT 1
);

CREATE TABLE dbo.Course (
    course_id    INT IDENTITY(1,1) PRIMARY KEY,
    title        NVARCHAR(255) NOT NULL,
    description  NVARCHAR(MAX) NULL,
    subject      NVARCHAR(150),
    level        NVARCHAR(50),
    created_by   INT NOT NULL,
    created_at   DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at   DATETIME2 NULL,
    is_public    BIT NOT NULL DEFAULT 1,
    language     NVARCHAR(50) DEFAULT 'bg',
    thumbnail_url NVARCHAR(1000) NULL,
    CONSTRAINT FK_Course_User FOREIGN KEY (created_by) REFERENCES dbo.[User](user_id)
);

CREATE TABLE dbo.Test (
    test_id            INT IDENTITY(1,1) PRIMARY KEY,
    course_id          INT NULL,
    title              NVARCHAR(255) NOT NULL,
    description        NVARCHAR(MAX) NULL,
    time_limit_minutes INT NULL,
    pass_percentage    DECIMAL(5,2) DEFAULT 70.00,
    max_attempts       INT DEFAULT 5,
    shuffle_questions  BIT DEFAULT 1,
    created_at         DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    is_published       BIT DEFAULT 0,
    CONSTRAINT FK_Test_Course FOREIGN KEY (course_id) REFERENCES dbo.Course(course_id)
);

CREATE TABLE dbo.Question (
    question_id    INT IDENTITY(1,1) PRIMARY KEY,
    author_id      INT NOT NULL,
    text           NVARCHAR(MAX) NOT NULL,
    type           NVARCHAR(50) NOT NULL, -- 'MCQ','MultiSelect','TrueFalse','Open'
    difficulty     TINYINT DEFAULT 3, -- 1..5
    points         DECIMAL(6,2) DEFAULT 1.00,
    created_at     DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    is_active      BIT DEFAULT 1,
    CONSTRAINT FK_Question_User FOREIGN KEY (author_id) REFERENCES dbo.[User](user_id)
);

CREATE TABLE dbo.[Option] (
    option_id     INT IDENTITY(1,1) PRIMARY KEY,
    question_id   INT NOT NULL,
    text          NVARCHAR(MAX) NOT NULL,
    is_correct    BIT DEFAULT 0,
    order_index   INT DEFAULT 0,
    CONSTRAINT FK_Option_Question FOREIGN KEY (question_id) REFERENCES dbo.Question(question_id)
);

CREATE TABLE dbo.TestQuestion (
    test_id    INT NOT NULL,
    question_id INT NOT NULL,
    question_order INT NULL,
    points_override DECIMAL(6,2) NULL,
    PRIMARY KEY (test_id, question_id),
    CONSTRAINT FK_TQ_Test FOREIGN KEY (test_id) REFERENCES dbo.Test(test_id),
    CONSTRAINT FK_TQ_Question FOREIGN KEY (question_id) REFERENCES dbo.Question(question_id)
);

CREATE TABLE dbo.Attempt (
    attempt_id      INT IDENTITY(1,1) PRIMARY KEY,
    test_id         INT NOT NULL,
    user_id         INT NOT NULL,
    started_at      DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    finished_at     DATETIME2 NULL,
    total_score     DECIMAL(8,2) NULL,
    percent_score   DECIMAL(5,2) NULL,
    passed          BIT NULL,
    client_ip       NVARCHAR(50) NULL,
    duration_seconds INT NULL,
    is_flagged      BIT DEFAULT 0,
    CONSTRAINT FK_Attempt_Test FOREIGN KEY (test_id) REFERENCES dbo.Test(test_id),
    CONSTRAINT FK_Attempt_User FOREIGN KEY (user_id) REFERENCES dbo.[User](user_id)
);

CREATE TABLE dbo.Answer (
    answer_id      INT IDENTITY(1,1) PRIMARY KEY,
    attempt_id     INT NOT NULL,
    question_id    INT NOT NULL,
    option_id      INT NULL,
    given_text     NVARCHAR(MAX) NULL,
    is_correct     BIT DEFAULT 0,
    time_taken_seconds INT NULL,
    CONSTRAINT FK_Answer_Attempt FOREIGN KEY (attempt_id) REFERENCES dbo.Attempt(attempt_id),
    CONSTRAINT FK_Answer_Question FOREIGN KEY (question_id) REFERENCES dbo.Question(question_id),
    CONSTRAINT FK_Answer_Option FOREIGN KEY (option_id) REFERENCES dbo.[Option](option_id)
);

CREATE TABLE dbo.Enrollment (
    user_id   INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    role_in_course NVARCHAR(50) DEFAULT 'Student',
    PRIMARY KEY (user_id, course_id),
    CONSTRAINT FK_Enrollment_User FOREIGN KEY (user_id) REFERENCES dbo.[User](user_id),
    CONSTRAINT FK_Enrollment_Course FOREIGN KEY (course_id) REFERENCES dbo.Course(course_id)
);

-- Индекси за бързи заявки
CREATE INDEX IX_Attempt_User_Test ON dbo.Attempt(user_id, test_id);
CREATE INDEX IX_Answer_Attempt ON dbo.Answer(attempt_id);
CREATE INDEX IX_Question_Difficulty ON dbo.Question(difficulty);

-- Осигуряване уникален текст на опцията за всеки въпрос
ALTER TABLE dbo.[Option]
ADD option_hash AS HASHBYTES('SHA2_256', text) PERSISTED;

ALTER TABLE dbo.[Option]
ADD CONSTRAINT UQ_Option_question_text
UNIQUE (question_id, option_hash);
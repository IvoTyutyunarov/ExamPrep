CREATE PROCEDURE dbo.usp_RecordAttemptResult
    @attempt_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @started DATETIME2,
        @finished DATETIME2,
        @total_score DECIMAL(10,2),
        @total_possible DECIMAL(10,2),
        @percent DECIMAL(5,2),
        @test_id INT,
        @pass_percentage DECIMAL(5,2),
        @passed BIT;

    SELECT @started = started_at 
    FROM dbo.Attempt 
    WHERE attempt_id = @attempt_id;

    SET @finished = SYSUTCDATETIME();

    ;WITH AnswerPoints AS (
        SELECT 
            a.answer_id,
            a.question_id,
            COALESCE(tq.points_override, q.points) AS question_points,
            CASE WHEN a.is_correct = 1 
                THEN COALESCE(tq.points_override, q.points) 
                ELSE 0 
            END AS points_earned
        FROM dbo.Answer a
        JOIN dbo.Question q ON a.question_id = q.question_id
        LEFT JOIN dbo.TestQuestion tq ON tq.question_id = q.question_id
        WHERE a.attempt_id = @attempt_id
    )
    SELECT @total_score = ISNULL(SUM(points_earned),0)
    FROM AnswerPoints;

    SELECT @test_id = test_id 
    FROM dbo.Attempt 
    WHERE attempt_id = @attempt_id;

    SELECT @total_possible =
        ISNULL(SUM(COALESCE(tq.points_override, q.points)),0)
    FROM dbo.TestQuestion tq
    JOIN dbo.Question q ON tq.question_id = q.question_id
    WHERE tq.test_id = @test_id;

    IF @total_possible = 0 SET @total_possible = 1;

    SET @percent = ROUND((@total_score * 100.0) / @total_possible, 2);

    SELECT @pass_percentage = pass_percentage 
    FROM dbo.Test 
    WHERE test_id = @test_id;

    SET @passed = CASE WHEN @percent >= ISNULL(@pass_percentage,70.00)
                       THEN 1 ELSE 0 END;

    UPDATE dbo.Attempt
    SET finished_at = @finished,
        total_score = @total_score,
        percent_score = @percent,
        passed = @passed,
        duration_seconds = DATEDIFF(SECOND, @started, @finished)
    WHERE attempt_id = @attempt_id;
END;
GO



CREATE PROCEDURE dbo.usp_RegisterUser
    @email NVARCHAR(255),
    @password_hash NVARCHAR(512),
    @first_name NVARCHAR(100),
    @last_name NVARCHAR(100),
    @role NVARCHAR(50) = 'Student'
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.[User] WHERE email = @email)
    BEGIN
        RAISERROR('Email already exists.',16,1);
        RETURN;
    END

    INSERT INTO dbo.[User] (email, password_hash, first_name, last_name, role)
    VALUES (@email,@password_hash,@first_name,@last_name,@role);
END;
GO


CREATE PROCEDURE dbo.usp_EnrollUserInCourse
    @user_id INT,
    @course_id INT,
    @role_in_course NVARCHAR(50) = 'Student'
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(SELECT 1 FROM dbo.Enrollment WHERE user_id=@user_id AND course_id=@course_id)
    BEGIN
        RAISERROR('User already enrolled in course.',16,1);
        RETURN;
    END

    INSERT INTO dbo.Enrollment (user_id, course_id, role_in_course)
    VALUES (@user_id,@course_id,@role_in_course);
END;
GO



CREATE PROCEDURE dbo.usp_GetTopProblemQuestions
    @top INT = 10
AS
BEGIN
    SELECT TOP (@top) q.question_id, q.text, dbo.fn_QuestionCorrectRate(q.question_id) AS correct_rate
    FROM dbo.Question q
    ORDER BY correct_rate ASC;
END;
GO


CREATE PROCEDURE dbo.usp_GetUserProgress
    @user_id INT
AS
BEGIN
    SELECT c.course_id, c.title AS course_title,
           COUNT(DISTINCT t.test_id) AS total_tests,
           SUM(CASE WHEN a.passed=1 THEN 1 ELSE 0 END) AS tests_passed,
           dbo.fn_UserAverageScore(@user_id) AS avg_score
    FROM dbo.Enrollment e
    JOIN dbo.Course c ON c.course_id = e.course_id
    LEFT JOIN dbo.Test t ON t.course_id = c.course_id
    LEFT JOIN dbo.Attempt a ON a.user_id = e.user_id AND a.test_id = t.test_id
    WHERE e.user_id = @user_id
    GROUP BY c.course_id, c.title;
END;
GO

CREATE FUNCTION dbo.fn_UserAverageScore(@user_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN (
        SELECT ISNULL(AVG(percent_score),0)
        FROM dbo.Attempt
        WHERE user_id = @user_id
    );
END;
GO


CREATE FUNCTION dbo.fn_TestPassRate(@test_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total INT = (SELECT COUNT(*) FROM dbo.Attempt WHERE test_id = @test_id);
    DECLARE @passed INT = (SELECT COUNT(*) FROM dbo.Attempt WHERE test_id = @test_id AND passed = 1);

    IF @total = 0 RETURN 0;

    RETURN CAST(@passed * 100.0 / @total AS DECIMAL(5,2));
END;
GO


CREATE FUNCTION dbo.fn_QuestionCorrectRate(@question_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total INT = (SELECT COUNT(*) FROM dbo.Answer WHERE question_id = @question_id);
    DECLARE @correct INT = (SELECT COUNT(*) FROM dbo.Answer WHERE question_id = @question_id AND is_correct = 1);

    IF @total = 0 RETURN 0;

    RETURN CAST(@correct * 100.0 / @total AS DECIMAL(5,2));
END;
GO


CREATE FUNCTION dbo.fn_CourseCompletionRate(@course_id INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @total_users INT = (SELECT COUNT(*) FROM dbo.Enrollment WHERE course_id = @course_id);
    DECLARE @completed INT = (
        SELECT COUNT(DISTINCT e.user_id)
        FROM dbo.Enrollment e
        JOIN dbo.Test t ON t.course_id = e.course_id
        JOIN dbo.Attempt a ON a.user_id = e.user_id AND a.test_id = t.test_id AND a.passed = 1
        GROUP BY e.user_id
        HAVING COUNT(DISTINCT t.test_id) = (SELECT COUNT(*) FROM dbo.Test WHERE course_id = @course_id)
    );

    IF @total_users = 0 RETURN 0;

    RETURN CAST(@completed * 100.0 / @total_users AS DECIMAL(5,2));
END;
GO

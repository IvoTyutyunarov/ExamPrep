CREATE TRIGGER trg_AttemptAfterInsert
ON dbo.Attempt
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE a
    SET is_flagged = 1
    FROM dbo.Attempt a
    JOIN inserted i ON a.attempt_id = i.attempt_id
    WHERE i.duration_seconds IS NOT NULL AND i.duration_seconds < 10 AND i.percent_score = 100;
END;
GO

CREATE TRIGGER trg_UpdateCourseOnTestInsert
ON dbo.Test
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE c
    SET updated_at = SYSUTCDATETIME()
    FROM dbo.Course c
    JOIN inserted i ON c.course_id = i.course_id;
END;
GO

CREATE TRIGGER trg_LimitEnrollmentPerCourse
ON dbo.Enrollment
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(
        SELECT 1
        FROM dbo.Enrollment e
        JOIN inserted i ON e.course_id = i.course_id
        GROUP BY e.course_id
        HAVING COUNT(*) > 1000
    )
    BEGIN
        RAISERROR('Course cannot have more than 1000 enrolled users.',16,1);
        ROLLBACK TRANSACTION;
    END
END;
GO

CREATE TRIGGER trg_AnswerInsertValidate
ON dbo.Answer
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS(
        SELECT 1 FROM dbo.Answer a
        JOIN inserted i ON a.attempt_id = i.attempt_id AND a.question_id = i.question_id
    )
    BEGIN
        RAISERROR('Answer for this question already exists in this attempt.',16,1);
        RETURN;
    END

    INSERT INTO dbo.Answer(answer_id, attempt_id, question_id, option_id, given_text, is_correct, time_taken_seconds)
    SELECT answer_id, attempt_id, question_id, option_id, given_text, is_correct, time_taken_seconds
    FROM inserted;
END;
GO

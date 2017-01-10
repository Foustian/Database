CREATE PROCEDURE [dbo].[usp_v4_JobType_SelectAll]
AS
BEGIN

	SET NOCOUNT ON;

	SELECT 
			Name, [Description], ID 
	FROM 
			IQJob_Type 
	WHERE 
			IsActive = 1 
	ORDER BY Name
END
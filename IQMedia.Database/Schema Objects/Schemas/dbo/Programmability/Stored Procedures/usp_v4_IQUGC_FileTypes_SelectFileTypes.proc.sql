CREATE PROCEDURE [dbo].[usp_v4_IQUGC_FileTypes_SelectFileTypes]
AS
BEGIN
	SELECT	DISTINCT
			FileTypeExt,
			FileType
	FROM 
			IQUGC_FileTypes
	WHERE
			IsActive = 1
END
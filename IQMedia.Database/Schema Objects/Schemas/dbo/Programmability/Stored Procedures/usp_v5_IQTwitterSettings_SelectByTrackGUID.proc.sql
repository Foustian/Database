CREATE PROCEDURE [dbo].[usp_v5_IQTwitterSettings_SelectByTrackGUID]
	@UserTrackGUID UNIQUEIDENTIFIER
AS
BEGIN
	SELECT	TwitterRule
	FROM	IQMediaGroup.dbo.IQ_Twitter_Settings
	WHERE	UserTrackGUID = @UserTrackGUID
END

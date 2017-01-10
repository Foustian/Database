CREATE PROCEDURE [dbo].[usp_v5_IQTVEyesSettings_SelectByID]
	@TVESettingsKey BIGINT
AS
BEGIN
	SELECT	TVESearchTerm
	FROM	IQMediaGroup.dbo.IQ_TVEyes_Settings
	WHERE	TVESettingsKey = @TVESettingsKey
END
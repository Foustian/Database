CREATE PROCEDURE [dbo].[usp_v4_Client_SelectDropDownByClient]
	@ClientID BIGINT
AS
BEGIN
	DECLARE @MCMediaAvailableTemplates XML
	SELECT	TOP 1 @MCMediaAvailableTemplates = CAST(Value AS XML)
	FROM	IQClient_CustomSettings
	LEFT	JOIN Client
			ON ClientKey = @ClientID 
			AND Client.ClientGUID = IQClient_CustomSettings._ClientGuid
	WHERE	Field = 'MCMediaAvailableTemplates'	
			AND (ClientKey IS NOT NULL OR IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	ORDER	BY IQClient_CustomSettings._ClientGuid DESC
	
	IF @MCMediaAvailableTemplates.exist('/Templates/Published[@IsAllowAll="true"]') = 1
	  BEGIN
		SELECT	IQ_ReportType.ID,
				Name
		FROM	IQ_ReportType
		WHERE	IsActive = 1 and MasterReportType = 'MCMediaTemplate'
		ORDER	BY IsDefault DESC, Name
	  END
	ELSE
	  BEGIN
		SELECT	IQ_ReportType.ID,
				Name
		FROM	IQ_ReportType
		INNER	JOIN @MCMediaAvailableTemplates.nodes('/Templates/Published/Template/ID') AS Template(ID)
				ON IQ_ReportType.ID = Template.ID.query('.').value('.','int')
		WHERE	IsActive = 1
		ORDER	BY IsDefault DESC, Name
	  END
	
	IF @MCMediaAvailableTemplates.exist('/Templates/Email[@IsAllowAll="true"]') = 1
	  BEGIN
		SELECT	IQ_ReportType.ID,
				Name
		FROM	IQ_ReportType
		WHERE	IsActive = 1 and MasterReportType = 'EmailTemplate'
		ORDER	BY IsDefault DESC, Name
	  END
	ELSE
	  BEGIN
		SELECT	IQ_ReportType.ID,
				Name
		FROM	IQ_ReportType
		INNER	JOIN @MCMediaAvailableTemplates.nodes('/Templates/Email/Template/ID') AS Template(ID)
				ON IQ_ReportType.ID = Template.ID.query('.').value('.','int')
		WHERE	IsActive = 1
		ORDER	BY IsDefault DESC, Name
	  END			
	
END
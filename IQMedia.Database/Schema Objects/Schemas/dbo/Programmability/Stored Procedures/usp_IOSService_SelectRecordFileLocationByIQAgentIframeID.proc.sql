CREATE PROCEDURE [dbo].[usp_IOSService_SelectRecordFileLocationByIQAgentIframeID]
	@IQAgentIframeID UNIQUEIDENTIFIER
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DataModelType		VARCHAR(10)
	DECLARE @IQAgentResultID	BIGINT
	
	SELECT	@DataModelType = DataModelType,
			@IQAgentResultID = IQAgentResultID
	FROM	IQMediaGroup.dbo.IQAgentIFrame
	WHERE	Guid = @IQAgentIframeID

	IF @DataModelType = 'TV'
	  BEGIN
		IF EXISTS (SELECT 1 FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
		  BEGIN
			SELECT
				IQCore_RootPath.AppName,
				IQCore_RootPath.StreamSuffixPath ,
				REPLACE(IQCore_RecordFile.Location,'\','/') AS 'IOSFileLocation'
			FROM
				IQAgent_TVResults WITH(NOLOCK)
					INNER JOIN IQCore_RecordFile 
						ON RL_VideoGUID = IQCore_RecordFile.[Guid]
					INNER JOIN IQCore_RootPath
							ON IQCore_RecordFile._RootPathID = IQCore_RootPath.ID	
			WHERE
				IQAgent_TVResults.ID = @IQAgentResultID
		  END
		ELSE
		  BEGIN
			SELECT
				IQCore_RootPath.AppName,
				IQCore_RootPath.StreamSuffixPath ,
				REPLACE(IQCore_RecordFile.Location,'\','/') AS 'IOSFileLocation'
			FROM
				IQAgent_TVResults_Archive WITH(NOLOCK)
					INNER JOIN IQCore_RecordFile 
						ON RL_VideoGUID = IQCore_RecordFile.[Guid]
					INNER JOIN IQCore_RootPath
							ON IQCore_RecordFile._RootPathID = IQCore_RootPath.ID	
			WHERE
				IQAgent_TVResults_Archive.ID = @IQAgentResultID
		  END
	  END
	ELSE IF @DataModelType = 'IQR'
	  BEGIN
		IF EXISTS (SELECT 1 FROM IQMediaGroup.dbo.IQAgent_TVResults WITH (NOLOCK) WHERE ID = @IQAgentResultID)
		  BEGIN
			SELECT
				IQCore_RootPath.AppName,
				IQCore_RootPath.StreamSuffixPath ,
				REPLACE(IQCore_RecordFile.Location,'\','/') AS 'IOSFileLocation'
			FROM
				IQAgent_RadioResults WITH(NOLOCK)
					INNER JOIN IQCore_RecordFile 
						ON IQAgent_RadioResults.Guid = IQCore_RecordFile.[Guid]
					INNER JOIN IQCore_RootPath
							ON IQCore_RecordFile._RootPathID = IQCore_RootPath.ID	
			WHERE
				IQAgent_RadioResults.ID = @IQAgentResultID
		  END
		ELSE
		  BEGIN
			SELECT
				IQCore_RootPath.AppName,
				IQCore_RootPath.StreamSuffixPath ,
				REPLACE(IQCore_RecordFile.Location,'\','/') AS 'IOSFileLocation'
			FROM
				IQAgent_RadioResults_Archive WITH(NOLOCK)
					INNER JOIN IQCore_RecordFile 
						ON IQAgent_RadioResults_Archive.Guid = IQCore_RecordFile.[Guid]
					INNER JOIN IQCore_RootPath
							ON IQCore_RecordFile._RootPathID = IQCore_RootPath.ID	
			WHERE
				IQAgent_RadioResults_Archive.ID = @IQAgentResultID
		  END
	  END
	ELSE
	  BEGIN
		SELECT '' AS AppName,
				'' AS StreamSuffixPath,
				'' AS IOSFileLocation
		WHERE 1 = 2

		DECLARE @IQMediaGroupExceptionKey BIGINT,
				@ExceptionMessage VARCHAR(500) = 'Encountered unsupported DataModelType: ' + ISNULL(@DataModelType, 'NULL'),
				@CreatedBy VARCHAR(50) = 'usp_IOSService_SelectRecordFileLocationByIQAgentIframeID',
				@CreatedDate DATETIME = GETDATE()
		
		EXEC usp_IQMediaGroupExceptions_Insert '',@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey OUTPUT
	  END
END

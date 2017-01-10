CREATE PROCEDURE [dbo].[usp_v4_ArchiveTVEyes_SelectLocationByArchiveTVEyesKey]
	@ID bigint
AS
BEGIN
	SELECT 
			 ISNULL(IQCore_RootPath.StreamSuffixPath + REPLACE(Location,'\','/') + AudioFile,'')  as AudioFileLocation,
			 ISNULL(IQCore_RootPath.StoragePath + Location + TranscriptFile,'')  as TranscriptFileLocation
	FROM	
			ArchiveTVEyes	INNER JOIN IQCore_RootPath ON ArchiveTVEyes._RootPathID = IQCore_RootPath.ID
	WHERE
			ArchiveTVEyesKey = @ID
END
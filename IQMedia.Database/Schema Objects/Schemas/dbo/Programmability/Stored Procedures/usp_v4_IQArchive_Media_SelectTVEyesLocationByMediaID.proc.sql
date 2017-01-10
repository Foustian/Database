CREATE PROCEDURE [dbo].[usp_v4_IQArchive_Media_SelectTVEyesLocationByMediaID]
	@MediaID bigint
AS
BEGIN
	SELECT 
		ISNULL(IQCore_RootPath.StreamSuffixPath + REPLACE(Location,'\','/') + AudioFile,'')  as AudioFileLocation,
		ISNULL(IQCore_RootPath.StoragePath + Location + TranscriptFile,'')  as TranscriptFileLocation
FROM	
		IQArchive_Media 
			inner join ArchiveTVEyes	
				ON IQArchive_Media.MediaType = 'TM'
				AND IQArchive_Media._ArchiveMediaID = ArchiveTVEyes.ArchiveTVEyesKey
			INNER JOIN IQCore_RootPath 
				ON ArchiveTVEyes._RootPathID = IQCore_RootPath.ID
WHERE
		IQArchive_Media.ID = @MediaID
END
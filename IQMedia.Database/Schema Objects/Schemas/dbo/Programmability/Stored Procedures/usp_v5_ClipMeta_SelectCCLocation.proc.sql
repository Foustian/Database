CREATE PROCEDURE [dbo].[usp_v5_ClipMeta_SelectCCLocation]
(
	@ClipXml	XML,
	@ClientGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	DECLARE @TblClip	TABLE (ClipGUID	UNIQUEIDENTIFIER)
	DECLARE @TblClipLocation	TABLE (ClipGUID UNIQUEIDENTIFIER, RPID INT, FileLocation VARCHAR(2048))

	INSERT INTO @TblClip
	(
		ClipGUID
	)
	SELECT
		DISTINCT
		tbl.c.value('@ClipGUID', 'UNIQUEIDENTIFIER')
	FROM
			@ClipXml.nodes('list/item') as tbl(c)
				INNER JOIN ArchiveClip
					ON	tbl.c.value('@ClipGUID', 'UNIQUEIDENTIFIER') = ArchiveClip.ClipID
					AND	ArchiveClip.ClientGUID = @ClientGUID

	INSERT INTO @TblClipLocation
	(
		ClipGUID,
		RPID
	)
	SELECT
		TblClip.ClipGUID,
		IQCore_ClipMeta.Value
	FROM
			@TblClip AS TblClip
				INNER JOIN IQCore_ClipMeta
					ON	TblClip.ClipGUID = IQCore_ClipMeta._ClipGuid
					AND	Field = 'CCRootPathID' 

	UPDATE 
			@TblClipLocation
	SET
			FileLocation = Value
	FROM
			@TblClipLocation AS TblClipLocation
				INNER JOIN	IQCore_ClipMeta
					ON	TblClipLocation.ClipGUID = IQCore_ClipMeta._ClipGuid
					AND	IQCore_ClipMeta.Field = 'CCFileLocation'


	SELECT
			TblClipLocation.ClipGUID,
			(IQCore_RootPath.StoragePath + TblClipLocation.FileLocation) AS FileLocation
	FROM
			@TblClipLocation AS TblClipLocation
				INNER JOIN IQCore_RootPath
					ON	TblClipLocation.RPID = IQCore_RootPath.ID


		

END
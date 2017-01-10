CREATE Procedure [dbo].[usp_ArchiveClip_SelectByClipList]
	@XmlData xml
As 
Begin
	SELECT
			ArchiveClip.ClipTitle,
			ArchiveClip.ClipID,
			ArchiveClip.ThumbnailImagePath,
			ArchiveClip.ArchiveClipKey
	FROM
			ArchiveClip JOIN @XmlData.nodes('list/Clip') AS x(Item) 
			ON ArchiveClip.ClipID = Item.value('.', 'uniqueidentifier' )
	WHERE
			IsActive=1

	
End	
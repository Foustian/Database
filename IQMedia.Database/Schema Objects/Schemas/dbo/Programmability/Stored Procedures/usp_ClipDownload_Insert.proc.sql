
CREATE PROCEDURE [dbo].[usp_ClipDownload_Insert]
(
	@CustomerGUID	uniqueidentifier,
	@XmlData		xml
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ClipIDString varchar(Max)

	SELECT @ClipIDString = COALESCE(@ClipIDString + ', ', '') + 
			''''+CAST(XmlTbl.d.value('@ClipID','uniqueidentifier') AS varchar(36))+''''
	   
	FROM 
			@XmlData.nodes('/ClipDownload/Clip') as XmlTbl(d)

	DECLARE @Query	nvarchar(Max)
	
	set @Query='	
	Declare @XmlVar xml
	Set @XmlVar='''+convert(Varchar(Max),@XmlData)+'''
	insert into ClipDownload
	(
		CustomerGUID,
		ClipID,
		ClipDownloadStatus
	)
	Select
			'''+CONVERT(varchar(36),@CustomerGUID)+''' as CustomerID,
			XmlTbl.d.value(''@ClipID'',''uniqueidentifier'') as ClipID,
			1 as ClipDownloadStatus
	From
			@XmlVar.nodes(''/ClipDownload/Clip'') as XmlTbl(d)
	Where
			XmlTbl.d.value(''@ClipID'',''uniqueidentifier'') not in
			
			(
				Select
						ClipID
				From
						ClipDownload
				Where
						CustomerGUID='''+CONVERT(varchar(36),@CustomerGUID)+''' and						
						ClipDownloadStatus=1 and
						CONVERT(varchar(Max),ClipID) in ('+@ClipIDString+') and
						IsActive=1
			)'

print @Query

exec sp_executesql @Query
    
END

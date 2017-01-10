CREATE PROCEDURE [dbo].[usp_iqsvc_IQClipTimeSync_Data_InsertList]
	@ClipGuid uniqueidentifier,
	@XmlData xml

AS
BEGIN
	Insert into IQClipTimeSync_Data
	(
		_ClipGuid,
		_TypeID,
		Data,
		DateCreated,
		IsActive
	)
	SELECT
		@ClipGuid,
		sync.data.query('Type').value('.','int'),
		sync.data.query('Data').value('.','varchar(max)'),
		GETDATE(),
		1
	FROM
		@XmlData.nodes('list/item') as sync(data)
			left outer join IQClipTimeSync_Data
				on IQClipTimeSync_Data._TypeID = sync.data.query('Type').value('.','int')
				and IQClipTimeSync_Data._ClipGuid = @ClipGuid
	WHERE
		IQClipTimeSync_Data._ClipGuid IS NULL
	
	SELECT @@ROWCOUNT

END
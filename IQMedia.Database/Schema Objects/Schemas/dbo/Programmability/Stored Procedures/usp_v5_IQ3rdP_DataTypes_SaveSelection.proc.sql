CREATE PROCEDURE [dbo].[usp_v5_IQ3rdP_DataTypes_SaveSelection]
	@CustomerGuid uniqueidentifier,
	@DataTypeIDXml xml	
AS
BEGIN
    
    BEGIN TRANSACTION
	BEGIN TRY
	
	-- Delete any previous selections
	DELETE FROM IQMediaGroup.dbo.IQ3rdP_CustomerDataTypes
	WHERE _CustomerGuid = @CustomerGuid

	INSERT INTO IQMediaGroup.dbo.IQ3rdP_CustomerDataTypes (_CustomerGuid, _DataTypeID)
	SELECT	@CustomerGuid,
			Type.ID.value('@id', 'int')
	FROM	@DataTypeIDXml.nodes('list/item') as Type(ID)

	Select @@RowCount
	
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH	
		ROLLBACK TRANSACTION
		
		declare @IQMediaGroupExceptionKey bigint,
				@ExceptionStackTrace varchar(500),
				@ExceptionMessage varchar(500),
				@CreatedBy	varchar(50),
				@ModifiedBy	varchar(50),
				@CreatedDate	datetime,
				@ModifiedDate	datetime,
				@IsActive	bit				
		
		Select 
				@ExceptionStackTrace=(ERROR_PROCEDURE()+'_'+CONVERT(varchar(50),ERROR_LINE())),
				@ExceptionMessage=convert(varchar(50),ERROR_NUMBER())+'_'+ERROR_MESSAGE(),
				@CreatedBy='usp_v5_IQ3rdP_DataTypes_SaveSelection',
				@ModifiedBy='usp_v5_IQ3rdP_DataTypes_SaveSelection',
				@CreatedDate=GETDATE(),
				@ModifiedDate=GETDATE(),
				@IsActive=1				
		
		exec IQMediaGroup.dbo.usp_IQMediaGroupExceptions_Insert @ExceptionStackTrace,@ExceptionMessage,@CreatedBy,@CreatedDate,NULL,@IQMediaGroupExceptionKey output
		
		Select -1
	END CATCH    
END
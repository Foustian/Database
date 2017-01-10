
CREATE PROCEDURE [dbo].[usp_UGCRawMedia_Update]
(
	@RawMediaID		uniqueidentifier,
	@MetaData		XML
)
AS
BEGIN
	SET NOCOUNT OFF;
	
Begin Transaction
begin try
	
	
		Update
			 IQCore_RecordfileMeta
		Set Value = a.b.value('@Value','varchar(max)')		
			FROM
				@MetaData.nodes('Root/Meta') a(b) 
				INNER JOIN IQCore_RecordfileMeta IQC
				ON IQC.Field = a.b.value('@Key','varchar(max)')
				AND _RecordfileGuid =@RawMediaID
		
		
		
		
		UPDATE 
			IQCore_RecordfileMeta
		SET Value = ''
			FROM
				 @MetaData.nodes('Root/Meta') a(b) 
				 RIGHT OUTER JOIN IQCore_RecordfileMeta IQC
				 ON IQC.Field = a.b.value('@Key','varchar(max)')			 
				 WHERE  IQC._RecordfileGuid = @RawMediaID
				 AND Field != 'UGC-CreateDT'
				 AND a.b.value('@Value','varchar(max)') IS NULL
			  
			  
		Insert into IQCore_RecordfileMeta	
		(Field,Value,_RecordfileGuid)	
		Select 
		a.b.value('@Key','varchar(max)'),
		a.b.value('@Value','varchar(max)'),
		@RawMediaID		
			FROM 
				@MetaData.nodes('Root/Meta') a(b) 
			LEFT OUTER JOIN IQCore_RecordfileMeta IQC
			ON IQC.Field = a.b.value('@Key','varchar(max)')
			AND _RecordfileGuid =@RawMediaID
			where IQC._RecordfileGuid IS NULL
	
	
			
	Update
			IQUGCArchive
	Set
			Title= (Select	a.b.value('@Value','varchar(max)')		
						FROM
							@MetaData.nodes('Root/Meta') a(b) 
							WHERE
							a.b.value('@Key','varchar(max)') = 'UGC-Title'),
			Keywords =(Select	a.b.value('@Value','varchar(max)')		
						FROM
							@MetaData.nodes('Root/Meta') a(b) 
							WHERE
							a.b.value('@Key','varchar(max)') = 'UGC-Kwords'),
			[Description] =(Select	a.b.value('@Value','varchar(max)')		
						FROM
							@MetaData.nodes('Root/Meta') a(b) 
							WHERE
							a.b.value('@Key','varchar(max)') = 'UGC-Desc'),
			CustomerGUID=(Select	a.b.value('@Value','varchar(max)')		
						FROM
							@MetaData.nodes('Root/Meta') a(b) 
							WHERE
							a.b.value('@Key','varchar(max)') = 'iQUser'),
			CategoryGUID=(Select	a.b.value('@Value','varchar(max)')		
						FROM
							@MetaData.nodes('Root/Meta') a(b) 
							WHERE
							a.b.value('@Key','varchar(max)') = 'UGC-Category'),
			SubCategory1GUID = (Select	a.b.value('@Value','varchar(max)')		
									FROM
								@MetaData.nodes('Root/Meta') a(b) 
								WHERE
								a.b.value('@Key','varchar(max)') = 'UGC-SubCategory1'),
			SubCategory2GUID = (Select	a.b.value('@Value','varchar(max)')		
									FROM
								@MetaData.nodes('Root/Meta') a(b) 
								WHERE
								a.b.value('@Key','varchar(max)') = 'UGC-SubCategory2'),
			SubCategory3GUID = (Select	a.b.value('@Value','varchar(max)')		
									FROM
								@MetaData.nodes('Root/Meta') a(b) 
								WHERE
								a.b.value('@Key','varchar(max)') = 'UGC-SubCategory3'),
			ModifiedDate=GETDATE()
	Where
			UGCGUID=@RawMediaID
			
	commit transaction
	end try
	begin catch
	rollback transaction
	end catch			
	


END


CREATE PROCEDURE [dbo].[TestLock]
(
	@RecordfileGUID		uniqueidentifier,
	@Status	bit output
)
AS
BEGIN	
	SET NOCOUNT ON;
	
	BEGIN TRY
		
				SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
				--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
				BEGIN TRANSACTION
		
				/*DECLARE @LockResult int
 
				EXECUTE @LockResult = sp_getapplock 
					 @Resource    = 'RepeatableRead_TRANSACTION', 
					 @LockMode    = 'Exclusive',
					 @LockTimeout = 0
   
	
				IF @LockResult <> 0
					BEGIN
						--IF @@TRANCOUNT > 0
						--	BEGIN
								ROLLBACK TRANSACTION
						--	END
						SET @Status = 0
						RETURN
						--RAISERROR ( 51001, 16, 1 )
					END
				ELSE
					BEGIN*/
						 -- All code between the use of sp_getapplock above,
						 -- and sp_releaseapplock below will be restricted to 
						 -- only one user at a time.
		 
						print convert(varchar(26),getdate(),109)
						
							
						UPDATE IQCore_Recordfile SET [Status] = 'TESTSTATUS' WHERE [Guid] = @RecordfileGUID	 
						
		 
						print convert(varchar(26),getdate(),109)
						 -- Ten Second delay for Demonstration Purposes
						 
						 if (@@ROWCOUNT>0)
							begin
								SET @Status = 1
							end
						else
							begin
								SET @Status=0
							end
						 
						WAITFOR DELAY '00:00:5';
						-- Remove these three lines for 'Normal' use
						
						
						
						--EXECUTE sp_releaseapplock @Resource = 'RepeatableRead_TRANSACTION'
						
						COMMIT TRANSACTION
				/*END*/
				
		END TRY
		
		BEGIN CATCH
		
			--EXECUTE sp_releaseapplock @Resource = 'RepeatableRead_TRANSACTION'
			Set @Status=0
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
		
		END CATCH

    
END

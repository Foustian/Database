CREATE PROCEDURE [dbo].[usp_TableLockTest]
	@Status	BIT OUTPUT
AS
   BEGIN
   
		BEGIN TRY
		
				--SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
				SET TRANSACTION ISOLATION LEVEL READ COMMITTED
				BEGIN TRANSACTION
		
				DECLARE @LockResult int
 
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
					BEGIN
						 -- All code between the use of sp_getapplock above,
						 -- and sp_releaseapplock below will be restricted to 
						 -- only one user at a time.
		 
						DECLARE @RecordfileID AS UNIQUEIDENTIFIER
		 
						SELECT top  1 @RecordfileID = [Guid] FROM IQCore_Recordfile WHERE [Status] <> 'TESTSTATUS' ORDER BY DateCreated DESC;
							
						UPDATE IQCore_Recordfile SET [Status] = 'TESTSTATUS' WHERE [Guid] = @RecordfileID
		 
						SELECT * FROM IQCore_Recordfile WHERE [Guid] = @RecordfileID
		 
						 -- Ten Second delay for Demonstration Purposes
						WAITFOR DELAY '00:00:30';
						-- Remove these three lines for 'Normal' use
						
						SET @Status = 1
						
						EXECUTE sp_releaseapplock @Resource = 'RepeatableRead_TRANSACTION'
						
						COMMIT TRANSACTION
				END
				
		END TRY
		
		BEGIN CATCH
		
			EXECUTE sp_releaseapplock @Resource = 'RepeatableRead_TRANSACTION'
			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END
		
		END CATCH
 
		
   END
 

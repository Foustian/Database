-- =============================================
-- Author:		<Author,,Name>
-- Create date: 29 July 2013
-- Description:	Delete record from IQUGCArchive table
-- =============================================

CREATE PROCEDURE [dbo].[usp_v4_IQUGCArchive_Delete]
	@ClientGuid				UNIQUEIDENTIFIER,
	@IQUGCArchiveXML		XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
	DECLARE @Result AS TABLE (UGCArchiveID BIGINT)

    IF @IQUGCArchiveXML Is NOT NULL
		BEGIN
			
			DECLARE @tblIQUGCArvhice AS TABLE(ID INT IDENTITY(1,1),IQUGCArchiveKey BIGINT)
			
			INSERT INTO @tblIQUGCArvhice ( IQUGCArchiveKey )
			SELECT	tbl.c.query('.').value('.','BIGINT')
			FROM	@IQUGCArchiveXML.nodes('list/id') as tbl(c)
			
			
			DECLARE @Count AS INT
			SET @Count = 1
			
			WHILE @Count <= (SELECT COUNT(*) FROM @tblIQUGCArvhice)
				BEGIN
				
					DECLARE @ID AS BIGINT
					SET @ID = (SELECT IQUGCArchiveKey FROM @tblIQUGCArvhice WHERE ID = @Count)
				
					UPDATE IQUGCArchive SET IsActive = 0,ModifiedDate = GETDATE()
					WHERE IQUGCArchiveKey = @ID AND ClientGuid = @ClientGuid AND IsActive = 1
					
					
					SET @Count = @Count + 1
					
					IF @@ROWCOUNT = 1
						BEGIN
							INSERT INTO @Result VALUES(@ID)
						END
					
				END
		END
	
	SELECT * FROM @Result
	
END
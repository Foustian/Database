CREATE PROCEDURE [dbo].[usp_V5_Group_Client_AddSubClient]
(
	@MCID	BIGINT,
	@SCXml	XML,
	@CustomerGUID	UNIQUEIDENTIFIER
)
AS
BEGIN

	SET NOCOUNT ON;
	SET XACT_ABORT ON;	

	DECLARE @SubClientTbl	TABLE (ID BIGINT)

	INSERT INTO @SubClientTbl
	SELECT
		tbl.c.value('@ID','BIGINT')
	FROM
			@SCXml.nodes('list/item') as tbl(c)		
	

	BEGIN TRANSACTION

		UPDATE
				Client
		SET
				MCID = @MCID,
				ModifiedDate = GETDATE(),
				ModifiedBy = @CustomerGUID
		From
				Client
						INNER JOIN	@SubClientTbl AS SC
							ON	Client.ClientKey = SC.ID

	COMMIT TRANSACTION

END
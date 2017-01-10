-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ArchiveClip_SelectByDate 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@CustomerID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		 * 
	FROM
		 ArchiveClip 
	WHERE 
		CustomerID=@CustomerID and ClipCreationDate between @StartDate and @EndDate
END

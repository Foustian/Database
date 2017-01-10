-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_IQ_News_Search]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select
		Headline,
		ReleaseDate,
		SubHead,
		SUBSTRING(Detail,1,CHARINDEX(' ',Detail,449)) + '....' as 'Detail',
		Url		
	From
		IQ_News
	Where
		ReleaseDate <= cast(Getdate() as Date)
		AND IsActive = 1
	Order by 
		ReleaseDate desc
		
		
    
END

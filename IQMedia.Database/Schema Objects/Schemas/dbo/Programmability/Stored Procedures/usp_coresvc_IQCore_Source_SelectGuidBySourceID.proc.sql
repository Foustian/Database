
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_Source_SelectGuidBySourceID]
	@SourceID varchar(20)
AS
BEGIN	
	SET NOCOUNT ON;

    SELECT 
			[Guid]
	FROM 
			[IQMediaGroup].[dbo].[IQCore_Source]
	Where 
			SourceID = @SourceID
		and IsActive = 1

END

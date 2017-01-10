
CREATE PROCEDURE [dbo].[usp_coresvc_IQCore_Rootpath_Update]
	@ID bigint,
	@status bit
AS
BEGIN


 
	SET NOCOUNT ON;

    UPDATE IQMediaGroup.dbo.IQCore_Rootpath
      SET [IsActive] = @status
	WHERE ID = @ID
	
  select @@ROWCOUNT as RowAffected
    
END

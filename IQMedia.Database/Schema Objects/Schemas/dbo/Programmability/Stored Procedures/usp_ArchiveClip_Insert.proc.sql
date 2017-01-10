-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ArchiveClip_Insert] 
	-- Add the parameters for the stored procedure here
	@ClipID uniqueidentifier,
	@ClipLogo varchar(150),
	@ClipTitle varchar(150),
	@ClipDate DateTime,
	@FirstName varchar(150),
	@CustomerID bigint,
	@Category varchar(50),
	@Description varchar(500),
	@ClosedCaption XML,
	@ClipCreationDate Datetime,
	--@CreatedBy varchar(50),
	--@ModifiedBy varchar(50),
	@CategoryGUID uniqueidentifier,
	@ClientGUID uniqueidentifier,
	@CustomerGUID uniqueidentifier,
	@ArchiveClipKey int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @ClipCount int
    SELECT @ClipCount = COUNT(*) FROM ArchiveClip WHERE ClipID=@ClipID
    IF @ClipCount = 0 
    BEGIN 
    
    Declare @CustomerFirstName varchar(50)
    
    Select
			@CustomerFirstName=FirstName
	From
			Customer
	Where
			Customer.CustomerGUID=@CustomerGUID
    
    INSERT INTO	
			ArchiveClip
			(
				ClipID,
				ClipLogo,
				ClipTitle,
				ClipDate,
				FirstName,
				CustomerID,
				Category,
				--CreatedBy,
				[Description],
				ClosedCaption,
				ClipCreationDate,
				--ModifiedBy,
				CreatedDate,
				ModifiedDate,
				IsActive,
				CustomerGUID,
				ClientGUID,
				CategoryGUID
			)
			VALUES
			(
				@ClipID,
				@ClipLogo,
				@ClipTitle,
				@ClipDate,
				@CustomerFirstName,
				@CustomerID,
				@Category,
				@Description,
				@ClosedCaption,
				@ClipCreationDate,
				--@CreatedBy,
				--@ModifiedBy,
				SYSDATETIME(),
				SYSDATETIME(),
				1,
				@CustomerGUID,
				@ClientGUID,
				@CategoryGUID				
			)
			SELECT @ArchiveClipKey = SCOPE_IDENTITY()
		END
	ELSE
		SET @ArchiveClipKey = 0
END

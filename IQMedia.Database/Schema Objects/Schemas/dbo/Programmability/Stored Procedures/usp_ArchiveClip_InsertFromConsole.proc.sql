
CREATE PROCEDURE [dbo].[usp_ArchiveClip_InsertFromConsole]
(
	@ClipID uniqueidentifier,
	@ClipLogo varchar(150),
	@ClipTitle varchar(255),
	@ClipDate DateTime,
	@FirstName varchar(150),
	@CustomerID bigint,
	@Category varchar(50),
	@Keywords  varchar(500),
	@Description varchar(500),
	@ClosedCaption XML,
	@ClipCreationDate Datetime,
	@CategoryGUID uniqueidentifier,
	@ClientGUID uniqueidentifier,
	@CustomerGUID uniqueidentifier
	
)
AS
BEGIN	
	SET NOCOUNT OFF;
	
	declare @Count int
	
	Select
			@Count=COUNT(*)
	From
			ArchiveClip
	Where 
			ClipID=@ClipID
			
	if(@Count=0)
		begin
		
			INSERT INTO	ArchiveClip
			(
				ClipID,
				ClipLogo,
				ClipTitle,
				ClipDate,
				FirstName,
				CustomerID,
				Category,
				[Keywords],				
				[Description],
				ClosedCaption,
				ClipCreationDate,				
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
				@FirstName,
				@CustomerID,
				@Category,
				@Keywords,
				@Description,
				@ClosedCaption,
				@ClipCreationDate,				
				SYSDATETIME(),
				SYSDATETIME(),
				1,
				@CustomerGUID,
				@ClientGUID,
				@CategoryGUID				
			)
		
		end
	else
		begin
		
				update [dbo].[ArchiveClip]
		
				set	CustomerGUID=@CustomerGUID,
					ClientGUID=@ClientGUID,
					CategoryGUID=@CategoryGUID,
					FirstName=@FirstName,
					ClipTitle=@ClipTitle,
					ModifiedDate=GETDATE(),
					ClipLogo= @ClipLogo,
					ClipDate=@ClipDate,
					CustomerID=@CustomerID,
					Category= @Category,
					[Keywords] =@Keywords,
					[Description]=@Description,
					ClosedCaption=@ClosedCaption,
					ClipCreationDate=@ClipCreationDate
				Where
					ArchiveClip.ClipID =@ClipID and
					(
						(ArchiveClip.CategoryGUID is null or ArchiveClip.CategoryGUID!=@CategoryGUID) or
						(ArchiveClip.CustomerGUID is null or ArchiveClip.CustomerGUID!=@CustomerGUID) or
						(ArchiveClip.ClientGUID is null or ArchiveClip.ClientGUID!=@ClientGUID) or
						(CONVERT(varchar(Max),ArchiveClip.ClosedCaption)!=CONVERT(varchar(Max),@ClosedCaption))
					) 
		
		end	
			

    
END

CREATE PROCEDURE [dbo].[usp_iqsvc_GetStationSharingByClipIDNClientGUID]
	@ClipID	uniqueidentifier,
	@ClientGuid uniqueidentifier,
	@CustomerGuid uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
		DECLARE @IQStationID varchar(255)
		Declare @IsSharing bit		
		set @IsSharing = 0
		
		
		Declare @IsSharingAccess bit = 0		  

		SELECT 
				@IsSharingAccess = CASE WHEN ClientRole.IsAccess = 1 AND CustomerRole.IsAccess = 1 THEN 1 ELSE 0 END
		FROM 
				Role 
					INNER JOIN ClientRole
						ON Role.RoleKey = ClientRole.RoleID
					INNER JOIN CustomerRole
						ON ROLE.RoleKey = CustomerRole.RoleID
						AND CustomerRole.RoleID = ClientRole.RoleID
					INNER JOIN Client
						ON ClientRole.ClientID = Client.ClientKey
					INNER JOIN Customer 
						ON Customer.CustomerKey = CustomerRole.CustomerID
						AND Customer.ClientID = Client.ClientKey
		WHERE
			 Role.RoleName ='IsSharingEnable' AND Client.ClientGUID = @ClientGuid AND Customer.CustomerGUID = @CustomerGuid 
			 AND Role.IsActive = 1 AND ClientRole.IsActive = 1 and CustomerRole.IsActive = 1
			 AND Customer.IsActive = 1 AND Client.IsActive = 1
						

		IF(@IsSharingAccess = 1)
		BEGIN
			Select 
				@IQStationID =IQ_Station.IQ_Station_ID 
			FROM 
				IQCore_Clip
			
				INNER JOIN IQCore_Recordfile
				ON IQCore_Clip._RecordfileGuid = IQCore_Recordfile.Guid
		
				INNER JOIN IQCore_Recording
				ON IQCore_Recordfile._RecordingID = IQCore_Recording.ID
		
				INNER JOIN IQCore_Source
				ON IQCore_Recording._SourceGuid = IQCore_Source.Guid
		
				INNER JOIN IQ_Station
				ON IQCore_Source.SourceID = IQ_Station.IQ_Station_ID
			
				INNER JOIN ArchiveClip
				ON IQCore_Clip.Guid = ArchiveClip.ClipID
			
		
				Where
				 IQCore_Clip.Guid = @ClipID	AND
				 IQCore_source.IsActive = 1 AND IQ_Station.IsActive = 1
				 AND ArchiveClip.IsActive = 1


			Select 
				@IsSharing = 
				Case 
					When IQClient_StationSharing.IQ_Station_ID IS NULL 
					Then CAST(isnull(IQ_Station.IsSharing,0) AS BIT)			
				Else
					CAST(IsNull(IQClient_StationSharing.IsActive,0) AS BIT)
		
				END
				
			From
				IQ_Station
			
				LEFT OUTER JOIN IQClient_StationSharing
				ON IQ_Station.IQ_Station_ID = IQClient_StationSharing.IQ_Station_ID
				AND IQClient_StationSharing.ClientGUID = @ClientGuid
			
			Where 
				IQ_Station.IQ_Station_ID = @IQStationID
		END
			
		Select cast(@IsSharing as bit)
		
END
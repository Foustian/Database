CREATE PROCEDURE [dbo].[usp_v4_IQTimeSync_Data_SelectByIQCCKeyAndCustomerGuid]
	@CustomerGuid uniqueidentifier,
	@IQ_CC_Key varchar(50)
AS
BEGIN
	DECLARE @RoleAccess bit,@ClientGuid uniqueidentifier

	SELECT @ClientGuid = ClientGUID FROM Customer inner join Client on Customer.ClientID = Client.ClientKey and Client.IsActive = 1 and Customer.IsActive = 1 and CustomerGUID = @CustomerGuid
	
	SELECT @RoleAccess = CASE WHEN CustomerRole.IsAccess =1 and ClientRole.IsAccess = 1 THEN 1 ELSE 0 END
	FROM 
			Customer	
				inner join Client
					on Customer.ClientID = Client.ClientKey
					and Customer.IsActive = 1
					and Client.IsActive = 1
				inner join CustomerRole
					on Customer.CustomerKey = CustomerRole.CustomerID
					and CustomerRole.IsActive =1
				inner join ClientRole
					on Client.ClientKey = ClientRole.ClientID
					and CustomerRole.RoleID = ClientRole.RoleID
					and ClientRole.IsActive = 1
				inner join [Role]
					on CustomerRole.RoleID = [Role].RoleKey
					and ClientRole.RoleID = [Role].RoleKey
					and [Role].IsActive = 1
	Where
		Customer.CustomerGUID = @CustomerGuid
		and RoleName='TimeSync'


	IF(@RoleAccess = 1)
	BEGIN
		DECLARE @TimeSyncTypes varchar(max)
		set @TimeSyncTypes = case 
			when exists(select value from IQClient_CustomSettings where IQClient_CustomSettings._ClientGuid = @ClientGuid and Field ='TimeSyncTypes') then(
				select value from IQClient_CustomSettings where IQClient_CustomSettings._ClientGuid = @ClientGuid and Field ='TimeSyncTypes'
			)
			else (
				select value from IQClient_CustomSettings where IQClient_CustomSettings._ClientGuid = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER) and Field ='TimeSyncTypes'
			)
			end

		SELECT 
			IQTimeSync_Data.Data,
			IQTimeSync_Type.Name,
			IQTimeSync_Type.GraphStructure
		FROM 
			IQTimeSync_Data
				inner join IQTimeSync_Type 
					on IQTimeSync_Data._TypeID = IQTimeSync_Type.ID
					and IQTimeSync_Data.IsActive = 1
					and IQTimeSync_Type.IsActive = 1
		WHERE
			IQ_CC_Key = @IQ_CC_Key
			and _TypeID in (
				SELECT 
						SplitTbl.Items
					from 
						Split(@TimeSyncTypes,',') as SplitTbl
			)
		ORDER BY Name
		
	END		 
END
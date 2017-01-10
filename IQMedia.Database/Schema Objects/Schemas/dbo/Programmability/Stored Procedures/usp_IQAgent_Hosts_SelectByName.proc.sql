CREATE PROCEDURE [dbo].[usp_IQAgent_Hosts_SelectByName]
	@Hostname varchar(50)
AS
BEGIN

SELECT ID, IPAddress, Hostname, WorkerCount, Active
FROM [IQMediaGroup].[dbo].[IQAgent_Hosts]
WHERE Hostname = @Hostname

END
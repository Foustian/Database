
CREATE PROCEDURE usp_STATSKEDPROG_FillDataTables

AS
BEGIN
	SET NOCOUNT ON;

    truncate table SSP_IQ_Dma_Name

	truncate table SSP_IQ_Cat

	truncate table SSP_IQ_Class

	truncate table SSP_Station_Affil

	insert into SSP_IQ_Dma_Name
	(
		IQ_Dma_Name,
		IQ_Dma_Num,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy
	)
	SELECT		
			Distinct IQ_Dma_Name,
			IQ_Dma_Num,
			GETDATE(),
			GETDATE(),
			'Service',
			'Service'
	FROM
			STATSKEDPROG
	WHERE
			IsActive= 1
	ORDER BY
			IQ_Dma_Num
			
	insert into SSP_IQ_Cat
	(
		IQ_Cat,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy
	)
	SELECT		
			Distinct IQ_Cat,
			GETDATE(),
			GETDATE(),
			'Service',
			'Service'
	FROM
			STATSKEDPROG
	WHERE
			IsActive= 1
			
	insert into SSP_IQ_Class
	(
		IQ_Class,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy
	)
	SELECT		
			Distinct IQ_Class,
			GETDATE(),
			GETDATE(),
			'Service',
			'Service'
	FROM
			STATSKEDPROG
	WHERE
			IsActive= 1
			
	insert into SSP_Station_Affil
	(
		Station_Affil,
		CreatedDate,
		ModifiedDate,
		CreatedBy,
		ModifiedBy
	)
	SELECT		
			Distinct Station_Affil,
			GETDATE(),
			GETDATE(),
			'Service',
			'Service'
	FROM
			STATSKEDPROG
	WHERE
			IsActive= 1
		
END

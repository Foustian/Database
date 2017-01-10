CREATE PROCEDURE [dbo].[usp_IQAgent_Compete_SelectByURL]
	@URL varchar(100)
AS
BEGIN

	SELECT
		@URL as CompeteURL,
		CASE
			WHEN (c_uniq_visitor > 0 AND results = 'A')
			THEN
				CAST(1 AS BIT)
			ELSE
				CAST(0 AS BIT)
		END as IsCompeteAll,
		c_uniq_visitor / 30 as Audience,
		A_M_18_24 AS MaleAudience_18_24,
		A_M_25_34 AS MaleAudience_25_34,
		A_M_35_44 AS MaleAudience_35_44,
		A_M_45_54 AS MaleAudience_45_54,
		A_M_55_64 AS MaleAudience_55_64,
		A_M_65_PLUS AS MaleAudience_Above_65,
		A_F_18_24 AS FemaleAudience_18_24,
		A_F_25_34 AS FemaleAudience_25_34,
		A_F_35_44 AS FemaleAudience_35_44,
		A_F_45_54 AS FemaleAudience_45_54,
		A_F_55_64 AS FemaleAudience_55_64,
		A_F_65_PLUS AS FemaleAudience_Above_65
	FROM IQ_CompeteAll
	WHERE CompeteURL = @URL AND CompeteURL NOT IN ('facebook.com', 'twitter.com', 'friendfeed.com')

END
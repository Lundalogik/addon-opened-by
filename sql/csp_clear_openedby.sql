USE [lime]
GO
/****** Object:  StoredProcedure [dbo].[csp_set_openedby]    Script Date: 2017-08-03 16:27:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lars Jensen
-- Create date: 2017-08-03
-- Description:	Sets opened by for any table, record and user
-- =============================================
CREATE PROCEDURE [dbo].[csp_clear_openedby]
	AS
BEGIN
    
    SELECT * 
    INTO #temp
    FROM (
	   SELECT * FROM openedby
	   WHERE timestamp > CAST(GETDATE() AS DATE)
    ) as temp

    TRUNCATE TABLE openedby
    
    INSERT INTO openedby (status, createduser, createdtime, updateduser, timestamp, rowguid, tablename, idrecord, iduser)
    SELECT status, createduser, createdtime, updateduser, timestamp, rowguid, tablename, idrecord, iduser FROM #temp

    DROP TABLE #temp
END

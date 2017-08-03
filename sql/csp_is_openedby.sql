
-- =============================================
-- Author:		Lars Jensen
-- Create date: 2017-04-13
-- Description:	Gets opened by for any table, record and user
-- =============================================
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'csp_is_openedby' AND UPPER(type) = 'P')
   DROP PROCEDURE [csp_is_openedby]
GO
CREATE PROCEDURE [dbo].[csp_is_openedby]
	@@idrecord INT,
	@@tablename NVARCHAR(64),
	@@openedby NVARCHAR(2000) OUTPUT
AS
BEGIN    
    -- FLAG-EXTERNALACCESS --
    DECLARE @openedby NVARCHAR(2000)
    SET @openedby = ''
    
    SELECT DISTINCT @openedby = @openedby + CAST(iduser AS NVARCHAR) + ';' FROM [openedby] WHERE tablename=@@tablename AND idrecord=@@idrecord AND status = 0
    SET @@openedby = ''
    SELECT @@openedby = @openedby
END


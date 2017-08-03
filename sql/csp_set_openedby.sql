-- =============================================
-- Author:		Lars Jensen
-- Create date: 2017-03-27
-- Description:	Sets opened by for any table, record and user
-- =============================================
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'csp_set_openedby' AND UPPER(type) = 'P')
   DROP PROCEDURE [csp_set_openedby]
GO
CREATE PROCEDURE [dbo].[csp_set_openedby]
	@@iduser INT,
	@@idrecord INT,
	@@delete INT,
	@@tablename NVARCHAR(64)
AS
BEGIN
	BEGIN
	-- FLAG-EXTERNALACCESS --
	IF @@delete = 0
	   BEGIN
		  INSERT INTO openedby (tablename, idrecord, iduser, status, createduser, createdtime)
			 VALUES (@@tablename, @@idrecord, @@iduser, 0, 1, GETDATE()) 			
	   END
	ELSE
		BEGIN
			DELETE FROM openedby
			WHERE tablename = @@tablename AND idrecord = @@idrecord AND iduser = @@iduser
		END
	END
END

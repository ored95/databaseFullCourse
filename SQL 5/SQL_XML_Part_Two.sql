------------------------------------------------
--------------- XML documents ------------------
------------------------------------------------
----- Part #2: OPEN and SAVE XML-documents -----
------------------------------------------------
-- #Syntax:
-- OPENXML( idoc int [ in] , rowpattern nvarchar [ in ] , [ flags byte [ in ] ] )   
-- [ WITH ( SchemaDeclaration | TableName ) ]  

-- Instruction:
-- idoc: Is the document handle of the internal representation of an XML document. 
--       The internal representation of an XML document is created by calling sp_xml_preparedocument.
-- rowpattern: Is the XPath pattern used to identify the nodes 
--            (in the XML document whose handle is passed in the idoc parameter) to be processed as rows.
-- flags: Indicates the mapping that should be used between the XML data and the relational rowset, 
--		  and how the spill-over column should be filled. flags is an optional input parameter, 
--		  and can be one of the following values.
---------------------------------------------------------------------------------------------------------
-- Byte value | Description
---------------------------------------------------------------------------------------------------------
--		0	  |	Defaults to attribute-centric mapping.
---------------------------------------------------------------------------------------------------------
--		1	  |	Use the attribute-centric mapping. Can be combined with XML_ELEMENTS. 
--			  |	In this case, attribute-centric mapping is applied first, and then 
--			  |	element-centric mapping is applied for all columns that are not yet dealt with.
---------------------------------------------------------------------------------------------------------
--		2	  |	Use the element-centric mapping. Can be combined with XML_ATTRIBUTES. 
--			  |	In this case, attribute-centric mapping is applied first, 
--			  | and then element-centric mapping is applied for all columns not yet dealt with.
---------------------------------------------------------------------------------------------------------
--		8	  | Can be combined (logical OR) with XML_ATTRIBUTES or XML_ELEMENTS. 
--            | In the context of retrieval, this flag indicates that the consumed data 
--            | should not be copied to the overflow property @mp:xmltext.
---------------------------------------------------------------------------------------------------------
USE Lab01;
GO

-- #1 SELECT and OPENXML
DECLARE @idoc INT, @doc VARCHAR(5000);
SET @doc = '
<ROOT>
	<iPhone ModelID="M68" TradeName="iPhone" ModelName="iPhone 1,1">
		<Information OS="iPhone OS 1.0"
					 System-On-Chip="Samsung S5L8900"
					 CPU="ARM 1176JZ(F)-S"
					 RAM="128MB"
					 Storage="4GB/8GB"
					 Top-Data-Speed="EDGE"
					 Battery="1400mAh"
					 Release-Date="2007-06-29">
		</Information>
	</iPhone>
	<iPhone ModelID="N82" TradeName="iPhone 3G" ModelName="iPhone 1,2">
		<Information OS="iPhone OS 2.0"
					 System-On-Chip="Samsung S5L8900"
					 CPU="ARM 1176JZ(F)-S"
					 RAM="128MB"
					 Storage="8GB/16GB"
					 Top-Data-Speed="3G 3.6"
					 Battery="1150mAh"
					 Release-Date="2008-07-11">
		</Information>
	</iPhone>
	<iPhone ModelID="N88" TradeName="iPhone 3GS" ModelName="iPhone 2,1">
		<Information OS="iPhone OS 3.0"
					 System-On-Chip="Samsung APL0298C05"
					 CPU="600MHz ARM Cortex A8"
					 RAM="256MB"
					 Storage="16GB/32GB"
					 Top-Data-Speed="HSPA 7.2"
					 Battery="1219mAh"
					 Release-Date="2009-06-19">
		</Information>
	</iPhone>
	<iPhone ModelID="N90/N92" TradeName="iPhone 4" ModelName="iPhone 3,1">
		<Information OS="iOS 4"
					 System-On-Chip="Apple A4"
					 CPU="800MHz ARM Cortex A8"
					 RAM="512MB"
					 Storage="16GB/32GB"
					 Top-Data-Speed="HSPA 7.2"
					 Battery="1420mAh"
					 Release-Date="2010-06-24">
		</Information>
	</iPhone>
	<iPhone ModelID="N94" TradeName="iPhone 4S" ModelName="iPhone 4,1">
		<Information OS="iOS 5" 
					 System-On-Chip="Apple A5" 
					 CPU="800MHz Dual-core ARM Cortex A9" 
					 RAM="512MB" 
					 Storage="16GB/32GB/64GB" 
					 Top-Data-Speed="HSPA 14.4" 
					 Battery="1430mAh"
					 Release-Date="2011-10-14">
		</Information>
	</iPhone>
	<iPhone ModelID="N41/N42" TradeName="iPhone 5" ModelName="iPhone 5,1">
		<Information OS="iOS 6"
					 System-On-Chip="Apple A6"
					 CPU="1.2GHz Dual-core custom ARM Cortex v7s"
					 RAM="1GB"
					 Storage="16GB/32GB/64GB"
					 Top-Data-Speed="LTE/DC-HSPA"
					 Battery="1440mAh"
					 Release-Date="2012-09-21">
		</Information>
	</iPhone>
</ROOT>';

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc
-- SELECT statement using OPENXML provider  

SELECT *
FROM OPENXML(@idoc, '/ROOT/iPhone/Information', 2)
WITH (ModelID VARCHAR(10)	'../@ModelID',
	  TradeName VARCHAR(15)	'../@TradeName',
	  ModelName VARCHAR(10)	'../@ModelName',
	  OS		VARCHAR(12)	'../Information/@OS',
	  SystemOnChip VARCHAR(30)	'../Information/@System-On-Chip',
	  CPU		VARCHAR(50)	'../Information/@CPU',
	  RAM		VARCHAR(10)	'../Information/@RAM',
	  Storage	VARCHAR(20)	'../Information/@Storage',
	  TopDataSpeed VARCHAR(20)	'../Information/@Top-Data-Speed',
	  Battery	VARCHAR(10)	'../Information/@Battery',
	  ReleaseDate DATETIME	'../Information/@Release-Date');
GO

-- remove used OPEN XML document
EXEC sp_xml_removedocument @idoc;
GO

-----------------------------------------------------------------------------
-- #2 SELECT statement using OPENROWSET provider 
DECLARE @idoc INT
DECLARE @doc XML
SELECT @doc = c FROM OPENROWSET(BULK 'D:\BigDATA\SQL 5\root.xml', SINGLE_BLOB) AS TEMP(c)

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

SELECT *
FROM OPENXML (@idoc, '/ROOT/iPhone', 1)
WITH (ModelID VARCHAR(10), TradeName VARCHAR(20), ModelName VARCHAR(20));
GO

----------------------------------------------------------------------------------------------
-- #3 Result as the edge TABLE type
DECLARE @idoc INT
DECLARE @doc XML
SELECT @doc = c FROM OPENROWSET(BULK 'D:\BigDATA\SQL 5\root.xml', SINGLE_BLOB) AS TEMP(c)

EXEC sp_xml_preparedocument @idoc OUTPUT, @doc

SELECT *
FROM OPENXML (@idoc, '/ROOT/iPhone')
--WHERE [text] IS NOT NULL
GO

EXEC sp_xml_removedocument @idoc
GO
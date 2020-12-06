USE MERCADO_01

ALTER PROCEDURE p_REMOVER_VENDA(@VALOR AS DECIMAL(10,2), @NOME AS VARCHAR(60), @VEN_ID AS INT)
 AS
 DELETE TBL_PAGAMENTO WHERE VENDA_ID= @VEN_ID
 UPDATE TBL_CLIENTE SET CLI_DIVIDA += @VALOR WHERE CLI_NOME = @NOME
 DELETE TBL_ITEM_VENDA WHERE VEN_ID = @VEN_ID
 DELETE TBL_VENDA WHERE VEN_ID = @VEN_ID
 GO

ALTER PROCEDURE p_REMOVER_ITEM(@NOME_CLIENTE VARCHAR(60), @VENDAID INT, @PRODID INT, @QTDREMOVER INT, @QTD_TOTAL_ITEM INT, @VALOR_TOTAL_VENDA DECIMAL(10,2), @VALOR_TOTAL_ITEM DECIMAL(10,2))
AS

DECLARE @DINHEIRO DECIMAL(10,2)
DECLARE @VALORUNITARIO DECIMAL(10,2) =  @VALOR_TOTAL_ITEM / @QTD_TOTAL_ITEM
DECLARE @VALORREMOVER DECIMAL(10,2) =  @VALORUNITARIO * @QTDREMOVER
DECLARE @VALORDEDOISPAGAMENTOS DECIMAL(10,2)  

SELECT @DINHEIRO = (SELECT PAG_DINHEIRO FROM TBL_PAGAMENTO WHERE VENDA_ID = @VENDAID);
UPDATE TBL_CLIENTE SET CLI_DIVIDA += @VALORREMOVER WHERE CLI_NOME = @NOME_CLIENTE
UPDATE TBL_VENDA SET VEN_TOTAL = VEN_TOTAL - @VALORREMOVER, VEN_QTD -= @QTDREMOVER WHERE VEN_ID = @VENDAID

IF(@QTDREMOVER < @QTD_TOTAL_ITEM)
BEGIN
UPDATE TBL_ITEM_VENDA SET ITEM_QTD -= @QTDREMOVER, ITEM_VALOR -= @VALORREMOVER WHERE PROD_ID = @PRODID
UPDATE TBL_PAGAMENTO SET PAG_DINHEIRO -= @VALORREMOVER WHERE VENDA_ID = @VENDAID
UPDATE TBL_PRODUTO SET PROD_QTD += @QTDREMOVER WHERE PROD_ID = @PRODID
END

ELSE IF(@QTDREMOVER = @QTD_TOTAL_ITEM)
BEGIN
DELETE TBL_ITEM_VENDA WHERE VEN_ID = @VENDAID AND PROD_ID = @PRODID
UPDATE TBL_PAGAMENTO SET PAG_DINHEIRO -= @VALORREMOVER WHERE VENDA_ID = @VENDAID
UPDATE TBL_PRODUTO SET PROD_QTD += @QTDREMOVER WHERE PROD_ID = @PRODID
END

--ELSE IF(@VALOR_TOTAL_VENDA = @VALORREMOVER)
--BEGIN
--DELETE TBL_PAGAMENTO WHERE VENDA_ID = @VENDAID
--DELETE TBL_ITEM_VENDA WHERE VEN_ID = @VENDAID AND PROD_ID = @PRODID
--UPDATE TBL_PRODUTO SET PROD_QTD += @QTDREMOVER WHERE PROD_ID = @PRODID
--END

--DECLARE @VENDTOTAL DECIMAL(10,2)=(SELECT VEN_TOTAL FROM TBL_VENDA WHERE VEN_ID = @VENDAID)
--IF(@VENDTOTAL = 0.00)
--BEGIN
--DELETE TBL_VENDA WHERE VEN_ID = @VENDAID
--END

GO


exec p_REMOVER_ITEM @NOME_CLIENTE='CLIENTE-1', @VENDAID = 3, @PRODID =  3, @QTDREMOVER =2,  @QTD_TOTAL_ITEM = 2, @VALOR_TOTAL_VENDA = 14.00, @VALOR_TOTAL_ITEM = 4.00

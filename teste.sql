-- Criei o Schema "teste" se caso ele não exista
CREATE SCHEMA IF NOT EXISTS teste;

-- Usar o Schema "teste"
USE teste;

-- Criação da tabela "base_teste"
CREATE TABLE IF NOT EXISTS base_teste (
    id INT,
    unidade_consumidora BIGINT,
    status VARCHAR(10),
    mes DATE,
    valor_cobrado DECIMAL(10,2),
    valor_economia DECIMAL(10,2),
    valor_fatura_concessionaria DECIMAL(10,2),
    porcentagem_economia DECIMAL(5,2)
);

-- Carregamento do arquivo CSV na tabela "base_teste"
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/base_teste.csv'          -- Caminho de destino do arquivo no computador
INTO TABLE base_teste                                                                    -- Copia todas as colunas para uma nova tabela 
FIELDS TERMINATED BY ';'                                                                 -- especifica o delimitador que separa os campos (colunas) no arquivo CSV
LINES TERMINATED BY '\n'                                                                 -- informa que cada linha de dados no arquivo CSV é separada por uma quebra de linha (\n--> Representa a mudança do cursor para a linha seguinte)
IGNORE 1 ROWS                                                                            -- ignorar a primeira linha do arquivo durante o carregamento dos dados
(id, unidade_consumidora, status, mes, valor_cobrado, @valor_economia, @valor_fatura_concessionaria, @porcentagem_economia)
SET                                                                                                                          -- aplicar transformações aos valores antes de inseri-los nas respectivas colunas
    valor_economia = NULLIF(TRIM(REPLACE(REPLACE(@valor_economia, '\r', ''), '\n', '')), ''),                                -- tratamento dos dados
    valor_fatura_concessionaria = NULLIF(TRIM(REPLACE(REPLACE(@valor_fatura_concessionaria, '\r', ''), '\n', '')), ''),
    porcentagem_economia = NULLIF(TRIM(REPLACE(REPLACE(@porcentagem_economia, '\r', ''), '\n', '')), '');                    -- final do tratamento dos dados para conversão

-- Consultas 

-- 1. Calcula a porcentagem de economia por unidade consumidora
SELECT 
    unidade_consumidora,
    (SUM(valor_economia) / SUM(valor_cobrado + valor_economia + valor_fatura_concessionaria)) * 100 AS porcentagem_economia
FROM base_teste
GROUP BY unidade_consumidora;

-- 2. Calcula a média da porcentagem de economia por unidade consumidora
SELECT 
    unidade_consumidora,
    AVG((valor_economia / (valor_cobrado + valor_economia + valor_fatura_concessionaria)) * 100) AS media_porcentagem_economia
FROM base_teste
GROUP BY unidade_consumidora;

-- 3. Calcula o valor total recebido de todas as cobranças com Status "PAGO"
SELECT 
    SUM(valor_cobrado) AS valor_total_recebido
FROM base_teste
WHERE status = 'PAGO';

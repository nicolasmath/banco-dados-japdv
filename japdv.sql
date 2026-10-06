/*
  Aluno: Nicolas Matheus Ribeiro Lopes 
  Professor: Junior Magalhães
  Data: 22/09/2026
  Projeto: Sistema PDV - JAPDV (Controle de Estoque e Vendas)
*/

-- 1. CRIAÇÃO E SELECÇÃO DO BANCO DE DADOS
-- _____________________________________________________
CREATE DATABASE IF NOT EXISTS japdv
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_general_ci;

USE japdv;


-- 2. CRIAÇÃO E POPULAÇÃO DA TABELA: FORNECEDORES
-- _____________________________________________________
CREATE TABLE fornecedores (
    idFornecedor INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL,
    fone VARCHAR(20) NOT NULL,
    email VARCHAR(50)
);

INSERT INTO fornecedores (nome, fone, email) VALUES
    ('Kalunga', '1199999-1111', 'kalunga@kalunga.com.br'),
    ('Tilibra', '1199999-2222', 'vendas@tilibra.com.br');


-- 3. CRIAÇÃO E POPULAÇÃO DA TABELA: PRODUTOS
-- _____________________________________________________
CREATE TABLE produtos (
    idProduto INT AUTO_INCREMENT PRIMARY KEY,
    codigoBarras VARCHAR(20) UNIQUE,
    descricao VARCHAR(100) NOT NULL,
    categoria VARCHAR(50),
    precoCusto DECIMAL(10,2) NOT NULL,
    precoVenda DECIMAL(10,2) NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    estoqueMinimo INT NOT NULL DEFAULT 0,
    idFornecedor INT NOT NULL,
    CONSTRAINT fk_idFornecedor
        FOREIGN KEY (idFornecedor)
        REFERENCES fornecedores(idFornecedor)
);

INSERT INTO produtos (codigoBarras, descricao, categoria, precoCusto, precoVenda, quantidade, estoqueMinimo, idFornecedor) VALUES
    ('789100000001', 'Caneta BIC Azul', 'Canetas', 1.50, 3.00, 50, 10, 1),
    ('789100000002', 'Caneta BIC Vermelha', 'Canetas', 1.60, 3.20, 8, 10, 1),
    ('789100000003', 'Caderno Universitário', 'Cadernos', 18.00, 29.90, 0, 5, 2),
    ('789100000004', 'Régua 30 cm', 'Réguas', 5.00, 10.00, 15, 5, 1);


-- 4 & 5. CRIAÇÃO DAS TABELAS: VENDAS E ITENS_VENDA
-- _____________________________________________________
CREATE TABLE vendas (
    idVenda INT AUTO_INCREMENT PRIMARY KEY,
    dataVenda DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL
);

CREATE TABLE itens_venda (
    idItem INT AUTO_INCREMENT PRIMARY KEY,
    idVenda INT NOT NULL,
    idProduto INT NOT NULL,
    quantidade INT NOT NULL,
    precoUnitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_idVenda
        FOREIGN KEY (idVenda)
        REFERENCES vendas(idVenda)
        ON DELETE CASCADE,
    CONSTRAINT fk_idProduto
        FOREIGN KEY (idProduto)
        REFERENCES produtos(idProduto)
);


-- 6. CADASTRO INICIAL DE VENDAS E ITENS DE VENDA
-- _____________________________________________________
INSERT INTO vendas (total) VALUES
    (16.00),
    (16.00),
    (23.00);

INSERT INTO itens_venda (idVenda, idProduto, quantidade, precoUnitario) VALUES
    (1, 1, 2, 3.00),
    (1, 4, 1, 10.00),
    (2, 2, 5, 3.20),
    (3, 4, 2, 10.00),
    (3, 1, 1, 3.00);


-- Consultas básicas de verificação inicial
SELECT * FROM fornecedores;
SELECT * FROM produtos;
SELECT * FROM vendas;
SELECT * FROM itens_venda;


-- 7. CONSULTAS DO SISTEMA
-- _____________________________________________________

-- 7.1. Produtos com informações dos fornecedores
SELECT 
    produtos.idProduto,
    produtos.descricao,
    produtos.categoria,
    produtos.precoVenda,
    produtos.quantidade,
    produtos.estoqueMinimo,
    fornecedores.nome AS fornecedor
FROM produtos
JOIN fornecedores ON produtos.idFornecedor = fornecedores.idFornecedor
ORDER BY produtos.descricao ASC;

-- 7.2. Produtos que precisam de reposição de estoque
SELECT 
    produtos.idProduto,
    produtos.codigoBarras,
    produtos.descricao,
    produtos.categoria,
    produtos.quantidade,
    produtos.estoqueMinimo,
    fornecedores.nome AS fornecedor,
    (estoqueMinimo - quantidade) AS quantidadeRepor
FROM produtos
JOIN fornecedores ON produtos.idFornecedor = fornecedores.idFornecedor
WHERE quantidade <= estoqueMinimo
ORDER BY produtos.quantidade ASC, produtos.descricao ASC;

-- 7.3. Detalhamento de vendas específicas (Vendas 1, 2 e 3)
SELECT 
    vendas.idVenda,
    DATE_FORMAT(vendas.dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
    produtos.descricao,
    itens_venda.quantidade,
    itens_venda.precoUnitario,
    (itens_venda.quantidade * itens_venda.precoUnitario) AS subtotal
FROM itens_venda
JOIN produtos ON itens_venda.idProduto = produtos.idProduto
JOIN vendas ON itens_venda.idVenda = vendas.idVenda
WHERE vendas.idVenda = 1;

SELECT 
    vendas.idVenda,
    DATE_FORMAT(vendas.dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
    produtos.descricao,
    itens_venda.quantidade,
    itens_venda.precoUnitario,
    (itens_venda.quantidade * itens_venda.precoUnitario) AS subtotal
FROM itens_venda
JOIN produtos ON itens_venda.idProduto = produtos.idProduto
JOIN vendas ON itens_venda.idVenda = vendas.idVenda
WHERE vendas.idVenda = 2;

SELECT 
    vendas.idVenda,
    DATE_FORMAT(vendas.dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
    produtos.descricao,
    itens_venda.quantidade,
    itens_venda.precoUnitario,
    (itens_venda.quantidade * itens_venda.precoUnitario) AS subtotal
FROM itens_venda
JOIN produtos ON itens_venda.idProduto = produtos.idProduto
JOIN vendas ON itens_venda.idVenda = vendas.idVenda
WHERE vendas.idVenda = 3;


-- 8. INDICADORES DO PDV (KPIS)
-- _____________________________________________________

-- 8.1. Quantidade total de registros em produtos
SELECT COUNT(*) AS totalProdutos 
FROM produtos;

-- 8.2. Produtos com estoque abaixo/igual ao mínimo mas com unidades disponíveis
SELECT COUNT(*) AS estoqueAbaixo 
FROM produtos 
WHERE quantidade <= estoqueMinimo AND quantidade > 0;

-- 8.3. Produtos com estoque zerado
SELECT COUNT(*) AS semEstoque 
FROM produtos 
WHERE quantidade = 0;

-- 8.4. Quantidade de vendas realizadas na data atual
SELECT COUNT(*) AS VendasHoje 
FROM vendas 
WHERE DATE(dataVenda) = CURDATE();

-- 8.5. Total de unidades vendidas na data atual
SELECT SUM(quantidade) AS itensVendidosHoje 
FROM itens_venda
JOIN vendas ON itens_venda.idVenda = vendas.idVenda 
WHERE DATE(dataVenda) = CURDATE();

-- 8.6. Faturamento total das vendas na data atual
SELECT COALESCE(SUM(total), 0) AS faturamentoHoje 
FROM vendas 
WHERE DATE(dataVenda) = CURDATE();


-- Inserções adicionais para testes de vendas e produtos
INSERT INTO vendas (total) VALUES
    (3.00),
    (6.40),
    (89.70),
    (40.00),
    (15.00),
    (19.20),
    (209.30);
    
INSERT INTO itens_venda (idVenda, idProduto, quantidade, precoUnitario) VALUES
    (4, 1, 1, 3.00),
    (5, 2, 2, 3.20),
    (6, 3, 3, 29.90),
    (7, 4, 4, 10.00),
    (8, 1, 5, 3.00),
    (9, 2, 6, 3.20),
    (10, 3, 7, 29.90);


-- 9. ÚLTIMAS VENDAS
-- _____________________________________________________
SELECT 
    idVenda,
    DATE_FORMAT(dataVenda, '%d/%m/%Y %H:%i') AS dataVenda,
    total
FROM vendas
ORDER BY idVenda DESC
LIMIT 10;

-- Novos produtos cadastrados
INSERT INTO produtos (codigoBarras, descricao, categoria, precoCusto, precoVenda, quantidade, estoqueMinimo, idFornecedor) VALUES
    ('789100000005', 'Caneta BIC Rosa', 'Canetas', 1.50, 3.00, 19, 10, 1),
    ('789100000006', 'Apontador metal', 'Apontadores', 1.50, 3.50, 24, 16, 2);


-- 10. DESAFIO EXTRA
-- _____________________________________________________

-- Desafio 1: Produto com maior quantidade em estoque
SELECT 
    descricao AS produto,
    quantidade
FROM produtos
ORDER BY quantidade DESC
LIMIT 1;

-- Desafio 2: Produto com maior margem (diferença entre precoVenda e precoCusto)
SELECT 
    idProduto,
    descricao AS produto,
    (precoVenda - precoCusto) AS maiorDiferenca
FROM produtos
ORDER BY maiorDiferenca DESC
LIMIT 1;

-- Desafio 3: Lista de cada produto e total vendido (incluindo os não vendidos)
SELECT 
    produtos.descricao AS produto,
    IFNULL(SUM(itens_venda.quantidade), 0) AS totalVendido
FROM produtos
LEFT JOIN itens_venda ON produtos.idProduto = itens_venda.idProduto
GROUP BY produtos.descricao, produtos.idProduto;

-- Desafio 4: Produto com a maior quantidade total vendida
SELECT 
    produtos.descricao AS produto,
    SUM(itens_venda.quantidade) AS totalVendido
FROM produtos
INNER JOIN itens_venda ON produtos.idProduto = itens_venda.idProduto
GROUP BY produtos.descricao, produtos.idProduto
ORDER BY totalVendido DESC
LIMIT 1;

-- Desafio 5: Cálculo do valor de cada venda a partir dos itens e comparação
SELECT 
    vendas.idVenda,
    SUM(itens_venda.quantidade * itens_venda.precoUnitario) AS totalCalculado,
    vendas.total
FROM vendas
JOIN itens_venda ON vendas.idVenda = itens_venda.idVenda
GROUP BY vendas.idVenda, vendas.total;
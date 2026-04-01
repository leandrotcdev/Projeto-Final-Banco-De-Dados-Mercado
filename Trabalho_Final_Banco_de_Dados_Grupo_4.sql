/*
 * ==================================================================================
 * MODELAGEM E POPULACAO DO BANCO DE DADOS DO MERCADO DINÂMICO
 * Projeto: [Projeto Final - Sistema de Mercado com Preço Dinâmico]
 * Autor: [Leandro Coutinho, Almir Acacio, Nathália Antunes, Matheus França, Emanuelle Castillo]
 * Data: 30/03/2026
 * ==================================================================================
 */

-- ================================================
-- 1 - CRIAR O SCHEMA
-- ================================================

-- Cria o Banco de Dados

create database mercado_dinamico;

-- =================================================
-- 2 - MODELAGEM FÍSICA (DDL) - CRIAÇÃO DAS TABELAS
-- =================================================

-- 1. Tabela Categoria (Tabela Pai) - Agrupa os produtos por tipo. Permite filtros e relatórios por segmento.

create table categoria (
	id_categoria serial primary key,
	nome varchar(100) not null,
	descricao text
);

-- 2. Tabela Produto - Representa cada item comercializado no mercado. Não possui campo de preço diretamente.

create table produto (
	id_produto serial primary key,
	nome varchar(150) not null unique,
	descricao text,
	unidade varchar(6) not null,
	id_categoria int not null,
	constraint fk_produto_categoria foreign key (id_categoria)
		references categoria(id_categoria) on delete restrict
);

-- 3. Tabela Estoque - Controla a quantidade disponível de cada produto no depósito.

create table estoque (
	id_estoque serial primary key,
	id_produto int not null unique,
	quantidade int not null check (quantidade >= 0),
	estoque_minimo int not null default 0,
	ultima_atualizacao timestamp with time zone default current_timestamp,
	constraint fk_estoque_produto foreign key (id_produto)
		references produto(id_produto) on delete restrict
);

-- 4. Tabela Historico_Preco - Registra cada mudança de preço de um produto. Nunca apaga registros anteriores.
-- Esta tabela é a espinha dorsal do Preço Dinâmico.

create table historico_preco (
	id_historico serial primary key,
	id_produto int not null,	-- Produto cujo preço foi alterado
	preco decimal(10, 2) not null,	-- Valor do preço neste momento
	data_inicio timestamp with time zone default current_timestamp,	-- Data e hora em que este preço passou a vigorar
	motivo varchar(100),
	constraint fk_historico_estoque foreign key (id_produto)
		references produto(id_produto) on delete restrict
);

-- 5. Tabela Venda - Cabeçalho de uma transação de venda realizada no caixa.

create table venda (
	id_venda serial primary key,
	data_venda timestamp with time zone default current_timestamp,
	cliente varchar(150),
	total decimal(10, 2) default 0.0
	);

-- 6. Tabela Item_Venda - Detalha cada produto vendido em uma venda. Registra o preço cobrado no momento.

create table item_venda (
	id_item_venda serial primary key,
	id_venda int not null,
	id_produto int not null,
	quantidade decimal(10, 2) not null,
	preco_unitario decimal(10, 2) not null,
	subtotal decimal(10, 2) not null,
		constraint fk_item_venda foreign key (id_venda)
			references venda(id_venda) on delete restrict,	
		constraint fk_item_produto foreign key (id_produto)
			references produto(id_produto) on delete restrict
);

-- ==========================================
-- 3 - INSERÇÕES (DML)
-- ==========================================

-- 1. Categorias

insert into categoria (nome, descricao)
values 
('Laticínios', 'Leites, iogurtes e queijos'),
('Hortifruti', 'Frutas, legumes e verduras frescos'),
('Açougue', 'Cortes bovinos, suínos e aves'),
('Mercearia', 'Grãos, massas e conservas'),
('Bebidas', 'Sumos, águas e refrigerantes'),
('Limpeza', 'Produtos de higiene e limpeza doméstica');

-- 2. Produtos

insert into produto (id_produto, id_categoria, nome, descricao, unidade)
values
(1, 1, 'Leite Integral 1L', 'Caixa longa vida', 'UN'), -- Ajustado para UN (Caixa)
(2, 1, 'Queijo Mussarela', 'Peça fatiada', 'KG'),
(3, 1, 'Iogurte Natural 170g', 'Sem adição de açúcar', 'UN'),
(4, 2, 'Tomate Carmem', 'Origem nacional', 'KG'),
(5, 2, 'Batata Inglesa', 'Lavada', 'KG'),
(6, 2, 'Maçã Fuji', 'Fruta fresca', 'KG'),
(7, 3, 'Picanha Bovina', 'Corte Premium', 'KG'),
(8, 3, 'Peito de Frango', 'Bandeja resfriada', 'KG'),
(9, 3, 'Linguiça Toscana', 'Pacote 1kg', 'UN'),
(10, 4, 'Arroz Branco 5kg', 'Tipo 1', 'UN'),
(11, 4, 'Feijão Carioca 1kg', 'Grãos selecionados', 'UN'),
(12, 4, 'Macarrão Esparguete 500g', 'Massa com ovos', 'UN'),
(13, 5, 'Refrigerante Cola 2L', 'Garrafa PET', 'UN'),
(14, 5, 'Sumo de Laranja 1L', '100% Integral', 'UN'), -- Ajustado para UN (Garrafa/Caixa)
(15, 5, 'Água Mineral 1.5L', 'Sem gás', 'UN'),
(16, 6, 'Sabão em Pó 1kg', 'Ação profunda', 'UN'),
(17, 6, 'Detergente Líquido 500ml', 'Neutro', 'UN'),
(18, 6, 'Amaciante 2L', 'Fragrância floral', 'UN');

select * from categoria; -- Testando e visualizando tudo dentro da tabela categoria

select * from produto; -- Testando e visualizando tudo dentro da tabela produto

-- 3. Estoque

insert into estoque (id_produto, quantidade, estoque_minimo)
values
(1, 150, 50), (2, 40, 15), (3, 80, 20),
(4, 5, 15),   -- ALERTA: estoque crítico (<10)
(5, 100, 30), (6, 60, 20),
(7, 8, 10),   -- ALERTA: estoque crítico (<10)
(8, 30, 15),  (9, 45, 15),
(10, 120, 50),(11, 80, 30),
(12, 6, 20),  -- ALERTA: estoque crítico (<10)
(13, 200, 50),(14, 40, 15), (15, 150, 40),
(16, 50, 20), (17, 100, 30),(18, 35, 15);

-- 4. Preço Base 

insert into historico_preco (id_produto, preco, data_inicio, motivo)
values
(1, 4.50, '2026-03-01 08:00:00', 'Preço Base'),
(2, 45.90, '2026-03-01 08:00:00', 'Preço Base'),
(3, 2.50, '2026-03-01 08:00:00', 'Preço Base'),
(4, 8.90, '2026-03-01 08:00:00', 'Preço Base'),
(5, 6.50, '2026-03-01 08:00:00', 'Preço Base'),
(6, 9.90, '2026-03-01 08:00:00', 'Preço Base'),
(7, 69.90, '2026-03-01 08:00:00', 'Preço Base'),
(8, 19.90, '2026-03-01 08:00:00', 'Preço Base'),
(9, 22.50, '2026-03-01 08:00:00', 'Preço Base'),
(10, 25.90, '2026-03-01 08:00:00', 'Preço Base'),
(11, 8.50, '2026-03-01 08:00:00', 'Preço Base'),
(12, 4.50, '2026-03-01 08:00:00', 'Preço Base'),
(13, 9.49, '2026-03-01 08:00:00', 'Preço Base'), 
(14, 12.90, '2026-03-01 08:00:00', 'Preço Base'),
(15, 3.50, '2026-03-01 08:00:00', 'Preço Base'),
(16, 14.90, '2026-03-01 08:00:00', 'Preço Base'),
(17, 2.50, '2026-03-01 08:00:00', 'Preço Base'),
(18, 18.90, '2026-03-01 08:00:00', 'Preço Base');

-- 5. Preço Atualizado (Oscilação Dinâmica)

insert into historico_preco (id_produto, preco, data_inicio, motivo)
values
(1, 5.10, '2026-03-15 10:00:00', 'Inflação Laticínios'),
(7, 85.00, '2026-03-15 10:00:00', 'Alta Demanda Fim de Semana'),
(10, 23.90, '2026-03-15 10:00:00', 'Promoção Cesta Básica'),
(13, 10.99, '2026-03-15 10:00:00', 'Alta Demanda - Verão'), 
(16, 16.50, '2026-03-15 10:00:00', 'Ajuste Fornecedor');

-- 6. Vendas antes do reajuste de preços (Pegam o Preço Base)

insert into venda (id_venda, data_venda, cliente, total)
values
(1, '2026-03-10 09:30:00', 'Maria Silva', 143.21),
(2, '2026-03-11 14:15:00', 'João Souza', 65.89),
(3, '2026-03-12 11:00:00', NULL, 85.49),
(4, '2026-03-13 18:45:00', 'Ana Costa', 70.33),
(5, '2026-03-14 20:10:00', 'Carlos Lima', 44.52);

-- 7. Vendas após o reajuste de preços (Pegam o Preço Atualizado)

insert into venda (id_venda, data_venda, cliente, total)
values
(6, '2026-03-20 08:30:00', 'Fernanda Alves', 78.40),
(7, '2026-03-21 13:20:00', 'Roberto Dias', 213.68), 
(8, '2026-03-22 16:40:00', NULL, 39.24),
(9, '2026-03-23 19:15:00', 'Juliana Rios', 60.84),
(10, '2026-03-25 21:05:00', 'Marcos Gomes', 47.65);

-- 8. Itens Vendas

insert into item_venda (id_venda, id_produto, quantidade, preco_unitario, subtotal)
values
(1, 7, 1.500, 69.90, 104.85),
(1, 13, 2, 9.49, 18.98),
(1, 15, 2, 3.50, 7.00),
(1, 6, 1.250, 9.90, 12.38),

(2, 10, 1, 25.90, 25.90),
(2, 11, 2, 8.50, 17.00),
(2, 12, 3, 4.50, 13.50),
(2, 13, 1, 9.49, 9.49),

(3, 1, 12, 4.50, 54.00),
(3, 2, 0.350, 45.90, 16.07),
(3, 17, 3, 2.50, 7.50),
(3, 6, 0.800, 9.90, 7.92),

(4, 16, 2, 14.90, 29.80),
(4, 18, 1, 18.90, 18.90),
(4, 5, 2.300, 6.50, 14.95),
(4, 4, 0.750, 8.90, 6.68),

(5, 8, 1.200, 19.90, 23.88),
(5, 6, 1.100, 9.90, 10.89),
(5, 5, 1.500, 6.50, 9.75),

-- Venda 6 (2 itens - PREÇOS NOVOS)
(6, 1, 6, 5.10, 30.60),       -- 6 Leites com preço atualizado
(6, 10, 2, 23.90, 47.80),     -- 2 Arroz com preço de promoção

-- Venda 7 (3 itens - PREÇOS NOVOS)
(7, 7, 1.800, 85.00, 153.00), -- 1.8kg de Picanha (Peça inteira realista)
(7, 13, 2, 10.99, 21.98),     -- 2 Refris (Preço novo)
(7, 14, 3, 12.90, 38.70),     -- 3 Caixas de Sumo

-- Venda 8 (3 itens - PREÇOS NOVOS)
(8, 16, 1, 16.50, 16.50),     -- 1 Sabão em Pó com preço atualizado
(8, 17, 5, 2.50, 12.50),      -- 5 Detergentes
(8, 4, 1.150, 8.90, 10.24),   -- 1.15kg de Tomate

-- Venda 9 (2 itens - PREÇOS NOVOS)
(9, 9, 2, 22.50, 45.00),      -- 2 Pacotes de Linguiça
(9, 6, 1.600, 9.90, 15.84),   -- 1.6kg de Maçã

-- Venda 10 (3 itens - PREÇOS NOVOS)
(10, 3, 8, 2.50, 20.00),      -- 8 Iogurtes
(10, 15, 4, 3.50, 14.00),     -- 4 Águas
(10, 5, 2.100, 6.50, 13.65);  -- 2.1kg de Batata

select * from estoque;
select * from historico_preco;
select * from venda;
select *from item_venda;

-- Aqui decidimos trocar os dados das tabelas para criar uma base de dados melhor e mais realista.
-- Demos um reset para esvaziar as tabelas e colocar novos dados.

truncate table
	categoria,
    produto,
    estoque,
    historico_preco,
    venda,
    item_venda
restart identity cascade;

-- ============================================================================
-- 4 - CONSULTAS SQL (DQL)
-- ============================================================================

-- C1: Lista de Produtos com suas Respectivas Categorias
-- Descrição: Retorna o catálogo de produtos e suas unidades de medida, vinculando cada um à sua categoria.
-- Utiliza left join para garantir que produtos apareçam mesmo se a categoria for nula, ordenado por categoria.

select 
    c.nome as nome_categoria,
    p.nome as nome_produto,
    p.unidade as unidade_medida
from produto p
left join categoria c on p.id_categoria = c.id_categoria
order by c.nome asc, p.nome asc;

-- C2: Estoque Atual de Todos os Produtos
-- Descrição: Mostra a situação física do depósito, comparando a quantidade atual com o estoque mínimo.
-- Ordenado de forma crescente pela quantidade, destacando os itens que estão acabando primeiro.

select 
    p.nome as nome_produto,
    e.quantidade as quantidade_atual_estoque,
    e.estoque_minimo as limite_minimo_seguranca
from produto p
inner join estoque e on p.id_produto = e.id_produto
order by e.quantidade asc;

-- C3: Histórico Completo de Preços
-- Descrição: Exibe a linha do tempo das flutuações de valor de cada produto.
-- Ordenado alfabeticamente pelo produto e, em seguida, da alteração de preço mais recente para a mais antiga.

select 
    p.nome as nome_produto,
    hp.preco as valor_historico,
    hp.data_inicio as data_da_alteracao,
    hp.motivo as motivo_mudanca
from historico_preco hp
inner join produto p ON hp.id_produto = p.id_produto
order by p.nome asc, hp.data_inicio desc;

-- C4: Preço Atual de Cada Produto (O Catálogo Vigente)
-- Descrição: Busca o valor de prateleira que está valendo hoje para cada produto.
-- Utiliza uma subconsulta (Subquery) para filtrar rigorosamente o registro com a 'data_inicio' mais recente.

select 
    p.nome as nome_produto,
    hp.preco as preco_vigente_atual,
    hp.data_inicio as vigencia_desde
from produto p
inner join historico_preco hp on p.id_produto = hp.id_produto
where hp.data_inicio = (
	select MAX(data_inicio) 
    from historico_preco 
    where id_produto = p.id_produto
)
order by p.nome asc;

-- C5: Resumo Analítico de Vendas por Período
-- Descrição: Apresenta o cabeçalho das vendas consolidadas, contando quantos itens diferentes foram comprados.
-- Utiliza group by e a função COUNT() para sumarizar os itens, ordenando da venda mais recente para a mais antiga.

select 
	v.data_venda as data_da_transacao,
    v.cliente as nome_do_cliente,
    COUNT(iv.id_produto) as total_itens_diferentes,
    v.total as valor_total_faturado
from venda v
inner join item_venda iv on v.id_venda = iv.id_venda
group by v.id_venda, v.data_venda, v.cliente, v.total
order by v.data_venda desc;

-- C6: Ranking dos Produtos Mais Vendidos (Top 5)
-- Descrição: Calcula o volume total de unidades vendidas de cada produto em todo o histórico do mercado.
-- Utiliza SUM() nas quantidades e limit 5 para construir o ranking dos campeões de saída.

select 
	p.nome as nome_produto,
    c.nome as nome_categoria,
    SUM(iv.quantidade) as volume_total_vendido
from item_venda iv
inner join produto p on iv.id_produto = p.id_produto
inner join categoria c on p.id_categoria = c.id_categoria
group by p.id_produto, p.nome, c.nome
order by volume_total_vendido desc
limit 5;

-- C7: Relatório de Produtos com Estoque Crítico (Abaixo do mínimo)
-- Descrição: Cruza as tabelas para alertar compras. Mostra apenas produtos onde a quantidade física é menor que o estoque mínimo exigido.
-- Traz acoplado o preço vigente atual usando subconsulta para auxiliar o setor de compras.

select 
    p.nome as nome_produto,
    e.quantidade as estoque_atual_critico,
    e.estoque_minimo as limite_exigido,
    hp.preco as preco_de_custo_atual
from produto p
inner join estoque e on p.id_produto = e.id_produto
inner join historico_preco hp on p.id_produto = hp.id_produto
where e.quantidade < e.estoque_minimo
	and hp.data_inicio = (
		select MAX(data_inicio) 
      	from historico_preco 
    	where id_produto = p.id_produto
  	)
order by e.quantidade asc;


-- C8: Faturamento Total Agrupado por Categoria
-- Descrição: Relatório financeiro de alto nível. Mostra qual setor do mercado gera mais dinheiro.
-- Utiliza SUM() para somar a receita financeira e AVG() para calcular o ticket médio dos itens faturados no setor.

select 
    c.nome as setor_categoria,
    SUM(iv.quantidade) as total_unidades_comercializadas,
    SUM(iv.subtotal) as faturamento_financeiro_total,
    ROUND(AVG(iv.preco_unitario), 2) as preco_medio_cobrado
from item_venda iv
inner join produto p on iv.id_produto = p.id_produto
inner join categoria c on p.id_categoria = c.id_categoria
group by c.id_categoria, c.nome
order by faturamento_financeiro_total desc;

-- ============================================================================
-- 5 - Desafio Final - Regra de Negócio - Mercado Dinâmico
-- ============================================================================

-- 1. Consulta select que identifica os produtos com estoque < 10.
-- Descrição: Identifica os produtos em situação de escassez (estoque crítico).
-- Cruza as tabelas de produto, estoque e a subconsulta de preço para trazer o valor de venda atual.

select 
	p.nome as nome_produto,
    e.quantidade as quantidade_em_estoque,
    hp.preco as preco_atual_vigente
from produto p
inner join estoque e on p.id_produto = e.id_produto
inner join historico_preco hp on p.id_produto = hp.id_produto
where e.quantidade < 10
	and hp.data_inicio = (
    	select max(data_inicio) 
    	from historico_preco 
    	where id_produto = p.id_produto
  	)
order by e.quantidade asc;

-- 2. Consulta select mostrando o novo preço calculado (antes de inserir).
-- Descrição: simula um aumento automático de 15% devido à baixa oferta (escassez de estoque).
-- Utiliza a função round para garantir que o valor financeiro fique formatado com duas casas decimais.

select 
    p.nome as nome_produto,
    e.quantidade as quantidade_em_estoque,
    hp.preco as preco_antigo,
    round(hp.preco * 1.15, 2) as novo_preco_simulado
from produto p
inner join estoque e on p.id_produto = e.id_produto
inner join historico_preco hp on p.id_produto = hp.id_produto
where e.quantidade < 10
	and hp.data_inicio = (
    	select max(data_inicio) 
      	from historico_preco 
      	where id_produto = p.id_produto
);

-- 3. Comandos insert no historico_preco para os produtos afetados.
-- Descrição: Aplica a regra de negócio inserindo os novos valores no histórico em lote.
-- O comando 'insert into ... select' automatiza o processo sem necessidade de inserir id por id manualmente.

insert into historico_preco (id_produto, preco, data_inicio, motivo)
select 
	p.id_produto,
    round(hp.preco * 1.15, 2),
    current_timestamp,
    'ajuste automático: escassez de estoque (< 10 unidades)'
from produto p
inner join estoque e on p.id_produto = e.id_produto
inner join historico_preco hp on p.id_produto = hp.id_produto
where e.quantidade < 10
	and hp.data_inicio = (
      	select max(data_inicio) 
      	from historico_preco 
      	where id_produto = p.id_produto
);

select * from historico_preco;

-- 4. Consultas de validação executadas após as inserções.
-- Validação C4: Preço atual de cada produto.
-- Descrição: Recalcula o catálogo atualizado para mostrar os produtos afetados
-- (com estoque < 10) agora exibem o novo preço reajustado, enquanto os restantes mantêm o preço antigo.

select 
	p.nome as nome_produto,
    hp.preco as preco_vigente_atual,
    hp.data_inicio as vigencia_desde
from produto p
inner join historico_preco hp on p.id_produto = hp.id_produto
where hp.data_inicio = (
    select max(data_inicio) 
    from historico_preco 
    where id_produto = p.id_produto
)
order by p.nome asc;

-- Validação C7: Relatório de produtos com estoque crítico.
-- Descrição: Valida especificamente o alerta do setor de compras. Os produtos com
-- estoque abaixo do mínimo devem agora aparecer atrelados à nova etiqueta de preço.

select 
	p.nome as nome_produto,
    e.quantidade as estoque_atual_critico,
    e.estoque_minimo as limite_exigido,
    hp.preco as preco_de_custo_atualizado
from produto p
inner join estoque e on p.id_produto = e.id_produto
inner join historico_preco hp on p.id_produto = hp.id_produto
where e.quantidade < e.estoque_minimo
	and hp.data_inicio = (
      	select max(data_inicio) 
      	from historico_preco 
		where id_produto = p.id_produto
  	)
order by e.quantidade asc;
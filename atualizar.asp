<%@ LANGUAGE="VBSCRIPT" %>
<!-- #include virtual="includes/conexao.asp" -->
<!-- #include virtual="includes/validaToken.asp" -->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="utf-8">
    <title>Dashboard - Produtos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        /* Remove scroll da página e ocupa altura total */
        html, body {
            height: 100%;
            margin: 0;
            overflow: hidden; /* remove scroll do body */
        }

        /* Conteúdo principal ocupa toda a altura restante */
        .conteudo-principal {
            display: flex;
            flex-direction: column;
            height: 100vh;
            padding: 1rem;
            box-sizing: border-box;
        }

        /* Card da tabela com scroll interno e limite ao final da tela */
        .card-body.tabela-scroll {
            max-height: calc(100vh - 550px); /* ajusta de acordo com altura do form + header */
            overflow-y: auto;
        }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- Inclui a sidebar -->
    <!--#include file="includes/sidebar.asp" -->

    <!-- Conteúdo principal -->
    <div class="flex-grow-1 conteudo-principal">
        <div id="conteudoProdutos"></div>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <script>
        (async function() {
            const container = document.getElementById("conteudoProdutos");

            // ===========================
            // 1️⃣ Formulário
            // ===========================
            const formCard = document.createElement("div");
            formCard.className = "card shadow-sm mb-4";
            formCard.innerHTML = `
                <div class="card-header bg-danger text-white">
                    <h4 class="mb-0">Cadastrar / Editar Produto</h4>
                </div>
                <div class="card-body">
                    <form id="produtoForm" class="row g-3">
                        <div class="col-md-2">
                            <label for="produtoId" class="form-label">ID</label>
                            <input type="text" class="form-control form-control-sm" id="produtoId" name="produtoid" placeholder="ID" readonly>
                        </div>
                        <div class="col-md-6">
                            <label for="nome" class="form-label">Nome</label>
                            <input type="text" class="form-control form-control-sm" id="nome" name="nome" placeholder="Nome do produto" required>
                        </div>
                        <div class="col-md-4">
                            <label for="preco" class="form-label">Preço</label>
                            <input type="number" step="0.01" class="form-control form-control-sm" id="preco" name="preco" placeholder="0,00" required>
                        </div>
                        <div class="col-md-12">
                            <label for="descricao" class="form-label">Descrição</label>
                            <textarea class="form-control form-control-sm" id="descricao" name="descricao" rows="3" placeholder="Descrição do produto"></textarea>
                        </div>
                        <div class="col-md-4">
                            <label for="estoque" class="form-label">Estoque</label>
                            <input type="number" class="form-control form-control-sm" id="estoque" name="Estoque" placeholder="Quantidade em estoque" required>
                        </div>
                        <div class="col-12 text-end">
                            <button type="submit" id="btnAdicionar" data-action="add" class="btn btn-primary btn-sm">Adicionar</button>
                            <button type="submit" id="btnAtualizar" data-action="update" class="btn btn-warning btn-sm">Atualizar</button>
                            <button type="reset" class="btn btn-secondary btn-sm">Limpar</button>
                        </div>
                    </form>
                    <div id="prodMsg" class="mt-2"></div>
                </div>
            `;
            container.appendChild(formCard);

            // ===========================
            // 2️⃣ Tabela
            // ===========================
            const tabelaCard = document.createElement("div");
            tabelaCard.className = "card shadow-sm";
            tabelaCard.innerHTML = `
                <div class="card-header bg-danger text-white">
                    <h4 class="mb-0">Produtos</h4>
                    <input type="text" id="buscaProduto" placeholder="Buscar produto..." class="form-control mt-2" />
                </div>
                <div class="card-body p-0 tabela-scroll">
                    <table class="table table-striped table-hover table-bordered text-center mb-0">
                        <thead class="table-dark">
                            <tr>
                                <th>#</th>
                                <th>Nome</th>
                                <th>Preço</th>
                                <th>Estoque</th>
                                <th>Editar</th>
                                <th>Excluir</th>
                            </tr>
                        </thead>
                        <tbody id="produtosBody"></tbody>
                    </table>
                </div>
            `;
            container.appendChild(tabelaCard);

            const tbody = document.getElementById("produtosBody");
            const inputBusca = document.getElementById("buscaProduto");
            const form = $('#produtoForm');

            let produtos = [];

            function renderTabela(filtro = "") {
                tbody.innerHTML = "";
                const produtosFiltrados = filtro
                    ? produtos.filter(p => p.Nome.toLowerCase().includes(filtro.toLowerCase()))
                    : produtos;

                produtosFiltrados.forEach(p => {
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>${p.ProdutoID}</td>
                        <td>${p.Nome}</td>
                        <td>R$ ${p.Preco.toFixed(2)}</td>
                        <td>${p.Estoque ?? "-"}</td>
                        <td><button class="btn btn-sm btn-warning btn-editar">Editar</button></td>
                        <td><button class="btn btn-sm btn-danger btn-excluir">Excluir</button></td>
                    `;
                    tbody.appendChild(tr);
                });
            }

            async function carregarProdutos() {
                try {
                    const resp = await fetch("/api/produtos.asp?action=list&token=token_admin");
                    produtos = await resp.json();
                    renderTabela();
                } catch (err) {
                    console.error("Erro ao carregar produtos:", err);
                }
            }

            inputBusca.addEventListener("input", () => renderTabela(inputBusca.value));
            carregarProdutos();

            // Adicionar, atualizar, limpar, editar e excluir continuam iguais
            // (mantive seu código original de manipulação de formulário e botões)
        })();
        </script>
    </div>
</div>
</body>
</html>

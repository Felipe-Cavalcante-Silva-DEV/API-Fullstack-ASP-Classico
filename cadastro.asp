<%@ LANGUAGE="VBSCRIPT" %>

<!-- #include virtual="includes/conexao.inc" -->
<!-- #include virtual="includes/validaTokenApi.inc" -->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="utf-8">
    <title>Dashboard - Produtos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
    html, body {
        height: 100%;
        margin: 0;
        overflow: hidden;
    }

    /* Scroll responsivo para a tabela externa */
    .scroll-tabela-externos {
        max-height: calc(100vh - 520px); /* Ajuste: altura da tela - altura do form e headers */
        overflow-y: auto;
        padding-bottom: 1rem;
        box-sizing: border-box;
    }

    @media (max-width: 767px) {
        .scroll-tabela-externos {
            max-height: calc(100vh - 620px); /* Ajuste para telas pequenas */
        }
    }
  </style>
</head>
<body>
<div class="d-flex">
    <!-- Inclui a sidebar -->
    <!--#include file="includes/sidebar.inc" -->

    <!-- Conteúdo principal -->
    <div class="flex-grow-1 p-4">
        <!-- Container onde formulário e tabela serão renderizados -->
        <div id="conteudoProdutos" style="display: flex; flex-direction: column; height: 100vh;">

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

        <script>
        const API_CONNECTION = "<%= API_CONNECTION %>";
        (async function() {
            const container = document.getElementById("conteudoProdutos");

            // ============================
            // 1️⃣ Criação do formulário
            // ============================
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

            // ============================
            // 2️⃣ Criação da tabela
            // ============================
            const tabelaCard = document.createElement("div");
            tabelaCard.className = "card shadow-sm";
            tabelaCard.innerHTML = `
                <div class="card-header bg-danger text-white">
                    <h4 class="mb-0">Produtos</h4>
                    <input type="text" id="buscaProduto" placeholder="Buscar produto..." class="form-control mt-2" />
                </div>
                <div class="card-body p-0">
                    <div class="scroll-tabela" style="max-height: 400px; overflow-y: auto;">
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
                     </div>
                </table>
             </div>
            `;
            container.appendChild(tabelaCard);

            const tbody = document.getElementById("produtosBody");
            const inputBusca = document.getElementById("buscaProduto");
            const form = $('#produtoForm');

            let produtos = [];

            // ============================
            // 3️⃣ Função para renderizar tabela
            // ============================
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

            // ============================
            // 4️⃣ Carregar produtos da API
            // ============================
            async function carregarProdutos() {
                try {
                    const resp = await fetch(API_CONNECTION+ "/api/produtos.asp?action=list&token=token_admin");
                    produtos = await resp.json();
                    renderTabela();
                } catch (err) {
                    console.error("Erro ao carregar produtos:", err);
                }
            }

            inputBusca.addEventListener("input", () => renderTabela(inputBusca.value));
            carregarProdutos();

            // ============================
            // 5️⃣ Botões Adicionar / Atualizar / Limpar
            // ============================
            const btnAdicionar = $('#btnAdicionar');
            const btnAtualizar = $('#btnAtualizar');
            const btnLimpar = $('button[type="reset"]');

            btnAtualizar.prop('disabled', true);

            // Limpar formulário
            btnLimpar.on('click', function() {
                btnAdicionar.prop('disabled', false);
                btnAtualizar.prop('disabled', true);
                $('#prodMsg').html('');
            });

            // ============================
            // Botão Editar
            // ============================
            $(document).on('click', '.btn-editar', function() {
                const linha = $(this).closest('tr');
                const id = linha.find('td:first').text();
                const produto = produtos.find(p => p.ProdutoID == id);

                if (produto) {
                    $('#produtoId').val(produto.ProdutoID);
                    $('#nome').val(produto.Nome);
                    $('#preco').val(produto.Preco);
                    $('#descricao').val(produto.Descricao ?? "");
                    $('#estoque').val(produto.Estoque ?? 0);

                    btnAdicionar.prop('disabled', true);
                    btnAtualizar.prop('disabled', false);
                }
            });

            // ============================
            // Função para excluir produto
            // ============================
            function excluirProduto(produtoId) {
                if (!confirm("Deseja realmente excluir este produto?")) return;

                $.ajax({
                    url: API_CONNECTION + "api/produtos.asp?action=delete&token=token_admin",
                    type: "POST",
                    contentType: "application/json",
                    data: JSON.stringify({ produtoId: produtoId }),
                    success: function(res) {
                        console.log("Produto deletado:", res);
                        alert(res.message || "Produto deletado com sucesso!");
                        carregarProdutos();
                    },
                    error: function(xhr) {
                        console.error("Erro ao deletar produto:", xhr);
                        alert("Erro ao deletar produto: " + xhr.responseText);
                    }
                });
            }

            $(document).on('click', '.btn-excluir', function() {
                const linha = $(this).closest('tr');
                const id = linha.find('td:first').text();
                excluirProduto(parseInt(id));
            });

            // ============================
            // Submissão do formulário
            // ============================
            let acaoSelecionada = null;

            $('#produtoForm button[type="submit"]').on('click', function () {
                acaoSelecionada = $(this).data('action'); // "add" ou "update"
            });

            form.submit(async function(e) {
                e.preventDefault();

                const data = {
                    nome: $('#nome').val(),
                    descricao: $('#descricao').val(),
                    preco: parseFloat($('#preco').val().replace(",", ".")),
                    estoque: parseInt($('#estoque').val())
                };

                if (acaoSelecionada === 'add') {
                    try {
                        const res = await $.ajax({
                            url: API_CONNECTION + 'api/produtos.asp?action=add&token=token_admin',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify(data)
                        });
                        $('#prodMsg').html('<div class="alert alert-success">' + (res.message || 'Produto criado!') + ' ID: ' + (res.NovoProdutoID || '') + '</div>');
                        form[0].reset();
                        carregarProdutos();
                    } catch (err) {
                        console.error("Erro ao cadastrar produto:", err);
                        $('#prodMsg').html('<div class="alert alert-danger">Erro ao cadastrar produto</div>');
                    }
                } else if (acaoSelecionada === 'update') {
                    data.produtoId = parseInt($('#produtoId').val());
                    try {
                        const res = await $.ajax({
                            url: API_CONNECTION + 'api/produtos.asp?action=update&token=token_admin',
                            type: 'POST',
                            contentType: 'application/json',
                            data: JSON.stringify(data)
                        });
                        $('#prodMsg').html('<div class="alert alert-success">' + (res.message || 'Produto atualizado!') + '</div>');
                        form[0].reset();
                        btnAdicionar.prop('disabled', false);
                        btnAtualizar.prop('disabled', true);
                        carregarProdutos();
                    } catch (err) {
                        console.error("Erro ao atualizar produto:", err);
                        $('#prodMsg').html('<div class="alert alert-danger">Erro ao atualizar produto</div>');
                    }
                }

                acaoSelecionada = null;
            });

        })();
        </script>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

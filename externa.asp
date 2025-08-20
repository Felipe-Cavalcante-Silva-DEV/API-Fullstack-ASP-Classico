<%@ LANGUAGE="VBSCRIPT" %>
<!-- #include virtual="includes/conexao.inc" -->
<!-- #include virtual="includes/validaToken.inc" -->

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
  <!-- Sidebar -->
  <!--#include file="includes/sidebar.inc" -->

  <!-- Conteúdo principal -->
  <div class="flex-grow-1 p-4">
    <div id="conteudoProdutos"></div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
(async function() {
    const container = document.getElementById("conteudoProdutos");

    // ============================
    // 1️⃣ Formulário
    // ============================
    const formCard = document.createElement("div");
    formCard.className = "card shadow-sm card-tabela-externos";
    formCard.innerHTML = `
        <div class="card-header bg-danger text-white">
            <h4 class="mb-0">Importar da FakeStoreApi</h4>
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
                </div>
            </form>
            <div id="prodMsg" class="mt-2"></div>
        </div>
    `;
    container.appendChild(formCard);

    // ============================
    // 2️⃣ Tabela produtos externos
    // ============================
    const tabelaCard = document.createElement("div");
    tabelaCard.className = "card shadow-sm";
    tabelaCard.innerHTML = `
        <div class="card-header bg-danger text-white">
            <h4 class="mb-0">Produtos Fake Store API</h4>
            <input type="text" id="buscaProdutoExterno" placeholder="Buscar produto..." class="form-control mt-2" />
        </div>
        <div class="card-body p-0 scroll-tabela-externos">
            <table class="table table-striped table-hover table-bordered text-center mb-0">
                <thead class="table-dark">
                    <tr>
                        <th>#</th>
                        <th>Nome</th>
                        <th>Preço</th>
                        <th>Estoque</th>
                        <th>Importar</th>
                    </tr>
                </thead>
                <tbody id="produtosExternosBody"></tbody>
            </table>
        </div>
    `;
    container.appendChild(tabelaCard);

    const tbodyExternos = document.getElementById("produtosExternosBody");
    const inputBusca = document.getElementById("buscaProdutoExterno");
    let produtosExternos = [];

    // ============================
    // 3️⃣ Buscar produtos Fake Store API
    // ============================
    async function carregarProdutosExternos() {
        try {
            const resp = await fetch("https://fakestoreapi.com/products");
            produtosExternos = await resp.json();
            renderTabelaExternos();
        } catch(err) {
            console.error("Erro ao carregar produtos externos:", err);
        }
    }

    function renderTabelaExternos(filtro = "") {
        tbodyExternos.innerHTML = "";
        const filtrados = filtro 
            ? produtosExternos.filter(p => p.title.toLowerCase().includes(filtro.toLowerCase()))
            : produtosExternos;

        filtrados.forEach(p => {
            const estoqueAleatorio = Math.floor(Math.random() * 20);
            p.estoque = estoqueAleatorio;

            const tr = document.createElement("tr");
            tr.innerHTML = `
                <td>${p.id}</td>
                <td>${p.title}</td>
                <td>R$ ${p.price.toFixed(2)}</td>
                <td>${estoqueAleatorio}</td>
                <td><button class="btn btn-sm btn-info btn-importar">Importar</button></td>
            `;
            tbodyExternos.appendChild(tr);
        });
    }

    inputBusca.addEventListener("input", () => renderTabelaExternos(inputBusca.value));
    carregarProdutosExternos();

    // ============================
    // 4️⃣ Importar produto externo para o form
    // ============================
    $(document).on('click', '.btn-importar', function() {
        const linha = $(this).closest('tr');
        const id = parseInt(linha.find('td:first').text());
        const produto = produtosExternos.find(p => p.id === id);

        if(produto) {
            $('#produtoId').val('');
            $('#nome').val(produto.title);
            $('#preco').val(produto.price);
            $('#descricao').val(produto.description);
            $('#estoque').val(produto.estoque);

            $('#btnAdicionar').prop('disabled', false);
            $('#prodMsg').html('');
        }
    });

    // ============================
    // 5️⃣ Submissão do form (Adicionar / Atualizar)
    // ============================
    let acaoSelecionada = null;
    $('#produtoForm button[type="submit"]').on('click', function() {
        acaoSelecionada = $(this).data('action');
    });

    $('#produtoForm').submit(async function(e) {
        e.preventDefault();
        const data = {
            nome: $('#nome').val(),
            descricao: $('#descricao').val(),
            preco: parseFloat($('#preco').val()),
            estoque: parseInt($('#estoque').val())
        };

        if(acaoSelecionada === 'add') {
            try {
                await $.ajax({
                    url: `/api/produtos.asp?action=add&token=token_admin`,
                    type: 'POST',
                    contentType: 'application/json',
                    data: JSON.stringify(data)
                });
                $('#prodMsg').html('<div class="alert alert-success">Produto adicionado com sucesso!</div>');
                $(this)[0].reset();
            } catch(err) {
                console.error(err);
                $('#prodMsg').html('<div class="alert alert-danger">Erro ao adicionar produto</div>');
            }
        }

        acaoSelecionada = null;
    });

})();
</script>

</body>
</html>

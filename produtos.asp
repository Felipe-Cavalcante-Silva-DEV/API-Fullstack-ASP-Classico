<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="includes/conexao.inc" -->
<!--#include virtual="includes/validaToken.inc" -->




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
        }

        .conteudo-produtos {
            flex-grow: 1;
            padding: 1rem;
            height: 100vh;
            overflow: hidden;
        }

        /* Container do scroll com padding interno */
        .scroll-tabela {
            max-height: calc(100vh - 100px);
            overflow-y: auto;
        }

        .scroll-tabela-inner {
            padding-bottom: 1rem; /* Espaço final da tabela */
        }

        /* Responsividade */
        @media (max-width: 767px) {
            .col-md-6 {
                flex: 0 0 100%;
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
<div class="d-flex">
    <!-- Sidebar -->
    <!--#include file="includes/sidebar.inc" -->


    <div class="conteudo-produtos">
        <div id="conteudoProdutos"></div>

        <script>
        (async function() {
            const container = document.getElementById("conteudoProdutos");

            let produtos = []; // armazena produtos em memória

            const itensPorPagina = 18;
            let paginaAtual = 1;

            const renderTabela = (filtro = "") => {
                const tbody = document.getElementById("produtosBody");
                tbody.innerHTML = "";

                const produtosFiltrados = filtro
                    ? produtos.filter(p => p.Nome.toLowerCase().includes(filtro.toLowerCase()))
                    : produtos;

                const inicio = (paginaAtual - 1) * itensPorPagina;
                const fim = inicio + itensPorPagina;
                const paginaProdutos = produtosFiltrados.slice(inicio, fim);

                paginaProdutos.forEach(p => {
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>${p.ProdutoID}</td>
                        <td>${p.Nome}</td>
                        <td>R$ ${p.Preco.toFixed(2)}</td>
                        <td>${p.Estoque ?? "-"}</td>
                    `;
                    tbody.appendChild(tr);
                });

                // Atualiza botões de paginação
                renderPaginacao(produtosFiltrados.length);
            };

            const renderPaginacao = (totalItens) => {
                const containerPaginacao = document.getElementById("paginacao");
                if (!containerPaginacao) return;

                containerPaginacao.innerHTML = "";

                const totalPaginas = Math.ceil(totalItens / itensPorPagina);

                for (let i = 1; i <= totalPaginas; i++) {
                    const btn = document.createElement("button");
                    btn.textContent = i;
                    btn.className = i === paginaAtual ? "btn btn-primary m-1" : "btn btn-outline-primary m-1";
                    btn.addEventListener("click", () => {
                        paginaAtual = i;
                        renderTabela(document.getElementById("buscaProduto").value);
                    });
                    containerPaginacao.appendChild(btn);
                }
            };
            const carregarProdutos = async () => {
                try {
                    const resp = await fetch(API_CONNECTION + "api/produtos.asp?action=list&token=token_admin");
                    produtos = await resp.json();

                    container.innerHTML = `
                        <div class="card shadow-sm">
                            <div class="card-header bg-danger text-white">
                                <h4 class="mb-0">Produtos</h4>
                                <input type="text" id="buscaProduto" placeholder="Buscar produto..." class="form-control mt-2" />
                            </div>
                            <div class="card-body p-0">
                            <div class="scroll-tabela" style="max-height: calc(100vh - 120px); overflow-y: auto; padding-bottom: 2rem;">
                                <table class="table table-striped table-hover table-bordered text-center mb-0">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>#</th>
                                            <th>Nome</th>
                                            <th>Preço</th>
                                            <th>Estoque</th>
                                        </tr>
                                    </thead>
                                    <tbody id="produtosBody"></tbody>

                                </table>
                        <div id="paginacao" class="text-center my-2"></div>


                            </div>                                                
                       </div>

                    `;

                    renderTabela();

                    const inputBusca = document.getElementById("buscaProduto");
                    inputBusca.addEventListener("input", () => renderTabela(inputBusca.value));

                } catch (err) {
                    console.error("Erro ao carregar produtos:", err);
                    container.innerHTML = `<div class="alert alert-danger">Não foi possível carregar os produtos.</div>`;
                }
            };

            carregarProdutos();
        })();
        </script>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
    
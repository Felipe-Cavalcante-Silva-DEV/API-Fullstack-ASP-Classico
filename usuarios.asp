<%@ LANGUAGE="VBSCRIPT" %>
<!-- #include virtual="includes/conexao.inc" -->
<!--#include virtual="includes/validaToken.inc" -->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="utf-8">
    <title>Dashboard - Usuários</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        html, body {
            height: 100%;
            margin: 0;
        }

        .conteudo-usuarios {
            flex-grow: 1;
            padding: 1rem;
            height: 100vh;
            overflow: hidden;
        }

        .scroll-tabela {
            overflow-y: auto;
            padding-bottom: 1rem;
            box-sizing: border-box;
        }

        @media (max-width: 767px) {
            .col-md-6, .col-12 {
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

    <div class="conteudo-usuarios">
        <h2>Usuários</h2>
        <div id="conteudoUsuarios"></div>
        <div id="paginacao" class="text-center my-2"></div>

        <script>
        (async function() {
            const container = document.getElementById("conteudoUsuarios");
            const containerPaginacao = document.getElementById("paginacao");

            let usuarios = [];
            const itensPorPagina = 15;
            let paginaAtual = 1;

            const renderTabela = (filtro = "") => {
                const tbody = document.getElementById("usuariosBody");
                tbody.innerHTML = "";

                const usuariosFiltrados = filtro
                    ? usuarios.filter(u => u.Nome.toLowerCase().includes(filtro.toLowerCase()))
                    : usuarios;

                const inicio = (paginaAtual - 1) * itensPorPagina;
                const fim = inicio + itensPorPagina;
                const paginaUsuarios = usuariosFiltrados.slice(inicio, fim);

                paginaUsuarios.forEach(u => {
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>${u.UserID}</td>
                        <td>${u.Nome}</td>
                        <td>${u.Email}</td>
                        <td>${u.TipoUsuario}</td>
                    `;
                    tbody.appendChild(tr);
                });

                renderPaginacao(usuariosFiltrados.length);
            };

            const renderPaginacao = (totalItens) => {
                containerPaginacao.innerHTML = "";
                const totalPaginas = Math.ceil(totalItens / itensPorPagina);

                for (let i = 1; i <= totalPaginas; i++) {
                    const btn = document.createElement("button");
                    btn.textContent = i;
                    btn.className = i === paginaAtual ? "btn btn-primary m-1" : "btn btn-outline-primary m-1";
                    btn.addEventListener("click", () => {
                        paginaAtual = i;
                        renderTabela(document.getElementById("buscaUsuario")?.value || "");
                    });
                    containerPaginacao.appendChild(btn);
                }
            };

            const carregarUsuarios = async () => {
                try {
                    const resp = await fetch("http://localhost:8083/api/auth.asp?action=list&token=token_admin");
                    usuarios = await resp.json();

                    container.innerHTML = `
                        <div class="card shadow-sm">
                            <div class="card-header bg-danger text-white">
                                <h4 class="mb-0">Usuários</h4>
                                <input type="text" id="buscaUsuario" placeholder="Buscar usuário..." class="form-control mt-2" />
                            </div>
                            <div class="card-body p-0">
                                <div class="scroll-tabela">
                                    <table class="table table-striped table-hover table-bordered text-center mb-0">
                                        <thead class="table-dark">
                                            <tr>
                                                <th>Id</th>
                                                <th>Nome</th>
                                                <th>Email</th>
                                                <th>Tipo</th>
                                            </tr>
                                        </thead>
                                        <tbody id="usuariosBody"></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    `;

                    renderTabela();

                    const inputBusca = document.getElementById("buscaUsuario");
                    inputBusca.addEventListener("input", () => {
                        paginaAtual = 1; // reinicia na primeira página ao filtrar
                        renderTabela(inputBusca.value);
                    });

                } catch (err) {
                    console.error("Erro ao carregar usuários:", err);
                    container.innerHTML = `<div class="alert alert-danger">Não foi possível carregar os usuários.</div>`;
                }
            };

            carregarUsuarios();
        })();
        </script>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

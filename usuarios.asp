<%@ LANGUAGE="VBSCRIPT" %>
<!-- #include virtual="includes/conexao.asp" -->
<!--#include virtual="includes/validaToken.asp" -->

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
            max-height: calc(100vh - 120px); /* altura da tela menos header do card e padding */
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
    <!--#include file="includes/sidebar.asp" -->

    <div class="conteudo-usuarios">
        <h2>Usuários</h2>
        <div id="conteudoUsuarios"></div>

        <script>
        (async function() {
            const container = document.getElementById("conteudoUsuarios");

            const renderTabela = async () => {
                try {
                    const resp = await fetch("http://localhost:8085/api/auth.asp?action=list&token=token_admin");
                    const usuarios = await resp.json();

                    container.innerHTML = `
                        <div class="card shadow-sm">
                            <div class="card-header bg-danger text-white">
                                <h4 class="mb-0">Usuários</h4>
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
                                        <tbody id="produtosBody"></tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    `;

                    const tbody = document.getElementById("produtosBody");
                    tbody.innerHTML = "";

                    usuarios.forEach(u => {
                        const tr = document.createElement("tr");
                        tr.innerHTML = `
                            <td>${u.UserID}</td>
                            <td>${u.Nome}</td>
                            <td>${u.Email}</td>
                            <td>${u.TipoUsuario}</td>
                        `;
                        tbody.appendChild(tr);
                    });

                } catch (err) {
                    console.error("Erro ao carregar usuários:", err);
                    container.innerHTML = `<div class="alert alert-danger">Não foi possível carregar os usuários.</div>`;
                }
            };

            renderTabela();
        })();
        </script>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

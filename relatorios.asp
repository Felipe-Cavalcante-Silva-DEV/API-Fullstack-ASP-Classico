<%@ LANGUAGE="VBSCRIPT" %>
<!--#include virtual="includes/conexao.inc" -->
<!--#include virtual="includes/validaToken.inc" -->

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="utf-8">
    <title>Dashboard - Logs</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        html, body {
            height: 100%;
            margin: 0;
        }

        .conteudo-principal {
            flex-grow: 1;
            padding: 1rem;
            height: 100vh;
            overflow: hidden;
        }

        .tabela-scroll {
            max-height: calc(100vh - 100px); /* altura da tela menos header do card e padding */
            overflow-y: auto;
        }

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

    <div class="conteudo-principal">
        <div id="conteudoLogs"></div>

        <script>
        (async function() {
            const container = document.getElementById("conteudoLogs");

            const renderTabela = (logsFiltrados, tbodyId) => {
                const tbody = document.getElementById(tbodyId);
                tbody.innerHTML = "";
                logsFiltrados.forEach(l => {
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>${l.Id}</td>
                        <td>${l.Acao}</td>
                        <td>${l.Tabela}</td>
                        <td>${l.RegistroId}</td>
                        <td>${l.DataLog}</td>
                    `;
                    tbody.appendChild(tr);
                });
            };

            const carregarLogs = async () => {
                try {
                    const resp = await fetch("http://localhost:8083/api/logs_api.asp?action=list&token=token_admin");
                    const logs = await resp.json();

                    container.innerHTML = `
                        <div class="row g-4">
                            <div class="col-md-6 col-12">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-danger text-white">
                                        <h4 class="mb-0">Logs DELETE</h4>
                                    </div>
                                    <div class="card-body p-0 tabela-scroll">
                                        <table class="table table-striped table-hover table-bordered text-center mb-0">
                                            <thead class="table-dark">
                                                <tr>
                                                    <th>#</th>
                                                    <th>Ação</th>
                                                    <th>Tabela</th>
                                                    <th>Registro ID</th>
                                                    <th>Data / Hora</th>
                                                </tr>
                                            </thead>
                                            <tbody id="deleteBody"></tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-6 col-12">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-warning text-dark">
                                        <h4 class="mb-0">Logs UPDATE</h4>
                                    </div>
                                    <div class="card-body p-0 tabela-scroll">
                                        <table class="table table-striped table-hover table-bordered text-center mb-0">
                                            <thead class="table-dark">
                                                <tr>
                                                    <th>#</th>
                                                    <th>Ação</th>
                                                    <th>Tabela</th>
                                                    <th>Registro ID</th>
                                                    <th>Data / Hora</th>
                                                </tr>
                                            </thead>
                                            <tbody id="updateBody"></tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;

                    const deleteLogs = logs.filter(l => l.Acao.toUpperCase() === "DELETE");
                    const updateLogs = logs.filter(l => l.Acao.toUpperCase() === "UPDATE");

                    renderTabela(deleteLogs, "deleteBody");
                    renderTabela(updateLogs, "updateBody");

                } catch (err) {
                    console.error("Erro ao carregar logs:", err);
                    container.innerHTML = `<div class="alert alert-danger">Não foi possível carregar os logs.</div>`;
                }
            };

            carregarLogs();
        })();
        </script>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

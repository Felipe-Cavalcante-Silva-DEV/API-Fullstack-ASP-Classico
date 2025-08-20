<div class="d-flex flex-column bg-dark text-white vh-100 p-3" style="width: 250px;">
    <h3 class="text-center">Dashboard</h3>
    <p class="text-center">Olá, <strong><%= email %></strong></p>

    <a href="produtos.asp" class="text-white text-decoration-none p-2 rounded d-block mb-1">Produtos</a>
    <a href="usuarios.asp" class="text-white text-decoration-none p-2 rounded d-block mb-1">Usuários</a>
    <a href="cadastro.asp" class="text-white text-decoration-none p-2 rounded d-block mb-1">Cadastro/Atualizar</a>
    <a href="externa.asp" class="text-white text-decoration-none p-2 rounded d-block mb-1">Injeção externa</a>
    <a href="relatorios.asp" class="text-white text-decoration-none p-2 rounded d-block mb-1">Relatórios</a>

    <a href="login.asp" class="btn btn-danger mt-auto">Sair</a>
</div>

<script>
    // Pega o token da URL atual
    const urlParams = new URLSearchParams(window.location.search);
    const token = urlParams.get("token");

    if(token){
        // Adiciona token a todos os links da sidebar
        document.querySelectorAll(".d-flex a").forEach(link => {
            const href = link.getAttribute("href");
            if(href && !href.includes("token=")){
                const separator = href.includes("?") ? "&" : "?";
                link.setAttribute("href", href + separator + "token=" + encodeURIComponent(token));
            }
        });
    }
</script>

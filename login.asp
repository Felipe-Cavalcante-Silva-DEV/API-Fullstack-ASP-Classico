
<!-- #include virtual="includes/conexao.inc" -->
<!-- #include virtual="includes/validaTokenApi.inc" -->
<!-- #include virtual="includes/appsettings.inc" -->
<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="utf-8">
<title>Login</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container py-5">

<h2>Login</h2>
<form id="loginForm" class="mb-3">
    <input type="text" id="loginNome" placeholder="Nome" class="form-control mb-2" required>
    <input type="password" id="loginSenha" placeholder="Senha" class="form-control mb-2" required>
    <button type="submit" class="btn btn-primary w-100">Login</button>
    
</form>

<div id="loginMsg"></div>

<script>

</script>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<h2>Registro</h2>
<form id="registerForm" class="mb-3 w-50 mx-auto p-3 border rounded shadow-sm bg-light">
    <div class="mb-3">
        <input type="text" id="regNome" placeholder="Nome" class="form-control" required>
    </div>
    <div class="mb-3">
        <input type="email" id="regEmail" placeholder="Email" class="form-control" required>
    </div>
    <div class="mb-3">
        <input type="password" id="regSenha" placeholder="Senha" class="form-control" required>
    </div>
    <button type="submit" class="btn btn-primary w-100">Registrar</button>
</form>

<div id="regMsg" class="w-50 mx-auto"></div>

<script>
    const API_CONNECTION = "<%= API_CONNECTION %>";

    $('#loginForm').submit(function(e) {
        e.preventDefault();
        

        const data = {
            nome: $('#loginNome').val(),
            senhahash: $('#loginSenha').val()
        };

        $.ajax({
            url: API_CONNECTION + "api/auth.asp?action=login",
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(data),
            success: function(response) {
                

                if (response.success) {
                    // Salva token e tipoUsuario na sessão
                    sessionStorage.setItem('token', response.token);

                    $('#loginMsg').html('<div class="alert alert-success">Login realizado com sucesso!'  + '</div>');

                    setTimeout(function() {
                        window.location.href = 'produtos.asp?token=' + encodeURIComponent(response.token);
                    }, 500);
                } else {
                    $('#loginMsg').html('<div class="alert alert-danger">' + (response.message || 'Login inválido') + '</div>');
                }
            },
            error: function(xhr, status, error) {
                console.error("Erro no login:", error);
                $('#loginMsg').html('<div class="alert alert-danger">Erro ao conectar com a API</div>');
            }
        });
    });

$('#registerForm').submit(function(e) {
    e.preventDefault();

    const data = {
        nome: $('#regNome').val(),
        email: $('#regEmail').val(),
        senhahash: $('#regSenha').val()
    };

    $.ajax({
        url: API_CONNECTION + 'api/auth.asp?action=register',
        type: 'POST',
        contentType: 'application/json',
        data: JSON.stringify(data),
        success: function(response) {
            $('#regMsg').html('<div class="alert alert-success">' + (response.message || 'Registro realizado!') + 
                ' Token: ' + (response.token || '') + '</div>');
        },
        error: function(xhr) {
            $('#regMsg').html('<div class="alert alert-danger">Erro ao registrar: ' + xhr.responseText + '</div>');
        }
    });
});
</script>



<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>


</body>
</html>

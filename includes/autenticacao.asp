<%
' Redireciona se não estiver logado
If Session("loggedin") = "" Then
    Response.Redirect "login.asp"
End If

' Função para checar se é admin
Function IsAdmin()
    If Session("role") = "admin" Then
        IsAdmin = True
    Else
        IsAdmin = False
    End If
End Function
%>

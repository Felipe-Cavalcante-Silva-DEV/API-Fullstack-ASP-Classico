<%@ Language="VBScript" %>
<!--#include virtual="/includes/conexao.asp" -->
<!--#include virtual="/includes/auth_utils.asp" -->
<!--#include virtual="/includes/json.asp" -->
<%
Response.ContentType = "application/json"
Dim action, nome, descricao, preco, produtoId, estoque, rs, cmd, sql, token
action = Request("action")
token  = Request("token") ' pode vir via querystring ou header

  
' 🔒 validar token
Set cmd = Server.CreateObject("ADODB.Command")
cmd.ActiveConnection = conDB


cmd.CommandType = 1 ' adCmdText
cmd.CommandText = "SELECT dbo.fnValidarToken('" & token & "') AS Valido"
Set rs = cmd.Execute


If rs("Valido") = 0 Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""error"": ""Token inválido ou expirado""}"
    Response.End
End If








If action = "list" Then
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spListarProdutos"
    Set rs = cmd.Execute

    Response.Write "["
    Do Until rs.EOF
        Response.Write "{""ProdutoID"": " & rs("Id") & _
                       ", ""Nome"": """ & rs("Nome") & """" & _
                       ", ""Descricao"": """ & rs("Descricao") & """" & _
                       ", ""Preco"": " & Replace(CStr(rs("Preco")), ",", ".") & _
                       ", ""Estoque"": " & rs("Estoque") & "}"

                       
                       
        rs.MoveNext
        If Not rs.EOF Then Response.Write ","
    Loop
    Response.Write "]"








ElseIf action = "add" Then
    On Error Resume Next

    Response.ContentType = "application/json"

    ' Ler corpo JSON
    Dim rawJSON
    rawJSON = ""
    If Request.TotalBytes > 0 Then
        rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    End If

    Dim objJSON
    Set objJSON = Nothing

    ' Tentar parsear JSON
    On Error Resume Next
    Set objJSON = ParseJSON(rawJSON)
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao parsear JSON: " & Err.Description & """}"
        Response.End
    End If
    On Error GoTo 0

    If objJSON Is Nothing Then
        Response.Write "{""success"":false,""message"":""JSON inválido ou vazio""}"
        Response.End
    End If

    ' Extrair campos do JSON
    On Error Resume Next
    nome = objJSON.nome
    descricao = objJSON.descricao
    preco = CDbl(objJSON.preco)
    estoque = CInt(objJSON.estoque)
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao extrair campos do JSON: " & Err.Description & """}"
        Response.End
    End If
    On Error GoTo 0

    ' Validação básica
    If nome = "" Or preco <= 0 Then
        Response.Write "{""success"":false,""message"":""Campos obrigatórios ausentes ou inválidos""}"
        Response.End
    End If

    ' Inserir produto via procedure
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spCriarProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 150, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Descricao", 200, 1, 500, descricao)
    cmd.Parameters.Append cmd.CreateParameter("@Preco", 5, 1, , preco)
    cmd.Parameters.Append cmd.CreateParameter("@Estoque", 3, 1, , estoque)

    Set rs = cmd.Execute

    ' Capturar ID do novo produto
    novoId = 0
    If Not rs.EOF Then novoId = rs("NovoProdutoID")

    ' Retornar JSON final
    Response.Write "{""success"":true,""message"":""Produto criado com sucesso"",""NovoProdutoID"":" & novoId & "}"

    Set rs = Nothing
    Set cmd = Nothing
    Response.End








ElseIf action = "update" Then
    On Error Resume Next
    Response.ContentType = "application/json"

    ' Ler corpo JSON

    rawJSON = ""
    If Request.TotalBytes > 0 Then
        rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    End If


    Set objJSON = Nothing

    ' Parsear JSON
    Set objJSON = ParseJSON(rawJSON)
    If objJSON Is Nothing Then
        Response.Write "{""success"":false,""message"":""JSON inválido ou vazio""}"
        Response.End
    End If

    ' Extrair campos
    On Error Resume Next
    produtoId = CLng(objJSON.produtoId)
    nome      = objJSON.nome
    descricao = objJSON.descricao
    preco     = CDbl(objJSON.preco)
    estoque   = CInt(objJSON.estoque)
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao extrair campos: " & Err.Description & """}"
        Response.End
    End If
    On Error GoTo 0

    ' Validação básica
    If produtoId <= 0 Or nome = "" Or preco <= 0 Then
        Response.Write "{""success"":false,""message"":""Campos obrigatórios ausentes ou inválidos""}"
        Response.End
    End If

    ' Executar procedure de update
    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spAtualizarProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , produtoId)
    cmd.Parameters.Append cmd.CreateParameter("@Nome", 200, 1, 150, nome)
    cmd.Parameters.Append cmd.CreateParameter("@Descricao", 200, 1, 500, descricao)
    cmd.Parameters.Append cmd.CreateParameter("@Preco", 5, 1, , preco)
    cmd.Parameters.Append cmd.CreateParameter("@Estoque", 3, 1, , estoque)

    On Error Resume Next
    cmd.Execute
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao atualizar produto: " & Err.Description & """}"
        Err.Clear
        Response.End
    End If
    On Error GoTo 0

    ' Retorno JSON
    Response.Write "{""success"":true,""message"":""Produto atualizado com sucesso""}"

    Set cmd = Nothing
    Response.End







ElseIf action = "delete" Then
    On Error Resume Next
    Response.ContentType = "application/json"

    ' Ler corpo JSON

    rawJSON = ""
    If Request.TotalBytes > 0 Then
        rawJSON = BinaryToString(Request.BinaryRead(Request.TotalBytes))
    End If

    ' Parsear JSON

    Set objJSON = ParseJSON(rawJSON)
    If objJSON Is Nothing Then
        Response.Write "{""success"":false,""message"":""JSON inválido ou vazio""}"
        Response.End
    End If

    ' Extrair produtoId

    On Error Resume Next
    produtoId = CLng(objJSON.produtoId)
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""produtoId inválido""}"
        Response.End
    End If
    On Error GoTo 0

    ' Validação básica
    If produtoId <= 0 Then
        Response.Write "{""success"":false,""message"":""produtoId inválido ou não fornecido""}"
        Response.End
    End If

    ' Executar procedure de delete

    Set cmd = Server.CreateObject("ADODB.Command")
    cmd.ActiveConnection = conDB
    cmd.CommandType = 4
    cmd.CommandText = "spExcluirProduto"
    cmd.Parameters.Append cmd.CreateParameter("@Id", 3, 1, , produtoId)

    On Error Resume Next
    cmd.Execute
    If Err.Number <> 0 Then
        Response.Write "{""success"":false,""message"":""Erro ao excluir produto: " & Err.Description & """}"
        Err.Clear
        Response.End
    End If
    On Error GoTo 0

    ' Retorno JSON
    Response.Write "{""success"":true,""message"":""Produto excluído com sucesso""}"

    Set cmd = Nothing
    set rs = Nothing        
    Response.End

End if



    









conDB.Close
%>

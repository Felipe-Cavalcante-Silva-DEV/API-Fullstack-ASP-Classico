<%
Function GerarToken()
    Dim chars, i, token
    chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    Randomize
    token = ""
    For i = 1 To 32
        token = token & Mid(chars, Int(Rnd() * Len(chars)) + 1, 1)
    Next
    GerarToken = token
End Function

%>

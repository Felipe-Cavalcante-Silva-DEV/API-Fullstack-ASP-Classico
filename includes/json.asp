<%
Function ParseJSON(strJSON)
    Dim sc
    ' Cria o ScriptControl
    Set sc = Server.CreateObject("MSScriptControl.ScriptControl")
    sc.Language = "JScript"
    
    ' Adiciona uma função em JScript para converter JSON em objeto
    sc.AddCode "function parse(json){ return eval('(' + json + ')'); }"
    
    ' Chama a função parse passando o JSON recebido
    Set ParseJSON = sc.Run("parse", strJSON)
End Function

Function BinaryToString(arrBytes)
    Dim stream
    Set stream = Server.CreateObject("ADODB.Stream")
    stream.Type = 1 ' adTypeBinary
    stream.Open
    stream.Write arrBytes
    stream.Position = 0
    stream.Type = 2 ' adTypeText
    stream.Charset = "utf-8"
    BinaryToString = stream.ReadText
    stream.Close
    Set stream = Nothing
End Function

%>



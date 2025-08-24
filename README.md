# API Fullstack ASP Clássico

Este projeto é um exemplo de aplicação **Fullstack com ASP Clássico**,
utilizando banco de dados SQL Server, endpoints expostos em formato de
API e interface simples com Bootstrap.

------------------------------------------------------------------------

## 🚀 Tecnologias Utilizadas

-   **ASP Clássico (VBScript)**
-   **SQL Server**
-   **Bootstrap 5**
-   **IIS (Internet Information Services) para hospedagem**
-   **JavaScript (fetch API para consumo da API)**

------------------------------------------------------------------------

## 📂 Estrutura do Projeto

    /includes
      appsettings.inc   -> variavel da sua rota
      conexao.inc       -> Conexão com banco de dados
      validaToken.inc   -> Middleware simples para autenticação via token
      json.inc          -> Funções utilitárias para retorno JSON

    /api
      produtos.asp      -> CRUD de produtos
      auth.asp          -> Login, registro e listagem de usuários

    /dashboard
      produtos.asp      -> Tela de gestão de produtos
      usuarios.asp      -> Tela de gestão de usuários

------------------------------------------------------------------------

## ⚙️ Configuração do Ambiente

### 1. Pré-requisitos

-   Windows 10/11 com **IIS habilitado**
-   SQL Server instalado (pode ser Express)
-   Acesso ao **SQL Server Management Studio (SSMS)**

### 2. Clonar o repositório
``` bash
git clone https://github.com/Felipe-Cavalcante-Silva-DEV/API-Fullstack-ASP-Classico.git
```

### 3. Configurar o banco de dados

1.  Crie um banco de dados no SQL Server (exemplo: `api`).
2.  Execute o scripts SQL fornecidos em `/SQL/DML_DLL_Inicial.sql` para criar as
    tabelas , procedures, function e triggers.
3.  No arquivo **`includes/conexao.inc`**, configure a
    `ConnectionString` de acordo com o seu ambiente, por exemplo:

    
``` asp
strConn = "Provider=SQLOLEDB;Data Source=localhost;Initial Catalog=API_Fullstack;User Id=sa;Password=SUASENHA;"
```

### 4. Configurar no IIS

Se o IIS não estiver instalado:

1. Abra Painel de Controle → Programas e Recursos → Ativar ou desativar recursos do Windows.
2. Marque Internet Information Services → expanda Serviços de World Wide Web → habilite ASP e ASP Clássico.
3. Clique em OK e aguarde a instalação.

Ao instalar corretamente:

1.  Abra o **Gerenciador do IIS**.
2.  Clique com o botão direito em **Sites \> Adicionar Site**.
3.  Configure:
    -   **Nome do site:** WebFullstrack
    -   **Caminho físico:** pasta clonada do projeto 
    -   **Porta:** 8085 (ou outra rota disponivel)
    -   OBS: Lembrar de alterar o valor da sua porta no arquivo appsettings.inc
4.  Clique em **Configurações Avançadas** do aplicativo e defina:
    -   **Versão do ASP:** Ativar **ASP Clássico**
    -   **Permissões de leitura e script:** Ativar
5.  Reinicie o site no IIS.

### 5. Testar no navegador

Acesse:

    http://localhost:8085/login.asp

E também as rotas da API, por exemplo:

    http://localhost:8085/api/auth.asp?action=register

    http://localhost:8085/api/auth.asp?action=login

    recupere o SEU_TOKEN e teste a coleção de rotas do postman:
    Rota Exemplo:
    http://localhost:8085/api/produtos.asp?action=list&token=SEU_TOKEN

------------------------------------------------------------------------

## 🔑 Autenticação via Token

-   O acesso às rotas da API é protegido por **token**.
-   O token é gerado na hora da criação de um novo usuário.
-   O arquivo `includes/validaToken.asp` valida a querystring `token`
    enviada nas requisições.

Exemplo:

    http://localhost:8085/api/produtos.asp?action=add&token=TOKEN_VALIDO

------------------------------------------------------------------------

## 🛠️ Desenvolvimento

-   Para editar os arquivos, qualquer editor de texto pode ser usado (Sublime
    text(recomendado) ou VS Code).
-   Sempre reinicie o IIS após mudanças de configuração.

------------------------------------------------------------------------

## 📌 Observações

-   Este projeto é um **exemplo didático**, não devendo ser usado em
    produção sem ajustes de segurança.

------------------------------------------------------------------------

## 👨‍💻 Autor

**Felipe Cavalcante Silva**\
[GitHub](https://github.com/Felipe-Cavalcante-Silva-DEV)

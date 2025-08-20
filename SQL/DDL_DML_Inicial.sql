    -- =========================
    -- CRIAR DATABASE
    -- =========================
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'api')
        CREATE DATABASE api;
    GO


    -- =========================
    -- TABELAS
    -- =========================

    -- Usuários do sistema
    CREATE TABLE Usuarios (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(100) NOT NULL,
        Email NVARCHAR(150) NOT NULL UNIQUE,
        SenhaHash NVARCHAR(200) NOT NULL,
        TipoUsuario VARCHAR(20) DEFAULT 'usuario',
        Token NVARCHAR(200),
        DataCriacao DATETIME DEFAULT GETDATE()
    );
    GO

    -- Produtos
    CREATE TABLE Produtos (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(150) NOT NULL,
        Descricao NVARCHAR(500),
        Preco DECIMAL(10,2) NOT NULL,
        Estoque INT NOT NULL,
        DataCriacao DATETIME DEFAULT GETDATE()
    );
    GO

    -- Logs de operações
    CREATE TABLE Logs (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Acao NVARCHAR(50) NOT NULL,
        Tabela NVARCHAR(50) NOT NULL,
        RegistroId INT NOT NULL,
        DataLog DATETIME DEFAULT GETDATE()
    );
    GO

    
    -- =========================
    -- PROCEDURES
    -- =========================

    -- Registro de usuário
    CREATE OR ALTER PROCEDURE spRegistrarUsuario
        @Nome NVARCHAR(100),
        @Email NVARCHAR(150),
        @SenhaHash NVARCHAR(200)
    AS
    BEGIN
        SET NOCOUNT ON;

        -- Verifica se já existe usuário com o e-mail informado
        IF EXISTS (SELECT 1 FROM Usuarios WHERE Email = @Email)
        BEGIN
            RAISERROR('Email já registrado.', 16, 1);
            RETURN;
        END;

        -- Insere novo usuário
        INSERT INTO Usuarios (Nome, Email, SenhaHash, DataCriacao)
        VALUES (@Nome, @Email, @SenhaHash, GETDATE());
    END;
    GO


    -- Login de usuário
    CREATE OR ALTER PROCEDURE spLoginUsuario
        @Nome NVARCHAR(100),
        @SenhaHash NVARCHAR(200)
    AS
    BEGIN
        SELECT Id, Nome, SenhaHash, Email, TipoUsuario, Token
        FROM Usuarios
        WHERE Nome = @Nome AND SenhaHash = @SenhaHash;
    END;
    GO


    -- listar usuarios
    CREATE OR ALTER PROCEDURE spListarUsuarios
    AS
    BEGIN
        SET NOCOUNT ON;

        SELECT 
            Id,
            Nome,
            Email,
            TipoUsuario,
            DataCriacao
        FROM Usuarios
        ORDER BY DataCriacao DESC;
    END;
    GO


    -- Criar produto
    CREATE OR ALTER PROCEDURE spCriarProduto
        @Nome NVARCHAR(150),
        @Descricao NVARCHAR(500),
        @Preco DECIMAL(10,2),
        @Estoque INT
    AS
    BEGIN
        SET NOCOUNT ON;

        INSERT INTO Produtos (Nome, Descricao, Preco, Estoque)
        VALUES (@Nome, @Descricao, @Preco, @Estoque);

        -- Retorna o ID do produto recém criado
        SELECT SCOPE_IDENTITY() AS NovoProdutoID;
    END;
    GO


    -- Listar produtos
    CREATE OR ALTER PROCEDURE spListarProdutos
    AS
    BEGIN
        SELECT Id, Nome, Preco, Estoque
        FROM Produtos;
    END;
    GO



    -- Atualizar produto
    CREATE OR ALTER PROCEDURE spAtualizarProduto
        @Id INT,
        @Nome NVARCHAR(150),
        @Descricao NVARCHAR(500),
        @Preco DECIMAL(10,2),
        @Estoque INT
    AS
    BEGIN
        UPDATE Produtos
        SET Nome = @Nome,
            Descricao = @Descricao,
            Preco = @Preco,
            Estoque = @Estoque
        WHERE Id = @Id;
    END;
    GO

    -- Excluir produto
    CREATE OR ALTER PROCEDURE spExcluirProduto
        @Id INT
    AS
    BEGIN
        DELETE FROM Produtos WHERE Id = @Id;
    END;
    GO

    -- =========================
    -- TRIGGERS
    -- =========================

    -- Log de update
    CREATE OR ALTER TRIGGER trgLogUpdateProduto
    ON Produtos
    AFTER UPDATE
    AS
    BEGIN
        DECLARE @Id INT;
        SELECT @Id = INSERTED.Id FROM INSERTED;

        INSERT INTO Logs (Acao, Tabela, RegistroId)
        VALUES ('UPDATE', 'Produtos', @Id);
    END;
    GO

    -- Log de delete
    CREATE OR ALTER TRIGGER trgLogDeleteProduto
    ON Produtos
    AFTER DELETE
    AS
    BEGIN
        DECLARE @Id INT;
        SELECT @Id = DELETED.Id FROM DELETED;

        INSERT INTO Logs (Acao, Tabela, RegistroId)
        VALUES ('DELETE', 'Produtos', @Id);
    END;
    GO


       -- =========================
    -- SEED DATA
    -- =========================

    -- Usuário produtos padrão
    INSERT INTO Produtos (Nome, Descricao, Preco, Estoque)
    VALUES
    ('Notebook Dell', 'Notebook para uso geral', 3500.00, 10),
    ('Teclado Mecânico', 'Teclado gamer RGB', 450.00, 20),
    ('Mouse Logitech', 'Mouse sem fio', 150.00, 30);

    INSERT INTO Usuarios (Nome, Email, SenhaHash, Token)
    VALUES
    ('Admin', 'Admin@admin.com', 123, 'token_admin');

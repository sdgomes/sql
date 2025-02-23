EXEC sp_addlinkedserver 
    @server = 'SQL003',  -- Nome do Linked Server
    @srvproduct = '',  -- Deixe vazio para SQL Server
    @provider = 'SQLNCLI',  -- Para SQL Server Native Client
    @datasrc = 'SQL003'; -- Nome ou IP do servidor de destino
GO

EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = 'SQL003', 
    @useself = 'false', 
    @rmtuser = 'linked_server',  -- Usuário do SQL Server remoto
    @rmtpassword = 'linked_123456'; -- Senha do SQL Server remoto
GO
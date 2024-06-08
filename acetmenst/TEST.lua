-- Carregando a biblioteca LuaSQL para MySQL
local luasql = require "luasql.mysql"

-- Função para autenticar o usuário no banco de dados MySQL
function authenticateUser(username, password)
    -- Definindo as credenciais do banco de dados MySQL
    local host = "seu_host"
    local user = "seu_usuario"
    local pass = "sua_senha"
    local dbname = "seu_banco_de_dados"

    -- Conectando ao banco de dados MySQL
    local env = assert(luasql.mysql())
    local con = assert(env:connect(dbname, user, pass, host))

    -- Consultando o banco de dados para verificar as credenciais do usuário
    local query = string.format("SELECT * FROM users WHERE username = '%s' AND password = '%s'", username, password)
    local cur = assert(con:execute(query))

    -- Verificando se há um resultado na consulta
    local row = cur:fetch({}, "a")
    if row then
        -- Usuário autenticado com sucesso
        return true
    else
        -- Falha na autenticação
        return false
    end

    -- Fechando as conexões
    cur:close()
    con:close()
    env:close()
end

-- Exemplo de uso
local username = "nome_de_usuario"
local password = "senha"

if authenticateUser(username, password) then
    print("Usuário autenticado com sucesso!")
else
    print("Falha na autenticação. Verifique suas credenciais.")
end

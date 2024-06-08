# Gemfile
source 'https://rubygems.org'

gem 'web3'
require 'web3'

# Defina o ABI do contrato
contract_abi = [
  {
    "inputs": [],
    "name": "registerUser",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "authenticateUser",
    "outputs": [{ "internalType": "bool", "name": "", "type": "bool" }],
    "stateMutability": "view",
    "type": "function"
  }
]

# Endereço do contrato
contract_address = 'YOUR_CONTRACT_ADDRESS'

# Inicialize o Web3
web3 = Web3::Eth::Rpc.new host: 'http://localhost:8080'

# Construa o contrato
contract = web3.eth.contract(contract_abi, contract_address)

# Função para registrar um usuário
def register_user(contract, password_hash)
  begin
    accounts = web3.eth.accounts
    contract.transact.registerUser(password_hash, from: accounts.first)
    puts 'User registered successfully'
  rescue => e
    puts "Error registering user: #{e.message}"
  end
end

# Função para autenticar um usuário
def authenticate_user(contract, password_hash)
  begin
    result = contract.call.authenticateUser(password_hash)
    puts "Authenticated user: #{result}"
  rescue => e
    puts "Error authenticating user: #{e.message}"
  end
end

# Exemplo de uso
password_hash = 'PASSWORD_HASH'

# Registra um novo usuário
register_user(contract, password_hash)

# Verifica a autenticação do usuário
authenticate_user(contract, password_hash)

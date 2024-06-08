require 'web3'

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

contract_address = 'YOUR_CONTRACT_ADDRESS'

web3 = Web3::Eth::Rpc.new host: 'http://localhost:8080'

contract = web3.eth.contract(contract_abi, contract_address)

def register_user(contract, password_hash, account)
  begin
    contract.transact.registerUser(password_hash, from: account)
  rescue => e
    puts "Error registering user: #{e.message}"
  end
end

def authenticate_user(contract, password_hash)
  begin
    result = contract.call.authenticateUser(password_hash)
    puts "Authenticated user: #{result}"
  rescue => e
    puts "Error authenticating user: #{e.message}"
  end
end

password_hash = 'PASSWORD_HASH'
main_key = 'MAIN_KEY_ADDRESS'

register_user(contract, password_hash, main_key)
authenticate_user(contract, password_hash)

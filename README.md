# 🔱 POSEIDOM v4 -  Blockchain posseidom - Iron Bear v4  🔱

---

## Descrição:
POSEIDOM v4 é uma plataforma de tokenização de diamantes baseada na blockchain derivada Iron Bear v3. Esta aplicação permite a criação, transferência e verificação de propriedade de tokens que representam diamantes na rede Iron Bear. Esta versão inicial apresenta um conjunto básico de funcionalidades para iniciar a tokenização de ativos digitais.

## Funcionalidades Principais:
- Criação de tokens de diamante na blockchain Iron Bear.
- Transferência de tokens entre contas.
- Verificação de propriedade de tokens.

## Pré-requisitos:
- Node.js instalado na sua máquina.
- Cliente Iron Bear configurado e sincronizado com a rede Iron Bear.
- Conhecimento básico de Solidity para contratos inteligentes Iron Bear.
- Conexão à internet para interagir com a rede Iron Bear.

## Instruções de Uso:

1. **Clonando o Repositório:**
   ```sh
   git clone https://github.com/seu-usuario/poseidom-v4.git
   ```

2. **Instalando Dependências:**
   ```sh
   cd poseidom-v4
   npm install
   ```

3. **Configurando a Rede Iron Bear:**
   - Garanta que seu cliente Iron Bear esteja em execução e sincronizado.
   - Configure as variáveis de ambiente no arquivo `.env` com os detalhes da sua rede Iron Bear.

4. **Implantando o Contrato Inteligente:**
   - Compile e implante o contrato inteligente `DiamondToken.sol` em sua rede Iron Bear.
   - Após a implantação, atualize o endereço do contrato no arquivo `config.js`.

5. **Executando a Aplicação:**
   ```sh
   npm start
   ```

6. **Interagindo com a POSEIDOM:**
   - Utilize os endpoints da API REST para criar, transferir e verificar a propriedade dos tokens de diamante.
   - Os tokens de diamante são representados como ativos ERC-20 na blockchain Iron Bear.

## Contribuição:
Contribuições são bem-vindas! Sinta-se à vontade para enviar solicitações de pull para melhorias, correções de bugs ou novos recursos.

## Licença:
Este projeto está licenciado sob a Licença Apache 2.0. Consulte o arquivo LICENSE para mais detalhes.

## Autor:
Conheça mais sobre o autor [aqui](https://nscio.vercel.app/).

## Aviso Legal:
Este projeto destina-se apenas a fins educacionais e de demonstração. Não deve ser usado em ambientes de produção sem uma revisão e teste adequados. A implementação inicial fornecida pode não ser adequada para todos os casos de uso e pode exigir ajustes significativos para atender a requisitos específicos.

![POSEIDOM Logo](logo.png)

---

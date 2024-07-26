// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

// Definição da interface ERC20, que define o padrão para tokens ERC20.
interface IERC20 {

    // Funções de leitura (getters)
    // Retorna o total de tokens em circulação.
    function totalSupply() external view returns(uint256);

    // Retorna o saldo de tokens de um determinado endereço.
    function balanceOf(address account) external view returns (uint256);

    // Retorna a quantidade de tokens que um endereço está autorizado a gastar em nome de outro endereço.
    function allowance(address owner, address spender) external view returns (uint256);

    // Funções de escrita
    // Transfere uma quantidade de tokens para um endereço destinatário.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Permite que um endereço gaste uma quantidade específica de tokens em nome do chamador.
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfere uma quantidade de tokens de um endereço para outro, usando uma autorização previamente aprovada.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Eventos
    // Emitido quando tokens são transferidos de um endereço para outro.
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitido quando a permissão para gastar tokens é aprovada ou alterada.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementação do contrato ERC20 chamada EDDIECoin
contract EDDIECoin is IERC20 {

    // Nome do token
    string public constant name = "ETH Coin";
    // Símbolo do token
    string public constant symbol = "ETH";
    // Número de casas decimais do token
    uint8 public constant decimals = 18;

    // Mapeamento de saldos de tokens por endereço
    mapping (address => uint256) balances;

    // Mapeamento de permissões de gastos de tokens: quanto um endereço está autorizado a gastar em nome de outro
    mapping(address => mapping(address => uint256)) allowed;

    // Total de tokens em circulação
    uint256 totalSupply_ = 10 ether;

    // Construtor do contrato, que inicializa o saldo do criador do contrato com o totalSupply
    constructor() {
        balances[msg.sender] = totalSupply_;
    }

    // Retorna o total de tokens em circulação
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // Retorna o saldo de tokens de um endereço específico
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }

    // Transfere uma quantidade de tokens para um endereço destinatário
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        // Verifica se o remetente tem tokens suficientes
        require(numTokens <= balances[msg.sender], "Saldo insuficiente");
        // Atualiza o saldo do remetente e do destinatário
        balances[msg.sender] -= numTokens;
        balances[receiver] += numTokens;
        // Emite um evento de transferência
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // Permite que um endereço autorize outro endereço a gastar uma quantidade específica de tokens em seu nome
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        // Define a quantidade de tokens que o delegate pode gastar
        allowed[msg.sender][delegate] = numTokens;
        // Emite um evento de aprovação
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // Retorna a quantidade de tokens que um endereço está autorizado a gastar em nome de outro endereço
    function allowance(address owner, address delegate) public override view returns (uint256) {
        return allowed[owner][delegate];
    }

    // Transfere uma quantidade de tokens de um endereço para outro, usando uma autorização previamente aprovada
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        // Verifica se o proprietário tem tokens suficientes e se a autorização é suficiente
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        // Atualiza o saldo do proprietário, a autorização e o saldo do comprador
        balances[owner] -= numTokens;
        allowed[owner][msg.sender] -= numTokens;
        balances[buyer] += numTokens;
        // Emite um evento de transferência
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}

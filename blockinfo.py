from web3 import Web3
from web3.middleware import geth_poa_middleware
# 连接到 Goerli 网络
w3 = Web3(Web3.HTTPProvider('https://goerli.infura.io/v3/69b30b8f90e344ecbfe7509a436b8784'))
w3.middleware_onion.inject(geth_poa_middleware,layer=0)


# 设置起始区块和结束区块
start_block = 5539577
end_block = 5539578

# 定义智能合约 ABI 获取函数
def get_contract_abi(contract_address):
    try:
        contract_abi = w3.eth.contract(address=contract_address).abi
    except InvalidAddress:
        contract_abi = None
    return contract_abi

# 定义获取合约函数签名对应的 ABI 函数
def get_function_abi(contract_address, function_signature):
    contract_abi = get_contract_abi(contract_address)
    if contract_abi is not None:
        contract_instance = w3.eth.contract(address=contract_address, abi=contract_abi)
        function_abi = next((x for x in contract_instance.abi if x['type'] == 'function' and function_signature in w3.sha3(text=x['name'] + '(' + ','.join([y['type'] for y in x['inputs']]) + ')').hex()), None)
    else:
        function_abi = None
    return function_abi

# 遍历指定区块并获取智能合约信息
for block_number in range(start_block, end_block+1):
    block = w3.eth.getBlock(block_number, True)
    if block is not None and 'transactions' in block:
        for tx in block['transactions']:
            if tx['to'] is not None:
                # 获取智能合约地址和函数签名
                contract_address = tx['to']
                function_signature = tx['input'][:10]
                
                # 获取智能合约 ABI 和函数 ABI
                contract_abi = get_contract_abi(contract_address)
                function_abi = get_function_abi(contract_address, function_signature)
                
                # 如果智能合约 ABI 和函数 ABI 都存在，则输出相应信息
                if contract_abi is not None and function_abi is not None:
                    print('Block:', block_number)
                    print('Contract Address:', contract_address)
                    print('Function Signature:', function_signature)
                    print('Function Name:', function_abi['name'])
                    print('Function Inputs:', function_abi['inputs'])
                    print('Function Outputs:', function_abi['outputs'])
                    print('Transaction Hash:', tx['hash'].hex())
                    print('Transaction Index:', tx['transactionIndex'])
                    print('From Address:', tx['from'])
                    print('Gas Price:', tx['gasPrice'])
                    print('Gas Used:', tx['gas'])
                    print('Value:', tx['value'])
                    print('---------------------------------------')
                    
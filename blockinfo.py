from web3 import Web3
from web3.middleware import geth_poa_middleware
# 连接到 Goerli 网络
w3 = Web3(Web3.HTTPProvider('https://goerli.infura.io/v3/69b30b8f90e344ecbfe7509a436b8784'))
w3.middleware_onion.inject(geth_poa_middleware,layer=0)
# 获取最新区块号
latest_block_number = w3.eth.blockNumber

# 打开文件以写入内容
with open('goerli_blocks.txt', 'w') as f:
    # 循环遍历所有区块
    for block_number in range(latest_block_number+1):
        # 获取当前区块的信息
        block = w3.eth.getBlock(block_number)

        # 写入当前区块的信息到文件中
        f.write(f'Block Number: {block.number}\n')
        f.write(f'Timestamp: {block.timestamp}\n')
        f.write(f'Hash: {block.hash.hex()}\n')
        f.write(f'Parent Hash: {block.parentHash.hex()}\n')
        f.write(f'Transactions: {block.transactions}\n')
        f.write('\n')

        # 遍历当前区块的所有交易
        for tx_hash in block.transactions:
            # 获取当前交易的信息
            tx = w3.eth.getTransaction(tx_hash)

            # 写入当前交易的信息到文件中
            f.write(f'Transaction Hash: {tx.hash.hex()}\n')
            f.write(f'From: {tx["from"]}\n')
            f.write(f'To: {tx.to}\n')
            f.write(f'Value: {tx.value}\n')
            f.write('\n')
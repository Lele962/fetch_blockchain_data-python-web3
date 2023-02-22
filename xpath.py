# https://etherscan.io/contractsVerified

# 在上面的代码中，我们首先使用 Web3.py 库连接到 Goerli 网络，并获取最新区块号。
# 然后，我们使用一个循环遍历所有区块，获取当前区块的信息，并输出它的区块号、
# 时间戳、哈希、父哈希和交易列表。接下来，我们遍历当前区块的所有交易，
# 并获取每个交易的信息，并输出它的哈希、发送者、接收者和价值。
from web3 import Web3

# 连接到 Goerli 网络
w3 = Web3(Web3.HTTPProvider('https://goerli.infura.io/v3/69b30b8f90e344ecbfe7509a436b8784'))

# 获取最新区块号
latest_block_number = w3.eth.blockNumber

# 循环遍历所有区块
for block_number in range(latest_block_number+1):
    # 获取当前区块的信息
    block = w3.eth.getBlock(block_number)

    # 输出当前区块的信息
    print(f'Block Number: {block.number}')
    print(f'Timestamp: {block.timestamp}')
    print(f'Hash: {block.hash.hex()}')
    print(f'Parent Hash: {block.parentHash.hex()}')
    print(f'Transactions: {block.transactions}')
    print('')

    # 遍历当前区块的所有交易
    for tx_hash in block.transactions:
        # 获取当前交易的信息
        tx = w3.eth.getTransaction(tx_hash)

        # 输出当前交易的信息
        print('Transaction Hash: {tx.hash.hex()}')
        print('From: {tx.from}')
        print('To: {tx.to}')
        print('Value: {tx.value}')
        print('')
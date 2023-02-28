# 功能说明如下

在上面的代码中，我们首先使用`Web3.py`库连接到`Goerli`网络，并获取最新区块号。
然后，我们使用一个循环遍历所有区块，获取当前区块的信息，并输出它的区块号、时间戳、哈希、父哈希和交易列表。
接下来，我们遍历当前区块的所有交易，并获取每个交易的信息，并输出它的哈希、发送者、接收者和价值。

## 2.28

可以使用 Python 和相关的网络爬虫库（如 requests 和 BeautifulSoup）来爬取 `etherscan.io/contractsverified` 网站上的合约信息，并将其输出到文件中。

以下是一个可能的代码示例，它使用 `requests` 和 `BeautifulSoup` 库来获取和解析 `etherscan.io` 网站上的 HTML 代码，并使用正则表达式来提取合约信息并输出到文件中：
此代码将在运行时创建一个名为 `contracts.txt` 的文件，并将每个合约的名称、地址、编译器版本和代码写入该文件。请注意，为了避免被 etherscan.io 网站屏蔽，此代码中包括了一个自定义请求头。

运行报错`check_hostname requires server_hostname`

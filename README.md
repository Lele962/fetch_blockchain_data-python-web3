# 功能说明如下

```powershell
python .\smartcontract_info.py
```

可以直接运行

_that's all_ **Fetch the latest 500 smart contracts**

This is a Python script that scrapes verified smart contract addresses from the etherscan.io website and then downloads the corresponding smart contract source code.

The script first defines a function askURL() that loops through the first 20 pages of the "contractsVerified" section on etherscan.io and retrieves the HTML code of each page. Within each page, the script searches for links to smart contract addresses and stores them in a list called addresses. It then generates the full URL for each smart contract and requests the corresponding HTML page. The script searches the HTML code of each smart contract page for the smart contract source code and stores it in a string called result. Finally, it creates a directory called "output" and writes the smart contract source code to a separate file in this directory, with the filename corresponding to the smart contract address.

The Parse_html(html) function is called within askURL() to extract the smart contract addresses and download the source code. Within this function, BeautifulSoup is used to parse the HTML code of each page and locate the smart contract addresses and source code.

Overall, this script demonstrates how web scraping can be used to retrieve information from websites and automate the process of downloading smart contract source code. However, it is important to note that web scraping can violate website terms of service and may be illegal in some jurisdictions. It is always important to consider ethical and legal implications when engaging in web scraping activities.

在上面的代码中，我们首先使用`Web3.py`库连接到`Goerli`网络，并获取最新区块号。
然后，我们使用一个循环遍历所有区块，获取当前区块的信息，并输出它的区块号、时间戳、哈希、父哈希和交易列表。
接下来，我们遍历当前区块的所有交易，并获取每个交易的信息，并输出它的哈希、发送者、接收者和价值。

## 2.28

可以使用 Python 和相关的网络爬虫库（如 requests 和 BeautifulSoup）来爬取 `etherscan.io/contractsverified` 网站上的合约信息，并将其输出到文件中。

以下是一个可能的代码示例，它使用 `requests` 和 `BeautifulSoup` 库来获取和解析 `etherscan.io` 网站上的 HTML 代码，并使用正则表达式来提取合约信息并输出到文件中：
此代码将在运行时创建一个名为 `contracts.txt` 的文件，并将每个合约的名称、地址、编译器版本和代码写入该文件。请注意，为了避免被 etherscan.io 网站屏蔽，此代码中包括了一个自定义请求头。

运行报错`check_hostname requires server_hostname`

解释一下新增的部分：

首先，我们通过 `ds.find_all('span', {'id': 'ContentPlaceHolder1_contractCodeDiv'})[0].text.strip`() 获取合约名称，然后将其存储在 contract_name 变量中。

接着，我们构造输出文件的名称，这里以合约名称作为文件名，并在 output/ 目录下创建该文件。

最后，我们将获取到的合约代码写入文件中。注意，在这里我们使用 with open(...) 的方式打开文件，这种方式可以自动关闭文件，避免忘记关闭文件导致的问题。

这个代码的作用是获取以太坊区块链上已验证的智能合约的源代码，并将其保存到本地文件中。代码的大致流程如下：

使用 BeautifulSoup 库解析获取到的网页内容，获取每个智能合约的地址。
针对每个智能合约的地址，访问其对应的页面，获取合约源代码。
使用 BeautifulSoup 库解析获取到的合约页面内容，获取合约的源代码。
将获取到的合约源代码保存到本地文件中。
注意事项：

代码中将获取到的所有合约源代码保存到同一个目录下，因此如果存在同名文件可能会覆盖掉之前获取的文件。
网络请求的代码中设置了一个访问超时时间，如果访问时间过长，会抛出超时异常。
每次访问一个合约页面时，只会获取一个合约的源代码，因此对于每个合约，都需要单独保存到文件中。

```bash
./pre_scripts -t mythril -f samples/*.sol
./pre_scripts -t slither -f samples/*.sol
./reparse results
./results2csv -p results > results.csv
```

# 导入所需的模块
import requests
from bs4 import BeautifulSoup
import json

# 定义一个函数来爬取一页已验证合约
def scrape_one_page(page):
  # 构造请求的url
  url = f'https://etherscan.io/contractsVerified/{page}'
  # 发送get请求并获取响应
  response = requests.get(url)
  # 加载响应的html内容
  soup = BeautifulSoup(response.text, 'html.parser')
  # 定义一个列表来存储爬取到的信息
  contracts = []
  # 遍历表格中的每一行
  for row in soup.find('table').find('tbody').find_all('tr'):
    # 获取合约地址、名称、余额、交易数和编译器版本等信息
    address = row.find('td', {'class': 'address'}).text.strip()
    name = row.find('td', {'class': 'name'}).text.strip()
    balance = row.find('td', {'class': 'balance'}).text.strip()
    txns = row.find('td', {'class': 'txns'}).text.strip()
    compiler = row.find('td', {'class': 'compiler'}).text.strip()
    # 将信息存入列表中
    contracts.append({'address': address, 'name': name, 'balance': balance, 'txns': txns, 'compiler': compiler})
  # 返回列表
  return contracts

# 定义一个函数来爬取所有已验证合约
def scrape_all_pages():
  # 定义一个变量来存储当前页码，默认为1
   page = 1 
   # 定义一个变量来存储总页数，默认为0 
   total_pages=0 
   # 定义一个列表来存储所有爬取到的信息 
   all_contracts=[] 
  
   while True: 
     try: 
       # print(f'正在爬取第{page}页...') 
       # 调用函数爬取一页已验证合约，并将结果添加到列表中 
       contracts=scrape_one_page(page) 
       all_contracts.extend(contracts) 
       print(f'第{page}页爬取完成，共{len(contracts)}条数据。') 
        
       if total_pages==0: 
         # 如果是第一次爬取，则获取总页数，并打印出来。 
         total_pages=int(soup.find('ul', {'class':'pagination'}).find_all('li')[-1].find('a')['href'].split('/')[2]) 
         print(f'总共有{total_pages}页。') 
        
       if page==total_pages: 
         break 
        
       page+=1 
    
     except Exception as e: 
       print(e) 
  
   print(f'所有页面爬取完成，共{len(all_contracts)}条数据。') 
  
   print(f'正在将数据写入文件...') 
  
   with open('./contracts.json','w') as f:  
     json.dump(all_contracts,f) 
  
   print(f'数据写入完成。')

# 调用函数开始爬虫程序。
scrape_all_pages()
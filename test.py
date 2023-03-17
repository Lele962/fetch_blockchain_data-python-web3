from bs4 import BeautifulSoup
import urllib.request, urllib.error
import os

addresses = []
names = []
count = 0

def askURL():                                   # 获取当前页的智能合约地址
    head={                                      # 模拟浏览器头部信息
        "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"
    }
    #用户代理，告诉服务器机器类型。
    baseURL="https://etherscan.io/contractsVerified/" # 获取智能合约地址页面 基地址
    for i in range(1,21):
        url=baseURL+str(i)                      #1-9页 加在基地址后面
        print(url)
        request = urllib.request.Request(url,headers=head,method="GET") # 封装访问信息
        response = urllib.request.urlopen(request,timeout=30) # 必须设置
        html=response.read().decode("gbk")      # 以gbk的方式解码，添加在列表里
        Parse_html(html)                        # 在每一个合约中抓取源代码

def Parse_html(html):
    bs = BeautifulSoup(html,"html.parser")      # 解析每个html文件，
    with open("html.txt", 'w',encoding='utf-8') as file_object:
            file_object.write(str(bs))
    # 模拟浏览器头部信息，向服务器发送消息
    head = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"
    }

    for a in bs.find_all('a', href=True):
        if 'address' in a['href']:
            addresses.append(a['href'].split('/')[-1])

    
    str1="https://etherscan.io/address/"        # 合约页面基地址
    str2="#code"                                # 合约页面地址的最后部分，合约地址在str1、str2中间

    for item in addresses:
        
        url=str1+item+str2                      # 拼全合约地址
        url = url.split("#")[0]                 # 将字符串按照 "#" 分割，取第一个元素
        request = urllib.request.Request(url, headers=head, method="GET") # 打包访问信息

        print("contract:"+url)
        response = urllib.request.urlopen(request,timeout=30) # 访问合约页面
        contract = response.read().decode("utf-8")  # 解析合约页面

        ds = BeautifulSoup(contract, "html.parser") # 用html解析打开

        contract = ds.find_all(class_="js-sourcecopyarea editor") # 定位页面中的合约信息
        if len(contract) > 0:
            text = contract[0].get_text()
            result = text.strip() # 转成string返回给result  因为write只能写string
        else:
            result = ''
        

        # 输出文件
        output_dir = 'output'
        if not os.path.exists(output_dir):
            os.mkdir(output_dir)
        filename = item.split("#")[0] + '.sol'
        filepath = os.path.join(output_dir, filename)

        with open(filepath, 'w', encoding='utf-8') as file_object:
            file_object.write(str(result))
askURL()
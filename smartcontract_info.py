from bs4 import BeautifulSoup
import urllib.request, urllib.error
import os

addresses = []
names = []
count = 0

def askURL():
    head={

        "accept-language": "en-US,en;q=0.9,zh-CN;q=0.8,zh-TW;q=0.7,zh;q=0.6",
        "cookie": "_ga=GA1.2.1393121958.1672812321; __stripe_mid=1a19efed-2ea3-4feb-9700-3435fe320ee6aab641; etherscan_cookieconsent=True; __cuid=f0ca26bfde00400a994cb6a1b6cde38a; amp_fef1e8=71f5db5f-acca-4fbd-a72e-52bb244ad811R...1go0e20a5.1go0e226l.7.4.b; ASP.NET_SessionId=5ubbzfrt1llcjhxl25101gl1; __cflb=02DiuFnsSsHWYH8WqVXaqGvd6BSBaXQLTgesADhNTXFCY; cf_chl_2=f7e2a602215e720; cf_clearance=HHtAKBRFdzw7eRs7HL506s19WH4nTflo9Vv1BWJBBTE-1683345382-0-150; __cf_bm=pqUH0NAjPwbOZfHky.eatllwT_8deEz88pr5.I0kMEI-1683347635-0-AXNryptaG2oqDWF3ApFqXWGgcFNwlUOho/9vKF5baqSmcE/E3vYEmtGcuOhSOpSLexw4Q1ESfTzdk4cObUDswDwlFYPTHMUarxX7niTh2EOl",
        "sec-ch-ua-mobile": "?0",
        "sec-ch-ua-platform": "Windows",
        "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    }

    baseURL="https://etherscan.io/contractsVerified/"
    for i in range(4,5):
        url=baseURL+str(i)
        print(url)
        request = urllib.request.Request(url,headers=head,method="GET")
        response = urllib.request.urlopen(request,timeout=30)
        html=response.read().decode("utf-8")
        Parse_html(html)

def Parse_html(html):
    bs = BeautifulSoup(html,"html.parser")
    with open("html.txt", 'w',encoding='utf-8') as file_object:
            file_object.write(str(bs))
    
    head = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"
    }

    for tr in bs.find_all('tr'): # 修改遍历的标签为tr
        name = tr.select('td:nth-of-type(2)') # 获取第二个td
        if len(name) > 0:
            names.append(name[0].text.strip()) # 添加td内文本到names列表中
        for a in tr.find_all('a', href=True):
            if 'address' in a['href']:
                addresses.append(a['href'].split('/')[-1])

    str1="https://etherscan.io/address/"
    str2="#code"

    for index, item in enumerate(addresses): # 添加索引值，以便获取对应的合约名
        url=str1+item+str2
        url = url.split("#")[0]
        request = urllib.request.Request(url, headers=head, method="GET")

        print("contract:"+url)
        response = urllib.request.urlopen(request,timeout=30)
        contract = response.read().decode("utf-8")

        ds = BeautifulSoup(contract, "html.parser")

        contract = ds.find_all(class_="js-sourcecopyarea editor")
        if len(contract) > 0:
            text = contract[0].get_text()
            result = text.strip()
        else:
            result = ''

        # 输出文件
        output_dir = 'demo2'
        if not os.path.exists(output_dir):
            os.mkdir(output_dir)
        filename = names[index] + '.sol' # 根据索引值获取对应的合约名
        filepath = os.path.join(output_dir, filename)

        with open(filepath, 'w', encoding='utf-8') as file_object:
            file_object.write(str(result))

askURL()
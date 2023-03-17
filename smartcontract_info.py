from bs4 import BeautifulSoup
import urllib.request, urllib.error
import os

addresses = []
names = []
count = 0

def askURL():
    head={
        "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"
    }

    baseURL="https://etherscan.io/contractsVerified/"
    for i in range(4,21):
        url=baseURL+str(i)
        print(url)
        request = urllib.request.Request(url,headers=head,method="GET")
        response = urllib.request.urlopen(request,timeout=30)
        html=response.read().decode("gbk")
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
        output_dir = 'output'
        if not os.path.exists(output_dir):
            os.mkdir(output_dir)
        filename = names[index] + '.sol' # 根据索引值获取对应的合约名
        filepath = os.path.join(output_dir, filename)

        with open(filepath, 'w', encoding='utf-8') as file_object:
            file_object.write(str(result))

askURL()
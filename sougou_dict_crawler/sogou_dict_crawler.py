#! /usr/bin/env python

import requests, bs4, wget, os, shutil, struct, subprocess
from typing import List

def download_dict() -> List[str]:
    sougou_dict_url_base = 'https://pinyin.sogou.com'
    sougou_dict_url = sougou_dict_url_base + '/dict/'

    html = requests.get(sougou_dict_url)

    # print(html.text)

    soup = bs4.BeautifulSoup(html.text, 'lxml')

    cate_list = { i.a.text:(sougou_dict_url_base + i.a['href']) for i in soup.find_all('div', class_='dict_category_list_title') }

    ret = []

    for cate in cate_list:
        # if cate in ['电子游戏', '人文科学', '城市信息大全', '自然科学', '社会科学', '工程与应用科学', '农林渔畜', '医学']:
        #     continue
        # if cate not in ['生活']:
        #     continue
        if not os.path.isdir(cate):
            if os.path.isfile(cate):
                os.remove(cate)
            os.mkdir(cate)
        print(f'\n\ncategory {cate}')
        cate_cnt = 0
        soup = bs4.BeautifulSoup(requests.get(cate_list[cate]).text, 'lxml')
        page = list(filter(lambda x: len(x.findChildren('a')) > 0, soup.find_all('span')))
        page = [ i.a for i in page ]
        page = list(filter(lambda x: x.text.isdigit(), page))
        page_url_base = page[-1]['href']
        page_url_base = page_url_base[:page_url_base.rfind('/')+1]
        # print(page_url_base)
        page = max([int(i.text) for i in page])
        for i in range(1, page+1):
            print(f'\n\npage{i}')
            page_url = sougou_dict_url_base + page_url_base + str(i)
            soup = bs4.BeautifulSoup(requests.get(page_url).text, 'lxml')
            dict_list = soup.find_all('div', class_='dict_detail_block odd') \
                        + soup.find_all('div', class_='dict_detail_block')
            dl_links = { d.div.div.a.text:d.contents[3].contents[3].a['href'] for d in dict_list }
            for dl in dl_links:
                # if dl == '玻璃熔窑词汇':
                #     print('wow')
                tmp = dl.replace('/', '_').replace(' ', '_')
                file_name = f'{cate}/{tmp}.scel' if '/' in dl or ' ' in dl else f'{cate}/{dl}.scel'
                if not os.path.isfile(file_name):
                    print(f'\nDownloading {dl}.scel')
                    wget.download(dl_links[dl], out=file_name)
                    cate_cnt += 1
                # print(f'\n\nhead -c9 {file_name}\n\n')
                if '<!DOCTYPE' == subprocess.getoutput(f'head -c9 {file_name}'):
                    os.remove(file_name)
                    print(f'ignore and remove {file_name}')
                    cate_cnt -= 1
        print(f'\n\ncategory {cate} downloaded {cate_cnt}')
        ret.append(cate)
    
    return ret


PYT_OFFSET = 0x1540;
WT_OFFSET = 0x2628;

pinyin_table = {}
word_table = []

def byte2str(data):
    pos = 0
    str = ''
    while pos+1 < len(data):
        c = chr(struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0])
        if c != chr(0):
            str += c
        pos += 2
    return str

def getPyTable(data):
    data = data[4:]
    pos = 0
    pyt = {}
    while pos < len(data):
        index = struct.unpack('H', bytes([data[pos],data[pos + 1]]))[0]
        pos += 2
        lenPy = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]
        pos += 2
        py = byte2str(data[pos:pos + lenPy])
        pyt[index] = py
        pos += lenPy

    return pyt

def getWordPy(data):
    pos = 0
    ret = ''
    while pos + 1 < len(data):
        index = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]
        if index in pinyin_table:
            ret += pinyin_table[index]
        pos += 2
    return ret

def getChinese(data):
    pos = 0
    while pos < len(data):
        # 同音词数量
        same = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]

        # 拼音索引表长度
        pos += 2
        py_table_len = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]

        # 拼音索引表
        pos += 2
        if pos + py_table_len >= len(data):
            break
        py = getWordPy(data[pos: pos + py_table_len])


        # 中文词组
        pos += py_table_len
        for i in range(same):
            if pos + 1 >= len(data):
                return
            # 中文词组长度
            c_len = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]
            # 中文词组
            pos += 2
            word = byte2str(data[pos: pos + c_len])
            # 扩展数据长度
            pos += c_len
            if pos + 1 >= len(data):
                return
            ext_len = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]
            # 词频
            pos += 2
            count = struct.unpack('H', bytes([data[pos], data[pos + 1]]))[0]

            # 保存
            word_table.append((count, py, word))

            # 到下个词的偏移位置
            pos += ext_len

def scel2txt(file_name):
    # 分隔符
    print('-' * 60)
    # 读取文件
    with open(file_name, 'rb') as f:
        data = f.read()
    print(file_name)
    print("词库名：", byte2str(data[0x130:0x338])) # .encode('GB18030')
    print("词库类型：", byte2str(data[0x338:0x540]))
    print("描述信息：", byte2str(data[0x540:0xd40]))
    print("词库示例：", byte2str(data[0xd40:PYT_OFFSET]))

    pinyin_table = getPyTable(data[PYT_OFFSET:WT_OFFSET])
    getChinese(data[WT_OFFSET:])

if __name__ == '__main__':
    # in_path = ['人文科学', '城市信息大全', '自然科学', '生活', '艺术', '运动休闲', '电子游戏', '娱乐', '农林渔畜', '工程与应用科学', '社会科学', '医学']
    
    in_path = download_dict()
    for each in in_path:
        for f in [fname for fname in os.listdir(each) if fname[-5:] == ".scel"]:
            f = os.path.join(each, f)
            with open(f, 'rb') as fp:
                data = fp.read()
            print(f)
            scel2txt(f)

    with open('./sogou_dict.txt', 'w') as f:
        for count, py, word in word_table:
            f.write(str(count)+ '\t\t\t' + py + '\t\t\t' + word + '\n')


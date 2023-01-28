## 搜狗词库爬虫+合并scel文件

- 爬虫，下载，分类存放
- 将scel文件合并成一个, 存放成txt
- scel格式
    | 字段 | offset |
    | ------ | -----|
    | 词库名 | 0x130 |
    | 词库类型 | 0x338 |
    | 描述信息 | 0x540 |
    | 词库示例 | 0xd40 |
    | 拼音表 | 0x1540 |
    | 中文词组表 | 0x2628 |
    - 编码utf-16
    - 拼音表由这样的元组序列构成：
        (index,len,pinyin)
        - index: 两个字节的整数 代表这个拼音的索引
        - len: 两个字节的整数 拼音的字节长度
        - pinyin: 拼音，每个字符两个字节，总长len
    - 中文词组表由这样的元组序列构成：
        (same,py_table_len,py_table,{word_len,word,ext_len,ext})
        - same: 两个字节 整数 同音词数量
        - py_table_len: 两个字节 整数 py_table的字节数
        - py_table: 整数列表，每个整数两个字节，每个整数代表一个拼音的索引
        - {word_len,word,ext_len,ext} 一共重复same次 同音词 相同拼音表
        - word_len:两个字节 整数 代表中文词组字节数长度
        - word: 中文词组,每个中文汉字两个字节，总长word_len
        - ext_len: 两个字节 整数 代表扩展信息的长度，好像都是10
        - ext: 扩展信息 前两个字节是一个整数(不知道是不是词频) 后八个字节好像全是0
- 感谢https://github.com/CQiang27/Spark_Python/blob/master/scel_TR_txt.ipynb
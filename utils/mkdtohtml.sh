#!/bin/bash

src=$1
dst=$2
if [ ! `which pandoc` ];then
    echo "Can't find pandoc command"
    exit
fi
# pandoc选项
PANDOC_FLAG=" --toc" # 自动生成目录
PANDOC_FLAG+=" --css=%WIKI_TOPDIR%style.css" # 指名css样式文件.
PANDOC_FLAG+=" --template=temp_pandoctpl.html" # pandoc模板.
PANDOC_FLAG+=" --tab-stop=4"
PANDOC_FLAG+=" --include-in-header temp_head_keywords.html" # 临时文件, 用于<head>的关键字标签.
PANDOC_FLAG+=" --include-in-header pageframe/head_statistic.html" # 百度统计
PANDOC_FLAG+=" --include-before-body pageframe/header.html"
PANDOC_FLAG+=" --include-before-body temp_title.html"
#PANDOC_FLAG+" --include-after-body pageframe/right_side.html" # 测边栏, 我目前没加, 可以预留以后放放广告啥的.
PANDOC_FLAG+=" --include-after-body pageframe/footer.html"

# 预处理
touch temp_head_keywords.html temp_title.html # 生成临时文件
sed -n -e "1,2s/<!---title:\(.*\)-->/<title>\1<\/title>/p" $src > temp_head_keywords.html # 生成<head>中的标题标签
sed -n -e "1,2s/<!---keywords:\(.*\)-->/<meta name=\"keywords\" content=\"\1\">/p" $src >> temp_head_keywords.html # 生成<head>中的关键字标签
sed -n -e "1,2s/<!---title:\(.*\)-->/<h1>\1<\/h1>/p" $src > temp_title.html # 生成<body>中的标题标签<h1>
cp utils/pandoctpl.html temp_pandoctpl.html
# WIKI_TOPDIR替换为相对地址 {{{
relative_dir=""
#delete readlink
if [ "${src:0:1}" = "/" ];then
    dst_dir=`dirname $src`
else
    dst_dir="`pwd`"/"`dirname $src`"
fi

while [ "`dirname ${dst_dir}`" != "${PWD}" ]
do
    relative_dir=${relative_dir}../
    dst_dir=`dirname ${dst_dir}`
done
#sed -i -e "s,%WIKI_TOPDIR%,${relative_dir},g" temp_pandoctpl.html
#for mac
sed -i '' 's,%WIKI_TOPDIR%,${relative_dir},g' temp_pandoctpl.html
# }}}

# pandoc转换
pandoc ${PANDOC_FLAG} --from=markdown --to=html ${src} -o $dst # 调用pandoc编译

# 后处理
#sed -i -e 's/<a href="#TOC">\(.\+\)<\/a>/\1/g' $dst # 去掉pandoc产生的从标题向目录的链接
#for mac
sed -i '' 's/<a href="#TOC">\(.\+\)<\/a>/\1/g' $dst # 去掉pandoc产生的从标题向目录的链接
#rm -f temp_head_keywords.html temp_title.html temp_pandoctpl.html # 删除临时文件


WIKI=$(shell find -name "*.md") # 从本路径向下查找所有.md作为源文件
HTML=$(WIKI:%.md=%.html) # 将.md的同名.html文件作为目标文件
Q_HTML=$(WIKI:%.md="%.html")  #加上双引号是因为目标文件中有特殊字符  比如:导航网格寻路C++实现版(入门级).md 中的括号。$< %@加双引号也是如此


# pandoc选项
PANDOC_FLAG=  --toc  --toc-depth=4 # 自动生成目录
PANDOC_FLAG+= --css="style.css" # 指名css样式文件.
PANDOC_FLAG+= --template=./template/pandoctpl.html # pandoc模板.
PANDOC_FLAG+= --tab-stop=4
PANDOC_FLAG+= --include-in-header temp_head_keywords.html # 临时文件, 用于<head>的关键字标签.
PANDOC_FLAG+= --include-before-body=./template/header.html
PANDOC_FLAG+= --include-before-body temp_title.html
#PANDOC_FLAG+--include-after-body right_side.html # 测边栏, 我目前没加, 可以预留以后放放广告啥的.
PANDOC_FLAG+= --include-after-body ./template/footer.html

# 伪目标
.PHONY:
	clean all check




# 总目标
all:$(HTML)

# 每个html的编译规则
%.html:%.md ./template/header.html ./template/footer.html makefile ./template/pandoctpl.html
	@echo "Making $@"
	@touch temp_head_keywords.html temp_title.html # 生成临时文件
	@sed -n -e "s/<!---title:\(.\+\)-->/<title>\1<\/title>/p" "$<" > temp_head_keywords.html # 生成<head>中的标题标签
	@sed -n -e "s/<!---keywords:\(.\+\)-->/<meta name=\"keywords\" content=\"\1\">/p" "$<" >> temp_head_keywords.html # 生成<head>中的关键字标签
	@sed -n -e "s/<!---title:\(.\+\)-->/<h1>\1<\/h1>/p" "$<" > temp_title.html # 生成<body>中的标题标签<h1>
	@pandoc $(PANDOC_FLAG) --from=markdown --to=html "$<" -o "$@" # 调用pandoc编译
	@rm -f temp_head_keywords.html temp_title.html # 删除临时文件
	@./template/getstyle.sh "$@" # 将/改为相对路径, 纯粹为了github而添加, 如果其他发布服务器的/即是wiki的根, 则不需要这句.

# 检查无效链接
check:
	./checkinvalidlink.sh





clean:
	@rm $(Q_HTML) -f

test:
	@echo "WIKI=============="
	@echo $(WIKI)
	@echo "HTML=============="
	@echo $(HTML)
	@echo "Q_HTML=============="
	@echo $(Q_HTML)
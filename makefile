
WIKI=$(shell find . -name "*.mkd") # 从本路径向下查找所有.mkd作为源文件
HTML=$(WIKI:%.html.mkd=%.html) # 将.mkd的同名.html文件作为目标文件

# 伪目标
.PHONY:
	clean all check

# 总目标
all:$(HTML)

# 每个html的编译规则
%.html:%.html.mkd  pageframe/header.html pageframe/footer.html pageframe/footer_statistic.html makefile utils/pandoctpl.html utils/mkdtohtml.sh
	@echo "\033[32mMaking $@\033[0m"
	@utils/mkdtohtml.sh $< $@ utils/pandoctpl.html

# 检查无效链接
check:
	utils/checkinvalidlink.sh





clean:
	@rm $(HTML) -f

#!/bin/bash
##############################################################
# File Name: /server/scripts/get_web02.sh
# Version: V1.0
# Author: x anyu
# Organization: 1915530614@qq.com
# Created Time :2017-12-04 10:43:27
# Description:get_web02
##############################################################
#列表页面起始位置
url=http://blog.51cto.com/oldboy/p1
#链接-标题-时间-存放目录
base=/application/nginx/html/monitor/list
#链接-标题-时间-存放 最终html生成页面存放位置
path=${base}/test.html
#下载网站列表页面网页
opt=/opt
#本地数据临时缓存
tmp=/tmp
#标题缓存
title_tmp=""
#时间缓存
time_tmp=""
#链接缓存
link_tmp=""
#基础链接
base_url="http://blog.51cto.com/oldboy/"
#check test.html 
function check_dir(){
		[ ! -d "${base}" ] &&{
			mkdir -p "${base}"
		}
		[ ! -f "${path}" ] && {
			echo '<meta http-equiv=Content-Type content="text/html;charset=utf-8">' >>"${path}"
		}
}
#download the web page from 1 to 29 ,find  ${opt}
function download_list_page(){
	for i in {1..29}; do
		[ ! -f ${opt}/p${i}.html ] &&{
			curl -o ${opt}/p${i}.html http://blog.51cto.com/oldboy/p${i}
		}
	done
}
#
function read_local_web_page(){

			html=$1

			[ ! -f "${html}" ] &&{
				echo "${html} is not exits!"
				exit;
			}
		#link
		link=`grep "blog_id" -A 5  $html|sed -rn 's#(.*)blog_id="(.*)">(.*)</p>#\2#gp';`

		#time
		time=`grep "发布于" -A 5  $html| sed -rn 's#(.*)发布于：(.*)</a>#\2#g'p`

		#title
		title=`grep 'class="tit" href="http://blog.51cto.com/oldboy/' -A 1 $html | sed -rn 's#(<span.*span>)?(.*)(.*)</a>#\2@#gp'`
		title=${title//<span class=\"jian\">荐<\/span>/}
		title=${title//<span class=\"ding\">置顶<\/span>/}
		# echo $title;
		# grep '<a href="javascript:;" class="con">' -B 1  $html|wc -l





		num=`echo $link|xargs -n1 |wc -l`
		time=${time//天前/00:00:00}
		echo $time  |xargs -n2  > ${tmp}/time.txt
		echo $link  | xargs -n1  > ${tmp}/link.txt
		echo $title | xargs -d '@' -n1  > ${tmp}/title.txt
		# echo $title| xargs -d '@' -n1 ;

		# echo $title| xargs -d '@' -n1 | wc -l >>${path} ;
		# echo $html"<br>" >>${path};

		for (( i = 1; i < ${num}; i++ )); do
			title_tmp=`sed -n "$(echo $i)p" ${tmp}/title.txt`
			time_tmp=`sed -n "$(echo $i)p" ${tmp}/time.txt`
			link_tmp=`sed -n "$(echo $i)p" ${tmp}/link.txt`
			echo $time_tmp '<a href="'$base_url$link_tmp'">' $title_tmp "</a><br>" >>${path}
		done
		: '
		echo $link | awk '{print $1}'
		echo $time | awk '{print $1}'
		echo $title | awk '{print $1}'
		'

}
function main(){
		# rm -f "${path}"
		check_dir
		download_list_page
		 # read_local_web_page /opt/p28.html
		 # : '
		for i in {1..29}; do
			[  -f ${opt}/p${i}.html ] &&{
				read_local_web_page ${opt}/p${i}.html
			}
		done
		 # '
}
main
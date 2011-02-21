#!/bin/bash
mv includefile includefile.old
cat includefile.old | sed -e "s/^[.]\///g" | sed -e "s/[.]bet$//" | sed -e ":again" -e "s/[^/.]\+\/[.][.]\///" -e "t again" > includefile
mv bodyfile bodyfile.old
cat bodyfile.old | sed -e "s/^[.]\///g" | sed -e "s/[.]bet$//" | sed -e ":again" -e "s/[^/.]\+\/[.][.]\///" -e "t again" > bodyfile
mv originfile originfile.old
cat originfile.old | sed -e "s/^[.]\///g" | sed -e "s/[.]bet$//" | sed -e ":again" -e "s/[^/.]\+\/[.][.]\///" -e "t again" > originfile
rm includefile.old bodyfile.old originfile.old
echo "graph: {" > graph.gdl
echo -e "layoutalgorithm: dfs
splines: yes
colorentry 42: 255 0 0
colorentry 43: 0 255 0
colorentry 44: 0 0 255
finetuning: yes
nearedges: yes" >> graph.gdl
echo >> graph.gdl
for a in `cat bodyfile originfile includefile | sort | uniq`; do echo "node: { title: \"$a\" }" >> graph.gdl; done
echo >> graph.gdl
echo "edge.arrowsize:7" >> graph.gdl
echo "edge.thickness:4" >> graph.gdl
echo "edge.color:42" >> graph.gdl
echo >> graph.gdl
i="1"
for a in `cat originfile`; do
	if [ "$i" = "1" ]; then
		echo -ne "backedge: { sourcename: \"$a\" " >> graph.gdl; i="0";
	else
		echo "targetname: \"$a\" }" >> graph.gdl; i="1";
	fi
done
echo >> graph.gdl
echo "edge.thickness:2" >> graph.gdl
echo "edge.color:43" >> graph.gdl
echo >> graph.gdl
for a in `cat includefile`; do
	if [ "$i" = "1" ]; then
		echo -ne "edge: { sourcename: \"$a\" " >> graph.gdl; i="0";
	else
		echo "targetname: \"$a\" }" >> graph.gdl; i="1";
	fi
done
echo >> graph.gdl
echo "edge.thickness:1" >> graph.gdl
echo "edge.color:44" >> graph.gdl
echo >> graph.gdl
for a in `cat bodyfile`; do
	if [ "$i" = "1" ]; then
		echo -ne "edge: { sourcename: \"$a\" " >> graph.gdl; i="0";
	else
		echo "targetname: \"$a\" }" >> graph.gdl; i="1";
	fi
done
echo >> graph.gdl
echo "}" >> graph.gdl

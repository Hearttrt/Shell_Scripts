
## cameras_id_to_usb_yml.sh
目的是减少重复的敲代码工作，可以自动获取已有的摄像头id并生成gui所需要的配置文件；并可以注释相应的抠像相机id；

### 现状
公司外采项目采用手动输入指令获取相机id并保存到配置文件，实施手动输入经常会发生一些人为错误，为解决该问题并提高效率。

### 分析
1）获取相机id的指令输出结果，可以使用linux的grep匹配指定字段来做文章;  
2）注释yml字段，就使用grep定位指定行，并添加`#`;  
3）其他一些重复输入命令就直接写入sh选择执行，避免重复劳动;  

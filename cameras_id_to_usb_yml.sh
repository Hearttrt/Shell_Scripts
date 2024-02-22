#!/bin/bash
# by 0.0
# 20231212
# v1: 生成usb.yml 
# 真机使用请取消注释第118-121行

# =============测试字符串=============
# camera_id="
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0002-video-index0 -> ../../video4
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0002-video-index1 -> ../../video5
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0003-video-index0 -> ../../video6
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0003-video-index1 -> ../../video7
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0004-video-index0 -> ../../video8
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0004-video-index1 -> ../../video9
# lrwxrwxrwx 1 root root 13 12月  8 10:13 usb-xxxxxxx_U3_0005-video-index0 -> ../../video10
# lrwxrwxrwx 1 root root 13 12月  8 10:13 usb-xxxxxxx_U3_0005-video-index1 -> ../../video11
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0021-video-index0 -> ../../video0
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-xxxxxxx_U3_0021-video-index1 -> ../../video1
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-SunplusIT_Inc_UC70-2_UC7002-video-index0 -> ../../video2
# lrwxrwxrwx 1 root root 12 12月  8 10:13 usb-SunplusIT_Inc_UC70-2_UC7002-video-index1 -> ../../video3
# lrwxrwxrwx 1 root root 13 12月  8 10:13 usb-SunplusIT_Inc_UC70_7UC20230327V01-video-index0 -> ../../video12
# lrwxrwxrwx 1 root root 13 12月  8 10:13 usb-SunplusIT_Inc_UC70_7UC20230327V01-video-index1 -> ../../video13
# "

# =============定义常量CONST=============
# yml 前面默认字段
YML_HEAD="%YAML 1.2
---
type: usb
scene: xxxxxx
seq: seq

sync_min: 20
sync_max: 75
cameras:"

# mocapdocker路径
MOCAP_PATH="$HOME/mocapdockercompose"
# usb.yml 路径
CAMREAS_YML_PATH="$MOCAP_PATH/config/sources"
CAMREAS_YML_NAME="usb.yml"
TEMP_YML_NAME="final_usb.yml"
# entri & intri 路径
REPLACE1_PATH="$MOCAP_PATH/data/xxxxxx/usb"
EXTRI_NAME="extri.yml"
INTRI_NAME="intri.yml"
# gui路径
GUI_PATH="$HOME/Downloads/gui"
# ultralytics 路径
ULTRALYTICS_PATH="$HOME/Downloads/ultralytics"
# 变量
num_main_cameras=()
final_usb=$camera_dict

# =============定义自定义行函数=============
# 定义自定义函数：备份文件
backup_file() {
  local path="$1"
  local filename="$2"
  local prefix="$3"
  local option_number="$4"
  if [ -e "$path/$filename" ]; then
      local timestamp=$(date +"%Y%m%d%H%M%S")
      # 文件存在，执行备份操作
      backup_file="$prefix.$filename.$timestamp"
      cp "$path/$filename" "$path/$backup_file"
      echo ">> [Logging][$option_number][Backup]: Completed: $path/$filename has been backed up to $backup_file"
  else
      # 文件不存在，显示消息
      echo ">> [Logging][$option_number][Error]: File not found: $filename does not exist in $path"
  fi
}

# 定义自定义函数：找到指定keyword并注释对应的行数
add_comment_to_line() {
  local keyword=$1
  local file_path=$2
  local camrea_index=$3

  line_number=$(grep -n "$keyword" "$file_path" | awk -F':' '{print $1}')
  # 使用 sed 命令在指定行添加注释
  sed -i "$((line_number + camrea_index + 1))s|^|# |" "$file_path"
}

model_(){
  local i=$1
  local name=$2
  local keyword=$3
  local camera_model="
  - name: \"$i\"
    path: \"/dev/v4l/by-id/$name\"
    height: 1080
    width: 1920
    fps: 30
    mirroring: 0
    fourcc: \"MJPG\"
  "
  local comment_model="
  # - name: \"$i\"
  #   path: \"/dev/v4l/by-id/$name\"
  #   height: 1080
  #   width: 1920
  #   fps: 30
  #   mirroring: 0
  #   fourcc: \"MJPG\"
  "
  if [ "$keyword" == "1" ]; then
    echo "$camera_model"
  else 
    echo "$comment_model"
  fi
}

# =============获取当前的摄像头列表=============
# 测试
camera_list_str=$(echo "$camera_id" | grep 'usb-.*-index0' | awk '{print $9}')

# 真机使用
echo ">> Logging: Get the list of the cameras."
camera_list_str=$(echo "$(ls -l /dec/v4l/by-id)" | grep 'usb-.*-index0' | awk '{print $9}')
echo "$camera_list_str"

# =============开始=============
echo "=============================================================================="
echo "|                                                                            |"
echo "| ███████╗████████╗ █████╗ ██████╗ ████████                                  |"
echo "| ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗╚══██╔══╝                                 |"
echo "| ███████╗   ██║   ███████║██████╔╝   ██║                                    |"
echo "| ╚════██║   ██║   ██╔══██║██╔══██╗   ██║                                    |"
echo "| ███████║   ██║   ██║  ██║██║  ██║   ██║                                    |"
echo "| ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   by0.0                            |"
echo "|                                                                            |"
echo "| >> The shell is designed to help engineers in quickly modifying            |"
echo "|  configurations.                                                           |"
echo "|                                                                            |"
echo "| 1. Get IDs&names of all cameras and generate usb.yml.                      |" 
echo "| 2. Starting GUI.                                                           |"
echo "| 3. Copy REPLACE1_PATH/*.yml to target path.                                  |"
echo "| 4. Conceal the IDs and names of the main camera in the usb.yml.            |"
echo "| 5. Conceal the IDs and names of the main camera in the ***tri.yml          |"  
echo "| 6. Specify the index number of the Nvidia.                                 |"
echo "| 7. Starting docker mocap.                                                  |"
echo "| 8. Starting ultralytics.                                                   |"
echo "=============================================================================="
while true; do
  # ============= 获取相机列表并组合成yml格式 =============
  # 生成相机数组, 为后面的循环使用
  for camera in $camera_list_str; do
      camera_list+=("$camera") 
      if echo "$camera" | grep -q 'usb-SunplusIT.*-index0'; then
        echo ">> [Logging][Get Main Cameras ID]: $camera"
      else
        echo ">> [Logging][Get Auxiliary Cameras ID]: $camera"
      fi
  done
  echo ">> [Logging][The number of cameras]: ${#camera_list[@]}"
  for ((i=0; i<${#camera_list[@]}; i++)); do
    result=$(model_ "$i" "${camera_list[i]}" "1")
    camera_dict+=$result
    if echo "${camera_list[i]}" | grep -q 'usb-SunplusIT.*-index0'; then
      result2=$(model_ "$i" "${camera_list[i]}" "2")
      num_main_cameras+=("$i")
    else
      result2=$(model_ "$i" "${camera_list[i]}" "1")
    fi
    final_usb+=$result2
  done
  echo "------------------------------------------------------------------------------"
  read -p ">> Please enter the number: " choice

  case $choice in
    1) # 获取摄像头配置自动生成文件
      backup_file "$CAMREAS_YML_PATH" "$CAMREAS_YML_NAME" "Backup" "1"
      # 覆盖写入 并替换原来的usb.yml
      camera_dict="${YML_HEAD}${camera_dict}"
      final_usb="${YML_HEAD}${final_usb}"
      echo "$camera_dict" > "$CAMREAS_YML_PATH/$CAMREAS_YML_NAME"
      echo "$final_usb" > "$CAMREAS_YML_PATH/$TEMP_YML_NAME"
      echo ">> [Logging][1][Save]: Save the new $CAMREAS_YML_NAME & $TEMP_YML_NAME to target path."
      ;;
    2) # 启动gui
      if [ -x "$GUI_PATH" ]; then
        # 执行文件
        echo ">> [Logging][2][Calibration]: Starting GUI. Please calibrate."
        sudo "$GUI_PATH"
      else
        echo ">> [Logging][2][Error]: gui file not exist or permission issuses: $GUI_PATH"
      fi
      ;;
    3) # 对文件提权，拷贝到指定文件夹
      echo ">> [Logging][3][Copy]: Copy the $REPLACE1_PATH/*.yml to $ULTRALYTICS_PATH/cam_params/"
      sudo chmod 777 "$REPLACE1_PATH"/*.yml # 通配符不需要""
      cp "$REPLACE1_PATH"/*.yml "$ULTRALYTICS_PATH/cam_params/"
      ;;
    4) # 注释 抠像摄像头
      echo ">> [Logging][4][Backup]: Backup the usb.yml to usb.yml.backup.timestamp."
      backup_file "$CAMREAS_YML_PATH" "$CAMREAS_YML_NAME" "Comment" "4"
      echo ">> [Logging][4][Move]: Move the $TEMP_YML_NAME to $CAMREAS_YML_NAME"
      mv "$CAMREAS_YML_PATH/$TEMP_YML_NAME" "$CAMREAS_YML_PATH/$CAMREAS_YML_NAME"
      ;;
    5) # [手动]: 注释内外参数摄像头索引号
      echo ">> [Logging][5][Comment]: Comment the extri.yml and intri.yml"
      backup_file "$REPLACE1_PATH" "$EXTRI_NAME" "Backup" "5"
      backup_file "$REPLACE1_PATH" "$INTRI_NAME" "Backup" "5"
      keyword="names:"
      add_comment_to_line "$keyword" "$REPLACE1_PATH/$EXTRI_NAME" "${num_main_cameras[0]}"
      add_comment_to_line "$keyword" "$REPLACE1_PATH/$EXTRI_NAME" "${num_main_cameras[1]}"
      add_comment_to_line "$keyword" "$REPLACE1_PATH/$INTRI_NAME" "${num_main_cameras[0]}"
      add_comment_to_line "$keyword" "$REPLACE1_PATH/$INTRI_NAME" "${num_main_cameras[1]}"
      ;;
    6) # 指定显卡索引号
      # TODO: 
      echo ">> [Logging][6][TBD]:: 大哥们先手动改改"
      nvidia-smi 
      ;;
    7) # 启动动补程序 TBD
      echo ">> [Logging][7][Startup]: Starting docker mocap."
      cd "$MOCAP_PATH/"
      echo "docker compose -f mocap_usb.yml up"
      ;;
    8) # 启动抠像程序
      echo ">> [Logging][8][Startup]: Starting ultralytics."
      cd "$ULTRALYTICS_PATH/"
      # 示例 element="${array2[$index]}"
      maincamera_0="${num_main_cameras[0]}"
      maincamera_1="${num_main_cameras[1]}"
      maincamera_0_name="/dev/v4l/by-id/${camera_list[$maincamera_0]}"
      maincamera_1_name="/dev/v4l/by-id/${camera_list[$maincamera_1]}"
      echo "CUDA_VISIBLE_DEVICES=0 python test_server_xxxxxx.py -n $maincamera_0 -i $maincamera_0_name 8888"
      echo "CUDA_VISIBLE_DEVICES=0 python test_server_xxxxxx.py -n $maincamera_1 -i $maincamera_1_name 8889"
  esac
  echo "=============================================================================="
  camera_list=()
  num_main_cameras=()
  final_usb=""
  camera_dict=""
done

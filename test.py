import os
import subprocess

# 批量检测的sol文件所在目录
sol_dir = "./output"

# 检测结果输出文件
output_file = "./output.txt"

# 需要检测的漏洞类型
bugs = ["reentrancy", "integer-overflow", "warn"]

# 遍历目录下的所有.sol文件
for filename in os.listdir(sol_dir):
    if filename.endswith(".sol"):
        file_path = os.path.join(sol_dir, filename)
        print(f"正在检测文件：{file_path}")
        
        # 使用Slither检测文件，并将结果输出到output_file文件中
        cmd = f"slither --disable-solc-warnings --json {file_path}"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        # 解析Slither的JSON输出，提取需要的漏洞信息
        json_output = result.stdout
        for bug in bugs:
            json_output = json_output.replace(bug, f"\n{bug}")
            
        # 将检测结果写入文件
        with open(output_file, "a") as f:
            f.write(f"sol_file: {file_path}\n\n{json_output}\n\n")
            
print("检测完成！")
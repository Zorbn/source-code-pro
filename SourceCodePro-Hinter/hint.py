import subprocess
import os
from os.path import isfile, join, splitext

in_path = "in"
out_path = "out"
control_path = "control"
out_suffix = "-Hinted"
control_suffix = "-Control"
cmd = ["./ttfautohint.exe"]

def main():
    for i in os.listdir(in_path):
        if not isfile(join(in_path, i)):
            continue

        split_i = splitext(i)
        i_name = split_i[0]
        i_ext = split_i[1]

        if i_ext != ".ttf":
            continue

        i_cmd = cmd.copy()
        
        control_file = f"control/{i_name}{control_suffix}.txt"
        
        if isfile(control_file):
            i_cmd.extend(["-m", control_file])
            print("Controlled", i)
        
        i_cmd.extend([join(in_path, i), join(out_path, f"{i_name}{out_suffix}{i_ext}")])

        subprocess.run(i_cmd)
        print("Hinted", i)

if __name__ == "__main__":
    main()

#!/bin/python3

import os
import sys
import shutil
import time

folder = sys.argv[1]
dropbox_path = os.path.expanduser("~/Dropbox/group29/")
arm_app_path = "../appARMcpu.elf"

results_path = dropbox_path + "results.txt"
log_path = dropbox_path + "log.txt"

def file_contains(path, string):
    try:
        with open(path, "r", errors="ignore") as f:
            return string in f.read()
    except UnicodeDecodeError:
        print("Decode error")
        return False

def clear_dropbox():
    try:
        os.remove(log_path)
    except OSError:
        pass
    try:
        os.remove(results_path)
    except OSError:
        pass
    try:
        os.remove(dropbox_path + "design_2_wrapper.xsa")
    except OSError:
        pass

def run_bench(subfolder):
    print("Running benchmark for: ", subfolder)

    clear_dropbox()

    shutil.copy(arm_app_path, dropbox_path)
    time.sleep(5)
    shutil.copy(subfolder + "design_2_wrapper.xsa", dropbox_path)

    while not os.path.exists(results_path):
        if os.path.exists(log_path) and file_contains(log_path, "ERROR: File appARMcpu.elf is missing"):
            print("Retrying")
            run_bench(subfolder)
            return
        time.sleep(1)

    print("Waiting for DONE to appear...")
    while not file_contains(results_path, "DONE"):
        time.sleep(1)
    shutil.copy(results_path, subfolder)
    

for sub in next(os.walk(folder))[1]:
    run_bench(folder + "/" + sub + "/")

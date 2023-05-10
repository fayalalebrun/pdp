def extract_all(folder):
    timing_path = folder + "timing_report.txt"
    utilization_path = folder + "utilization_report.txt"
    results_path = folder + "results.txt"

    return extract_util(utilization_path) | extract_wns(timing_path) | extract_results(results_path)


def extract_results(path):
    result = {}
    with open(path, "r", errors="ignore") as f:
        for line in f.readlines():
            if "Total:" in line:
                result["benchall_million_clk"] = float(line.split(':', 1)[1].strip())
            if "Total energy" in line:
                result["total_energy"] = float(line.split(' ')[-2].strip())
            if "Peak power" in line:
                result["peak_power"] = float(line.split(' ')[-2].strip())
    return result

def extract_wns(path):
    lines_since_wns = 0
    with open(path, "r", errors="ignore") as f:
        for line in f.readlines():
            if lines_since_wns == 2:
                return {"wns": float(line.strip().split(' ')[0])}
            
            if lines_since_wns >= 1:
                lines_since_wns += 1
            
            if "WNS" in line:
                lines_since_wns = 1

def extract_util(path):
    slice_num = 0
    utilization = 0.0
    with open(path, "r", errors="ignore") as f:
        for line in f.readlines():
            if "Slice" in line:
                if slice_num == 6:
                    utilization += float(line.split()[3]) * 0.5
                slice_num += 1
            if "RAMB36/FIFO" in line:
                utilization += float(line.split()[3]) * 2.4
            if "RAMB18" in line and not "RAMB18E1" in line:
                utilization += float(line.split()[3]) * 1.2
    return {"utilization": utilization}

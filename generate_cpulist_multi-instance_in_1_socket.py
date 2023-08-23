#!/usr/bin/env python3
import sys

def divide_numbers(start, end, count):
    core_num_per_partition = (end - start + 1) // count
    remainder = (end - start + 1) % count

    parts = []
    current_num = start

    for i in range(count):
        part = []
        for _ in range(core_num_per_partition):
            part.append(str(current_num))
            current_num += 1

        if remainder > 0:
            part.append(str(current_num))
            current_num += 1
            remainder -= 1

        parts.append(','.join(part))

    return '|'.join(parts)

def merge_strings(str1, str2):
    parts1 = str1.split('|')
    parts2 = str2.split('|')

    merged_parts = []
    for part1, part2 in zip(parts1, parts2):
        merged_part = part1 + ',' + part2
        merged_parts.append(merged_part)

    return '|'.join(merged_parts)

def generate_cpulist(core_per_socket, instance_count):
    str1 = divide_numbers(0, core_per_socket - 1, instance_count)
    str2 = divide_numbers(2 * core_per_socket, 3 * core_per_socket - 1, instance_count)
    cpulist = merge_strings(str1, str2)
    return cpulist

def main():
    if len(sys.argv) != 3:
        print("Usage: python generate_cpulist.py core_per_socket instance_count")
        return

    core_per_socket = int(sys.argv[1])
    instance_count = int(sys.argv[2])
    cpulist = generate_cpulist(core_per_socket, instance_count)
    print(cpulist)

if __name__ == "__main__":
    main()

# gem/core/commands/du.py

from filesystem import fs_manager
import os

def define_flags():
    """Declares the flags that the du command accepts."""
    return {
        'flags': [
            {'name': 'summarize', 'short': 's', 'long': 'summarize', 'takes_value': False},
            {'name': 'human-readable', 'short': 'h', 'long': 'human-readable', 'takes_value': False},
        ],
        'metadata': {}
    }

def _format_bytes(byte_count):
    if byte_count is None: return "0B"
    if byte_count == 0: return "0"
    power = 1024
    n = 0
    power_labels = {0: 'B', 1: 'K', 2: 'M', 3: 'G', 4: 'T'}
    while byte_count >= power and n < len(power_labels) -1 :
        byte_count /= power
        n += 1
    return f"{byte_count:.1f}{power_labels[n]}".replace(".0", "")


def run(args, flags, user_context, **kwargs):
    paths = args if args else ['.']
    is_summarize = flags.get('summarize', False)
    is_human_readable = flags.get('human-readable', False)
    output_lines = []

    for path in paths:
        node = fs_manager.get_node(path)
        if not node:
            return {
                "success": False,
                "error": {
                    "message": f"du: cannot access '{path}': No such file or directory",
                    "suggestion": "Please check that the file or directory path is correct."
                }
            }
        # Using 1024 for kilobyte calculation for block size
        size_in_kb = lambda size: (size + 1023) // 1024

        if is_summarize:
            total_size = fs_manager.calculate_node_size(path)
            size_str = _format_bytes(total_size) if is_human_readable else str(size_in_kb(total_size))
            output_lines.append(f"{size_str}\t{path}")
        else:
            sizes = []
            def recurse_du(current_path, current_node):
                if current_node.get('type') == 'directory':
                    for child_name in current_node.get('children', {}):
                        child_path = os.path.join(current_path, child_name)
                        recurse_du(child_path, current_node['children'][child_name])
                size = fs_manager.calculate_node_size(current_path)
                sizes.append((size, current_path))
            recurse_du(path, node)
            for size, p in sorted(sizes, key=lambda x: x[1]):
                size_str = _format_bytes(size) if is_human_readable else str(size_in_kb(size))
                output_lines.append(f"{size_str}\t{p}")

    return "\n".join(output_lines)

def man(args, flags, user_context, **kwargs):
    return """
NAME
    du - estimate file space usage

SYNOPSIS
    du [OPTION]... [FILE]...

DESCRIPTION
    Summarize disk usage of the set of FILEs, recursively for directories. Sizes are displayed in 1K blocks by default.

OPTIONS
    -h, --human-readable
          Print sizes in human readable format (e.g., 1K, 234M, 2G).
    -s, --summarize
          Display only a total for each argument, not for subdirectories.

EXAMPLES
    du
    du -h /home/guest
    du -sh /etc
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: du [-sh] [FILE]..."
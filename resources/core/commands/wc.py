# gem/core/commands/wc.py

from filesystem import fs_manager

def define_flags():
    """Declares the flags that the wc command accepts."""
    return {
        'flags': [
            {'name': 'lines', 'short': 'l', 'long': 'lines', 'takes_value': False},
            {'name': 'words', 'short': 'w', 'long': 'words', 'takes_value': False},
            {'name': 'bytes', 'short': 'c', 'long': 'bytes', 'takes_value': False},
        ],
        'metadata': {}
    }

def _count_content(content):
    """Calculates lines, words, and bytes for a string."""
    lines = len(content.splitlines()) if content else 0
    words = len(content.split())
    bytes_count = len(content.encode('utf-8'))
    return lines, words, bytes_count

def run(args, flags, user_context, stdin_data=None):
    show_lines = flags.get('lines', False)
    show_words = flags.get('words', False)
    show_bytes = flags.get('bytes', False)

    if not (show_lines or show_words or show_bytes):
        show_lines = show_words = show_bytes = True

    output_lines = []
    total_counts = {'lines': 0, 'words': 0, 'bytes': 0}
    has_errors = False
    error_list = []

    def format_output(lines, words, bytes_count, name=""):
        parts = []
        if show_lines: parts.append(str(lines).rjust(7))
        if show_words: parts.append(str(words).rjust(7))
        if show_bytes: parts.append(str(bytes_count).rjust(7))
        if name: parts.append(f" {name}")
        return "".join(parts)

    sources = args if args else ([] if stdin_data is None else ['stdin'])

    for source in sources:
        lines, words, bytes_count = 0, 0, 0
        if source == 'stdin':
            lines, words, bytes_count = _count_content(stdin_data)
            output_lines.append(format_output(lines, words, bytes_count))
        else:
            node = fs_manager.get_node(source)
            if not node:
                error_list.append(f"wc: {source}: No such file or directory")
                has_errors = True
                continue
            if node.get('type') == 'directory':
                error_list.append(f"wc: {source}: Is a directory")
                has_errors = True
            else:
                content = node.get('content', '')
                lines, words, bytes_count = _count_content(content)
                output_lines.append(format_output(lines, words, bytes_count, source))

            total_counts['lines'] += lines
            total_counts['words'] += words
            total_counts['bytes'] += bytes_count

    if has_errors:
        return {
            "success": False,
            "error": {
                "message": "\n".join(error_list),
                "suggestion": "Please check the file paths provided."
            }
        }

    if len(sources) > 1 and 'stdin' not in sources:
        output_lines.append(format_output(total_counts['lines'], total_counts['words'], total_counts['bytes'], "total"))

    return "\n".join(output_lines)

def man(args, flags, user_context, stdin_data=None):
    return """
NAME
    wc - print newline, word, and byte counts for each file

SYNOPSIS
    wc [OPTION]... [FILE]...

DESCRIPTION
    Print newline, word, and byte counts for each FILE, and a total line if
    more than one FILE is specified. With no FILE, or when FILE is -,
    read standard input.

OPTIONS
    -c, --bytes
          Print the byte counts.
    -l, --lines
          Print the newline counts.
    -w, --words
          Print the word counts.

EXAMPLES
    wc my_document.txt
    wc -l my_document.txt
    ls | wc -w
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: wc [OPTION]... [FILE]..."
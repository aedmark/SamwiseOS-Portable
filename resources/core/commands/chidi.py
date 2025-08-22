# gem/core/commands/chidi.py

import os
from filesystem import fs_manager
from story_manager import story_manager

SUPPORTED_EXTENSIONS = {".md", ".txt", ".html", ".js", ".sh", ".css", ".json"}

def define_flags():
    """Declares the flags that the chidi command accepts."""
    return [
        {'name': 'new', 'short': 'n', 'long': 'new', 'takes_value': False},
        {'name': 'provider', 'short': 'p', 'long': 'provider', 'takes_value': True},
        {'name': 'model', 'short': 'm', 'long': 'model', 'takes_value': True},
    ]

def _get_files_for_analysis(start_path, user_context):
    """
    Recursively finds all supported files for analysis from a starting path.
    """
    # Check if the start_path is a .story directory
    if os.path.basename(start_path) == '.story':
        summary_result = story_manager.get_story_summary(start_path)
        if summary_result["success"]:
            # Return a single pseudo-file with the story summary
            return [{
                "name": "Story Summary",
                "path": start_path,
                "content": summary_result["data"]
            }]
        else:
            return [] # Return empty if summary fails

    files = []
    visited = set()
    start_node = fs_manager.get_node(start_path)

    def recurse(current_path, node):
        if current_path in visited:
            return
        visited.add(current_path)

        if not fs_manager.has_permission(current_path, user_context, "read"):
            return

        if node.get('type') == 'file':
            _, ext = os.path.splitext(current_path)
            if ext.lower() in SUPPORTED_EXTENSIONS:
                files.append({
                    "name": os.path.basename(current_path),
                    "path": current_path,
                    "content": node.get('content', '')
                })
        elif node.get('type') == 'directory':
            # Skip .story directories during normal traversal
            if os.path.basename(current_path) == '.story':
                return
            if not fs_manager.has_permission(current_path, user_context, "execute"):
                return
            for child_name in sorted(node.get('children', {}).keys()):
                child_path = fs_manager.get_absolute_path(os.path.join(current_path, child_name))
                child_node = node['children'][child_name]
                recurse(child_path, child_node)

    if start_node:
        recurse(start_path, start_node)
    return files

def run(args, flags, user_context, stdin_data=None, **kwargs):
    """
    Gathers files and returns an effect to launch the Chidi UI.
    """
    files = []

    if stdin_data:
        paths_from_pipe = stdin_data.strip().splitlines()
        for path in paths_from_pipe:
            if not path.strip():
                continue

            node = fs_manager.get_node(path)
            if not node or node.get('type') != 'file' or not fs_manager.has_permission(path, user_context, "read"):
                continue

            _, ext = os.path.splitext(path)
            if ext.lower() in SUPPORTED_EXTENSIONS:
                files.append({
                    "name": os.path.basename(path),
                    "path": path,
                    "content": node.get('content', '')
                })
    else:
        start_path_arg = args[0] if args else "."
        start_path = fs_manager.get_absolute_path(start_path_arg)

        if not fs_manager.get_node(start_path):
            return {
                "success": False,
                "error": {
                    "message": f"chidi: {start_path_arg}: No such file or directory",
                    "suggestion": "Please check the path and try again."
                }
            }

        files = _get_files_for_analysis(start_path, user_context)

    if not files:
        return "No supported files (.md, .txt, .html, .js, .sh, .css, .json) found to open."

    provider = flags.get("provider")
    model = flags.get("model")

    return {
        "effect": "launch_app",
        "app_name": "Chidi",
        "options": {
            "initialFiles": files,
            "launchOptions": {
                "isNewSession": flags.get('new', False),
                "provider": provider,
                "model": model
            }
        }
    }

def man(args, flags, user_context, **kwargs):
    return """
NAME
chidi - Opens the Chidi AI-powered document and code analyst.

SYNOPSIS
chidi [-n] [-p provider] [-m model] [path]
<command> | chidi

DESCRIPTION
Chidi is a powerful graphical tool that leverages a Large Language
Model (LLM) to help you understand and interact with your files in SamwiseOS.
It can summarize documents, suggest insightful questions, and answer
your questions based on the content of the files you provide.
When pointed at a .story directory, Chidi will provide a narrative summary
of the project's history.
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: chidi [-n] [-p provider] [-m model] [path]"
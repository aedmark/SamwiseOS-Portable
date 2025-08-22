# gem/core/commands/rmdir.py

from filesystem import fs_manager
import os

def define_flags():
    """Declares the flags that the rmdir command accepts."""
    return {
        'flags': [
            {'name': 'parents', 'short': 'p', 'long': 'parents', 'takes_value': False},
        ],
        'metadata': {}
    }

def run(args, flags, user_context, **kwargs):
    if not args:
        return {
            "success": False,
            "error": {
                "message": "rmdir: missing operand",
                "suggestion": "You must specify at least one directory to remove."
            }
        }

    is_parents = flags.get('parents', False)

    for path in args:
        abs_path = fs_manager.get_absolute_path(path)
        try:
            node = fs_manager.get_node(abs_path)
            if not node:
                return {"success": False, "error": {"message": f"rmdir: failed to remove '{path}': No such file or directory", "suggestion": "Please check the directory path."}}
            if node.get('type') != 'directory':
                return {"success": False, "error": {"message": f"rmdir: failed to remove '{path}': Not a directory", "suggestion": "You can only use rmdir on directories."}}
            if node.get('children'):
                return {"success": False, "error": {"message": f"rmdir: failed to remove '{path}': Directory not empty", "suggestion": "Use 'rm -r' to remove non-empty directories."}}

            fs_manager.remove(abs_path)

            if is_parents:
                parent_path = os.path.dirname(abs_path)
                while parent_path != '/':
                    parent_node = fs_manager.get_node(parent_path)
                    if parent_node and not parent_node.get('children'):
                        fs_manager.remove(parent_path)
                        parent_path = os.path.dirname(parent_path)
                    else:
                        break
        except Exception as e:
            return {"success": False, "error": {"message": f"rmdir: failed to remove '{path}': {repr(e)}", "suggestion": "An unexpected error occurred. Check permissions."}}

    return ""

def man(args, flags, user_context, **kwargs):
    return """
NAME
    rmdir - remove empty directories

SYNOPSIS
    rmdir [-p] DIRECTORY...

DESCRIPTION
    Removes the DIRECTORY(ies), if they are empty.

OPTIONS
    -p, --parents
          remove DIRECTORY and its ancestors. For instance,
          `rmdir -p a/b/c` is similar to `rmdir a/b/c a/b a`.

EXAMPLES
    rmdir old_project
    rmdir -p new/empty/structure
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: rmdir [-p] DIRECTORY..."
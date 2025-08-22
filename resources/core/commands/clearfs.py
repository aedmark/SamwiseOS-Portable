# gem/core/commands/clearfs.py
import os
from filesystem import fs_manager
from datetime import datetime

def define_flags():
    """Declares the flags that the clearfs command accepts."""
    return {
        'flags': [
            {'name': 'confirmed', 'long': 'confirmed', 'takes_value': False},
        ],
        'metadata': {}
    }


def run(args, flags, user_context, **kwargs):
    """
    Clears all files and directories from the current user's home directory
    after a confirmation prompt.
    """
    if args:
        return {
            "success": False,
            "error": {
                "message": "clearfs: command takes no arguments",
                "suggestion": "Simply run 'clearfs' by itself."
            }
        }
    if flags.get('confirmed', False):
        return _perform_clear(user_context)

    username = user_context.get('name')
    if username == 'root':
        return {
            "success": False,
            "error": {
                "message": "clearfs: cannot clear the root user's home directory",
                "suggestion": "This is a safety precaution. To clear root's home, you must manually remove files with 'rm -rf'."
            }
        }
    home_path = f"/home/{username}"
    home_node = fs_manager.get_node(home_path)

    if home_node and home_node.get('type') == 'directory':
        return {
            "effect": "confirm",
            "message": [
                "WARNING: This will permanently delete all files and directories in your home folder.",
                "This action cannot be undone. Are you sure?",
            ],
            "on_confirm_command": "clearfs --confirmed"
        }
    return {"success": False, "error": {"message": "clearfs: Could not find home directory to clear.", "suggestion": f"Ensure that the directory '{home_path}' exists."}}

def _perform_clear(user_context):
    """The actual logic that runs after the user confirms."""
    username = user_context.get('name')
    home_path = f"/home/{username}"
    home_node = fs_manager.get_node(home_path)

    if home_node and home_node.get('type') == 'directory':
        home_node['children'] = {}
        home_node['mtime'] = datetime.utcnow().isoformat() + "Z"
        fs_manager._save_state()
        return "Home directory cleared."
    return {"success": False, "error": {"message": "clearfs: something went wrong after confirmation", "suggestion": "Please try the command again."}}

def man(args, flags, user_context, **kwargs):
    return """
NAME
    clearfs - Clears all files from the current user's home directory.

SYNOPSIS
    clearfs

DESCRIPTION
    Removes all files and subdirectories within the current user's home directory, resetting it to a clean slate. This is a destructive and irreversible operation that requires confirmation. For safety, this command cannot be run by the 'root' user.

OPTIONS
    This command takes no options.
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: clearfs"
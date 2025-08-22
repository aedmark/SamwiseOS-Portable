# gem/core/users.py

import base64
import os
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import copy # For deepcopy

# We need to import our other managers to collaborate!
from filesystem import fs_manager
from groups import group_manager

class UserManager:
    """Manages user accounts, credentials, and properties."""
    def __init__(self):
        self.users = {}
        # A simple list of reserved names. In a real system, this might be in a config file.
        self.RESERVED_USERNAMES = ["guest", "root", "admin", "system"]
        self.MIN_USERNAME_LENGTH = 3
        self.MAX_USERNAME_LENGTH = 20


    def initialize_defaults(self, default_username):
        """Initializes default users if they don't exist."""
        if not group_manager.group_exists('root'):
            group_manager.create_group('root')

        if 'root' not in self.users:
            self.users['root'] = {'passwordData': None, 'primaryGroup': 'root'}

        if default_username not in self.users:
            self.users[default_username] = {'passwordData': None, 'primaryGroup': default_username}

    def get_all_users(self):
        """Returns the entire users dictionary."""
        return self.users

    def load_users(self, users_dict):
        """Loads user data from a dictionary (from storage)."""
        self.users = users_dict.to_py() if hasattr(users_dict, 'to_py') else users_dict

    def user_exists(self, username):
        """Checks if a user exists."""
        return username in self.users

    def get_user(self, username):
        """Gets data for a single user."""
        return self.users.get(username)

    def has_password(self, username):
        """Checks if a user has a password set."""
        user_entry = self.get_user(username)
        return bool(user_entry and user_entry.get('passwordData'))

    def _secure_hash_password(self, password):
        """Securely hashes a password using PBKDF2 with a random salt."""
        salt = os.urandom(16)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        pwd_hash = kdf.derive(password.encode('utf-8'))
        return {'salt': salt.hex(), 'hash': pwd_hash.hex()}

    def _verify_password_with_salt(self, password_attempt, salt_hex, stored_hash_hex):
        """Verifies a password attempt against a stored salt and hash."""
        salt = bytes.fromhex(salt_hex)
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        try:
            kdf.verify(password_attempt.encode('utf-8'), bytes.fromhex(stored_hash_hex))
            return True
        except Exception:
            return False

    def register_user(self, username, password, primary_group):
        """Creates a new user account."""
        if self.user_exists(username):
            return {"success": False, "error": f"User '{username}' already exists."}

        password_data = self._secure_hash_password(password) if password else None
        self.users[username] = {'passwordData': password_data, 'primaryGroup': primary_group}
        return {"success": True, "user_data": self.users[username]}

    def remove_user(self, username):
        """Removes a user account."""
        if self.user_exists(username):
            del self.users[username]
            return True
        return False

    def verify_password(self, username, password_attempt):
        """Verifies a user's password."""
        user_entry = self.get_user(username)

        if not user_entry:
            return False # User doesn't exist

        password_data = user_entry.get('passwordData')

        # Case 1: User has no password set (e.g., Guest).
        if not password_data:
            # If no password is set, only an empty or null attempt is valid.
            return password_attempt is None or password_attempt == ""

        # Case 2: User has a password, but none was provided in the attempt.
        # This now explicitly checks for an empty string as well.
        if password_attempt is None or password_attempt == "":
            return False

        # Case 3: Root must have a password after onboarding. This is a redundant
        # safety check, as `password_data` would exist, but it's good practice.
        if username == 'root' and not password_data:
            return False

        # Case 4: A password is set, and an attempt was made. Verify it.
        salt = password_data['salt']
        stored_hash = password_data['hash']
        return self._verify_password_with_salt(password_attempt, salt, stored_hash)

    def change_password(self, username, new_password):
        """Changes a user's password."""
        if not self.user_exists(username):
            return False

        new_password_data = self._secure_hash_password(new_password)
        self.users[username]['passwordData'] = new_password_data
        return True

    def validate_username_format(self, username):
        """Validates a new username against system rules."""
        if not isinstance(username, str) or not username.strip():
            return {"success": False, "error": "Username cannot be empty."}
        if ' ' in username:
            return {"success": False, "error": "Username cannot contain spaces."}
        if username.lower() in self.RESERVED_USERNAMES:
            return {"success": False, "error": f"Cannot use '{username}'. This username is reserved."}
        if len(username) < self.MIN_USERNAME_LENGTH:
            return {"success": False, "error": f"Username must be at least {self.MIN_USERNAME_LENGTH} characters long."}
        if len(username) > self.MAX_USERNAME_LENGTH:
            return {"success": False, "error": f"Username cannot exceed {self.MAX_USERNAME_LENGTH} characters."}
        return {"success": True}

    def delete_user_and_data(self, username, remove_home):
        """
        Securely deletes a user, removes them from all groups,
        and optionally deletes their home directory. This is the new
        centralized function for user removal.
        """
        if not self.user_exists(username):
            return {"success": False, "error": f"User '{username}' does not exist."}
        if username == 'root':
            return {"success": False, "error": "Cannot remove the root user."}

        try:
            # Remove from all groups
            group_manager.remove_user_from_all_groups(username)

            # Remove home directory if requested
            if remove_home:
                home_path = f"/home/{username}"
                if fs_manager.get_node(home_path):
                    fs_manager.remove(home_path, recursive=True)

            # Finally, remove the user account itself
            self.remove_user(username)

            # Important: Save the state of the filesystem after potential deletion
            fs_manager._save_state()

            return {"success": True}
        except Exception as e:
            # In a real system, we'd have a transaction to roll back group/file changes
            # if the final user deletion failed. For now, we report the error.
            return {"success": False, "error": f"An error occurred during deletion: {str(e)}"}

    def first_time_setup(self, username, password, root_password):
        """
        Performs the initial system setup in a transactional manner.
        """
        # Backup state for rollback
        original_users = copy.deepcopy(self.users)
        original_groups = copy.deepcopy(group_manager.groups)
        original_fs_data = copy.deepcopy(fs_manager.fs_data)

        try:
            # 1. Initialize the default filesystem structure
            fs_manager._initialize_default_filesystem()

            # 2. Ensure root group and user exist before anything else
            if not group_manager.group_exists('root'):
                group_manager.create_group('root')
            if not self.user_exists('root'):
                self.register_user('root', None, 'root')

            if not group_manager.group_exists('Guest'):
                group_manager.create_group('Guest')
            if not self.user_exists('Guest'):
                self.register_user('Guest', None, 'Guest')

            # 4. Create the new user's group
            if not group_manager.group_exists(username):
                group_manager.create_group(username)

            # 5. Register the new user
            registration_result = self.register_user(username, password, username)
            if not registration_result["success"]:
                if "already exists" not in registration_result["error"]:
                    raise ValueError(registration_result["error"])

            # 6. Add the user to their own primary group
            group_manager.add_user_to_group(username, username)

            # 7. Create the user's home directory as root
            home_path = f"/home/{username}"
            if not fs_manager.get_node(home_path):
                fs_manager.create_directory(home_path, {"name": "root", "group": "root"})
                fs_manager.chown(home_path, username)
                fs_manager.chgrp(home_path, username)

            # 8. Set the root password
            if not self.change_password('root', root_password):
                raise ValueError("Failed to set root password during setup.")

            # 9. Persist changes to the filesystem
            fs_manager._save_state()

            return {
                "success": True,
                "data": {
                    "users": self.get_all_users(),
                    "groups": group_manager.get_all_groups()
                }
            }
        except Exception as e:
            # Rollback to original state on any failure
            self.users = original_users
            group_manager.groups = original_groups
            fs_manager.fs_data = original_fs_data

            return {"success": False, "error": f"An error occurred during setup: {str(e)}"}

user_manager = UserManager()
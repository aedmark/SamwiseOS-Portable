# gem/core/commands/kill.py

def define_flags():
    """Declares the flags that the kill command accepts."""
    return {
        'flags': [
            {'name': 'signal', 'short': 's', 'long': 'signal', 'takes_value': True},
        ],
        'metadata': {}
    }

def run(args, flags, user_context, **kwargs):
    """
    Sends a signal to one or more specified jobs or processes.
    """
    if not args:
        return {
            "success": False,
            "error": {
                "message": "kill: usage: kill [-s sigspec] pid | %job ...",
                "suggestion": "You must specify a job ID (e.g., %1) or process ID to signal."
            }
        }

    signal = flags.get('signal', 'TERM').upper()
    pid_args = list(args)

    if not flags.get('signal') and pid_args[0].startswith('-'):
        signal = pid_args[0][1:].upper()
        pid_args = pid_args[1:]

    if not pid_args:
        return {
            "success": False,
            "error": {
                "message": "kill: missing pid",
                "suggestion": "Please specify one or more job or process IDs."
            }
        }

    effects = []
    for pid_arg in pid_args:
        job_id = None
        if pid_arg.startswith('%'):
            try:
                job_id = int(pid_arg[1:])
            except (ValueError, IndexError):
                return {"success": False, "error": {"message": f"kill: invalid job spec: {pid_arg}", "suggestion": "Job IDs must be numbers, like '%1'."}}
        else:
            try:
                job_id = int(pid_arg)
            except ValueError:
                return {"success": False, "error": {"message": f"kill: invalid pid: {pid_arg}", "suggestion": "Process IDs must be numbers."}}

        effects.append({
            "effect": "signal_job",
            "job_id": job_id,
            "signal": signal
        })

    return {"effects": effects}


def man(args, flags, user_context, **kwargs):
    return """
NAME
    kill - send a signal to a process or job

SYNOPSIS
    kill [-s sigspec] [pid | %job]...
    kill -SIGNAME [pid | %job]...

DESCRIPTION
    The kill utility sends a signal to the specified processes or jobs. If no signal is specified, the TERM signal is sent, which requests a clean termination.

OPTIONS
    -s, --signal <sigspec>
        Specify the signal to be sent. Common signals include TERM, KILL, and STOP.

EXAMPLES
    kill %1
    kill -s KILL 12345
    kill -STOP %2
"""

def help(args, flags, user_context, **kwargs):
    return "Usage: kill [-s sigspec | -sigspec] [pid | %job]..."
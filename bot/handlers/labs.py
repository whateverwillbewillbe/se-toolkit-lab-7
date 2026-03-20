"""Handler for /labs command."""

from config import load_config
from services.lms_client import create_lms_client


def handle_labs() -> str:
    """Handle the /labs command.

    Returns:
        List of available labs.
    """
    config = load_config()
    client = create_lms_client(config)
    result = client.get_labs()

    if not result["success"]:
        return f"Error fetching labs: {result['error']}"

    labs = result["labs"]
    if not labs:
        return "No labs available."

    lines = ["Available labs:"]
    for lab in labs:
        name = lab.get("name", lab.get("id", "Unknown"))
        lab_id = lab.get("id", "")
        description = lab.get("description", "")

        # Format: "- Lab 01 — Products, Architecture & Roles"
        if description:
            lines.append(f"- {name} — {description}")
        else:
            lines.append(f"- {name}")

    return "\n".join(lines)

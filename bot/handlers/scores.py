"""Handler for /scores command."""


def handle_scores(lab_name: str = "") -> str:
    """Handle the /scores command.
    
    Args:
        lab_name: Name of the lab to get scores for.
    
    Returns:
        Scores information for the specified lab.
    """
    # Placeholder - will be implemented in Task 2 with real API call
    if lab_name:
        return f"Scores for {lab_name}:\n- Task 1: 85%\n- Task 2: 92%\n\n(placeholder)"
    return "Please specify a lab name. Example: /scores lab-01"

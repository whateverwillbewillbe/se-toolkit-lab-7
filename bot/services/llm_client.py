"""LLM client for intent routing."""

import httpx
import json
from typing import Optional, Any


class LLMClient:
    """Client for LLM API with tool calling support."""
    
    def __init__(self, api_key: str, base_url: str, model: str):
        """Initialize the LLM client.
        
        Args:
            api_key: API key for authentication
            base_url: Base URL of the LLM API
            model: Model name to use
        """
        self.api_key = api_key
        self.base_url = base_url.rstrip("/")
        self.model = model
        self._client: Optional[httpx.Client] = None
    
    def _get_client(self) -> httpx.Client:
        """Get or create HTTP client with auth headers."""
        if self._client is None:
            self._client = httpx.Client(
                base_url=self.base_url,
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json"
                },
                timeout=60.0
            )
        return self._client
    
    def chat(
        self,
        messages: list[dict],
        tools: Optional[list[dict]] = None,
        tool_choice: str = "auto"
    ) -> dict:
        """Send a chat request to the LLM.
        
        Args:
            messages: List of message dicts with 'role' and 'content'
            tools: Optional list of tool definitions
            tool_choice: How to use tools ("auto", "required", "none")
        
        Returns:
            Response dict with 'content' and/or 'tool_calls'
        """
        client = self._get_client()
        
        payload: dict[str, Any] = {
            "model": self.model,
            "messages": messages,
            "temperature": 0.7,
        }
        
        if tools:
            payload["tools"] = tools
            payload["tool_choice"] = tool_choice
        
        response = client.post("/chat/completions", json=payload)
        response.raise_for_status()
        data = response.json()
        
        choice = data.get("choices", [{}])[0]
        message = choice.get("message", {})
        
        return {
            "content": message.get("content", ""),
            "tool_calls": message.get("tool_calls", [])
        }
    
    def get_tool_definitions(self) -> list[dict]:
        """Get tool definitions for all backend endpoints.
        
        Returns:
            List of tool schemas for the LLM.
        """
        return [
            {
                "type": "function",
                "function": {
                    "name": "get_items",
                    "description": "Get list of all labs and tasks available in the system",
                    "parameters": {
                        "type": "object",
                        "properties": {},
                        "required": []
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_learners",
                    "description": "Get list of enrolled students and their groups",
                    "parameters": {
                        "type": "object",
                        "properties": {},
                        "required": []
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_scores",
                    "description": "Get score distribution (4 buckets) for a specific lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_pass_rates",
                    "description": "Get per-task average pass rates and attempt counts for a lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_timeline",
                    "description": "Get submissions per day timeline for a lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_groups",
                    "description": "Get per-group performance and student counts for a lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_top_learners",
                    "description": "Get top N learners by score for a lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"},
                            "limit": {"type": "integer", "description": "Number of top learners to return, e.g. 5"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "get_completion_rate",
                    "description": "Get completion rate percentage for a lab",
                    "parameters": {
                        "type": "object",
                        "properties": {
                            "lab": {"type": "string", "description": "Lab identifier, e.g. 'lab-01', 'lab-04'"}
                        },
                        "required": ["lab"]
                    }
                }
            },
            {
                "type": "function",
                "function": {
                    "name": "trigger_sync",
                    "description": "Trigger ETL sync to refresh data from autochecker",
                    "parameters": {
                        "type": "object",
                        "properties": {},
                        "required": []
                    }
                }
            }
        ]


def create_llm_client(config: dict) -> LLMClient:
    """Create an LLM client from config.
    
    Args:
        config: Configuration dictionary with LLM_API_KEY, LLM_API_BASE_URL, LLM_API_MODEL
    
    Returns:
        Configured LLMClient instance.
    """
    return LLMClient(
        api_key=config.get("LLM_API_KEY", ""),
        base_url=config.get("LLM_API_BASE_URL", "http://localhost:42005/v1"),
        model=config.get("LLM_API_MODEL", "coder-model")
    )

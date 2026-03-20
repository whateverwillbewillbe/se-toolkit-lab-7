"""API client for the LMS backend."""

import httpx
from typing import Optional


class LMSClient:
    """Client for the LMS backend API."""

    def __init__(self, base_url: str, api_key: str):
        """Initialize the LMS client.

        Args:
            base_url: Base URL of the LMS backend (e.g., http://localhost:42002)
            api_key: API key for authentication
        """
        self.base_url = base_url.rstrip("/")
        self.api_key = api_key
        self._client: Optional[httpx.Client] = None

    def _get_client(self) -> httpx.Client:
        """Get or create HTTP client with auth headers."""
        if self._client is None:
            self._client = httpx.Client(
                base_url=self.base_url,
                headers={"Authorization": f"Bearer {self.api_key}"},
                timeout=10.0,
            )
        return self._client

    def health_check(self) -> dict:
        """Check if the backend is healthy.

        Returns:
            Dict with 'healthy' bool and 'message' str.
        """
        try:
            client = self._get_client()
            response = client.get("/items/")
            response.raise_for_status()
            items = response.json()
            count = len(items) if isinstance(items, list) else 0
            return {
                "healthy": True,
                "message": f"Backend is healthy. {count} items available.",
                "item_count": count,
            }
        except httpx.ConnectError as e:
            return {
                "healthy": False,
                "message": f"Backend error: connection refused ({self.base_url}). Check that the services are running.",
                "error": str(e),
            }
        except httpx.HTTPStatusError as e:
            return {
                "healthy": False,
                "message": f"Backend error: HTTP {e.response.status_code} {e.response.reason_phrase}. The backend service may be down.",
                "error": str(e),
            }
        except Exception as e:
            return {
                "healthy": False,
                "message": f"Backend error: {str(e)}. Check that the services are running.",
                "error": str(e),
            }

    def get_labs(self) -> dict:
        """Get list of available labs.

        Returns:
            Dict with 'success' bool, 'labs' list, and 'error' str if failed.
        """
        try:
            client = self._get_client()
            response = client.get("/items/")
            response.raise_for_status()
            items = response.json()

            # Filter for labs (items with type 'lab')
            labs = []
            for item in items:
                if isinstance(item, dict):
                    item_type = item.get("type", "")
                    if item_type == "lab":
                        labs.append(
                            {
                                "title": item.get("title", ""),
                                "name": item.get("title", item.get("id", "Unknown")),
                                "id": item.get("id", ""),
                                "description": item.get("description", ""),
                            }
                        )

            return {"success": True, "labs": labs, "error": None}
        except httpx.ConnectError as e:
            return {
                "success": False,
                "labs": [],
                "error": f"Connection refused ({self.base_url}). Backend may be down.",
            }
        except httpx.HTTPStatusError as e:
            return {
                "success": False,
                "labs": [],
                "error": f"HTTP {e.response.status_code}: {e.response.reason_phrase}",
            }
        except Exception as e:
            return {"success": False, "labs": [], "error": str(e)}

    def get_scores(self, lab_name: str) -> dict:
        """Get scores for a specific lab.

        Args:
            lab_name: Lab identifier (e.g., "lab-04")

        Returns:
            Dict with 'success' bool, 'scores' list, and 'error' str if failed.
        """
        try:
            client = self._get_client()
            response = client.get("/analytics/pass-rates", params={"lab": lab_name})
            response.raise_for_status()
            data = response.json()

            # Handle different response formats
            if isinstance(data, list):
                scores = data
            elif isinstance(data, dict):
                scores = data.get("pass_rates", data.get("scores", []))
            else:
                scores = []

            return {"success": True, "scores": scores, "error": None}
        except httpx.ConnectError as e:
            return {
                "success": False,
                "scores": [],
                "error": f"Connection refused ({self.base_url}). Backend may be down.",
            }
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 404:
                return {
                    "success": False,
                    "scores": [],
                    "error": f"Lab '{lab_name}' not found.",
                }
            return {
                "success": False,
                "scores": [],
                "error": f"HTTP {e.response.status_code}: {e.response.reason_phrase}",
            }
        except Exception as e:
            return {"success": False, "scores": [], "error": str(e)}


def create_lms_client(config: dict) -> LMSClient:
    """Create an LMS client from config.

    Args:
        config: Configuration dictionary with LMS_API_URL and LMS_API_KEY

    Returns:
        Configured LMSClient instance.
    """
    return LMSClient(
        base_url=config.get("LMS_API_URL", "http://localhost:42002"),
        api_key=config.get("LMS_API_KEY", ""),
    )

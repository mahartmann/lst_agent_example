# server.py
from mcp.server.fastmcp import FastMCP

# Create an MCP server
mcp = FastMCP("SimpleServer")

# Add an addition tool
@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers"""
    return a + b


# Main execution block - this is required to run the server
if __name__ == "__main__":
    mcp.run()
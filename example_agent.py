"""
a simple agent backed by an LLM run via vllm as a server
"""
import asyncio
from langchain_mcp_adapters.client import MultiServerMCPClient
from langchain.agents import create_agent
from langgraph.checkpoint.memory import MemorySaver
import os
from langchain_openai import ChatOpenAI
import argparse

workdir = os.getcwd()



async def main(args):

    client = MultiServerMCPClient(
        {
            "simple_server": {
                "transport": "stdio",  # Local subprocess communication
                "command": "python",
                "args": [os.path.join(workdir, "example_server.py")]
            }
        }
    )

    config = {
        "configurable": {
            "thread_id": "example-session"
        }
    }


    tools = await client.get_tools()

    llm = ChatOpenAI(
        model=args.model,
        base_url=args.base_url,
    )


    agent = create_agent(
        model=llm,
        tools=tools,
        checkpointer=MemorySaver(),  # Required for multi-turn / persistence
    )

    task_instruction = "What's 25643563 plus 3763764?"
    messages = [{"role": "user", "content": task_instruction}]
    result = await agent.ainvoke({"messages": messages},
                                config=config)

    print(result)
    print(result["messages"][-1].content)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument("--base_url", type=str, default="http://localhost:8080/v1")
    parser.add_argument("--model", type=str, default="/scratch/common_models/Qwen3-8B")

    args = parser.parse_args()

    asyncio.run(main(args))

